//
//  PollManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation

protocol PollManagerProtocol {
    var createdPolls: [Poll]? { get }
    var joinedPolls: [Poll]? { get }
    func queryPolls(completion: ( (Bool) -> Void)?)
}

protocol PollManagerDelegate: AnyObject {
    func finishedFetchingPolls(_ success: Bool)
}

class PollManager: PollManagerProtocol {
    
    weak var delegate: PollManagerDelegate?
    
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
    
    
    private init() {}
    
    public static let shared = PollManager()
    
    let network: NetworkService = .shared
    
    var createdPolls: [Poll]?
    
    var joinedPolls: [Poll]?
    
}
