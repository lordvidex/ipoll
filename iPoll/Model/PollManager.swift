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
    var joinedPolls: [Poll]? { get }
    func queryPolls(completion: ( (Bool) -> Void)?)
    func createPoll(title: String,
                    options: [String],
                    completion: ((Result<Poll, IPollError>) -> Void)?)
}


/// Delegate for updating view from the ViewModel
protocol PollManagerDelegate: AnyObject {
    func finishedFetchingPolls(_ success: Bool)
}


class PollManager: PollManagerProtocol {
    
    // MARK: variables
    weak var delegate: PollManagerDelegate?
    
    public static let shared = PollManager()
    
    let network: NetworkService = .shared
    
    var createdPolls: [Poll]?
    
    var joinedPolls: [Poll]?
    
    private init() {}
    
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
    
    func queryPolls(completion: ( (Bool) -> Void )? = nil) {
        network.getUser { [weak self] result in
            switch result {
                case .success(let user):
                    self?.createdPolls = user.createdPolls
                    self?.joinedPolls = user.participatedPolls
                    completion?(true)
                    self?.delegate?.finishedFetchingPolls(true)
                case .failure(let err):
                    completion?(false)
                    self?.delegate?.finishedFetchingPolls(false)
                    print(err.message)
            }
        }
    }
}
