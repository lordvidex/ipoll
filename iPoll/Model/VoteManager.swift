//
//  VoteManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.03.2022.
//

import Foundation

protocol VoteManagerDelegate: AnyObject {
    func didFetchPoll(_ voteManager: VoteManager, poll: Poll)
    func didFail(_ voteManager: VoteManager, with error: IPollError)
}
protocol VoteManagerProtocol {
    func fetchPoll(_ id: String)
}

struct VoteManager: VoteManagerProtocol {
    private let network: NetworkService = .shared
    weak var delegate: VoteManagerDelegate?
    
    func fetchPoll(_ id: String) {
        network.getPoll(id) { result in
            switch result {
                case .success(let poll):
                    delegate?.didFetchPoll(self, poll: poll)
                case .failure(let error):
                    delegate?.didFail(self, with: error)
            }
        }
    }
    
    func vote(pollId: String, optionId: String) {
        network.vote(pollId: pollId, optionId: optionId) { result in
            switch result {
                case .success(let poll):
                    delegate?.didFetchPoll(self, poll: poll)
                case .failure(let error):
                    delegate?.didFail(self, with: error)
                    
            }
        }
    }
}
