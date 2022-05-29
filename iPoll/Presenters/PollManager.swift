//
//  PollManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation

/// PollManagers ViewModels must conform to the following protocol
protocol PollManagerProtocol {
    var delegate: PollManagerDelegate? { get set }
    var createdPolls: [Poll]? { get }
    var visitedPolls: [Poll]? { get }
    var participatedPolls: [Poll]? { get }
    func fetchRemotePolls(completion: ( (Bool) -> Void)?)
    func createPoll(pollDto: PollDto,
                    completion: ((Result<Poll, IPollError>) -> Void)?)
}

/// Delegate for updating view from the ViewModel
protocol PollManagerDelegate: AnyObject {
    func finishedFetchingPolls(_ success: Bool)
    func finishedFetchingPoll(_ poll: Poll?, or error: IPollError?)
}

extension PollManagerDelegate {
    func finishedFetchingPoll(_ poll: Poll?, or error: IPollError?) {}
}

class PollManager: PollManagerProtocol {

    // MARK: variables
    weak var delegate: PollManagerDelegate?

    public static let shared = PollManager()

    let network: NetworkService = .shared

    let persistent: PersistenceService = .shared

    var createdPolls: [Poll]?

    var visitedPolls: [Poll]?

    var participatedPolls: [Poll]?

    // MARK: functions
    func createPoll(pollDto: PollDto,
                    completion: ((Result<Poll, IPollError>) -> Void)?) {
        network.createPoll(poll: pollDto) { result in
            switch result {
                case .success(let poll):
                    completion?(.success(poll))
                case .failure(let err):
                    completion?(.failure(err))
            }
        }
    }
    
    func editPoll(id: String, pollDto: PollDto, completion: ((Result<Poll, IPollError>) -> Void)?) {
        network.editPoll(id, dto: pollDto) { result in
            switch result {
                case .success(let poll):
                    completion?(.success(poll))
                case .failure(let err):
                    completion?(.failure(err))
            }
        }
    }
    
    func fetchPoll(with id: String) {
        network.getPoll(id) { [weak self] result in
            switch result {
                case .success(let poll):
                    self?.delegate?.finishedFetchingPoll(poll, or: nil)
                case .failure(let error):
                    self?.delegate?.finishedFetchingPoll(nil, or: error)
            }
        }
    }

    func fetchRemotePolls(completion: ( (Bool) -> Void )? = nil) {
        network.getUser { [weak self] result in
            switch result {
                case .success(let user):
                    self?.createdPolls = user.createdPolls
                    self?.participatedPolls = user.participatedPolls
                    completion?(true)
                    self?.delegate?.finishedFetchingPolls(true)
                case .failure(let err):
                    completion?(false)
                    self?.delegate?.finishedFetchingPolls(false)
                    print(err.message)
            }
        }
    }

    func fetchVisitedPolls() {
        visitedPolls = persistent.fetchPolls()
    }
}
