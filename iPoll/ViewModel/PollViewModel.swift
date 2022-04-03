//
//  PollManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation

/// PollManagers ViewModels must conform to the following protocol
protocol PollViewModelProtocol {
    // network handler for ViewModel
    var network: NetworkServiceProtocol { get }
    
    // local storage handler for ViewModel
    var persistent: PersistenceServiceProtocol { get }
    
    // event dispatcher for viewModel
    var delegate: PollViewModelDelegate? { get set }
    
    // polls created by the logged in User
    var createdPolls: [Poll]? { get }
    
    // polls visited by the logged in User
    var visitedPolls: [Poll]? { get }
    
    // polls in which the user voted
    var participatedPolls: [Poll]? { get }
    
    // callback for getting remote polls
    func fetchRemotePolls(completion: ( (Bool) -> Void)?)
    
    // callback for creating a new poll
    func createPoll(title: String,
                    options: [String],
                    completion: ((Result<Poll, IPollError>) -> Void)?)
    
    // callback for getting visited polls
    func fetchVisitedPolls()
}

/// Delegate for updating view from the ViewModel
protocol PollViewModelDelegate: AnyObject {
    func finishedFetchingPolls(_ success: Bool)
}

class PollViewModel: PollViewModelProtocol {

    // MARK: variables
    weak var delegate: PollViewModelDelegate?


    let network: NetworkServiceProtocol

    let persistent: PersistenceServiceProtocol

    var createdPolls: [Poll]?

    var visitedPolls: [Poll]?

    var participatedPolls: [Poll]?

    init(networkService: NetworkServiceProtocol, persistentService: PersistenceServiceProtocol) {
        self.network = networkService
        self.persistent = persistentService
    }

    // MARK: functions
    func createPoll(title: String,
                    options: [String],
                    completion: ((Result<Poll, IPollError>) -> Void)?) {
        network.createPoll(title: title, options: options) { result in
            switch result {
                case .success(let poll):
                    completion?(.success(poll))
                case .failure(let err):
                    completion?(.failure(err))
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
