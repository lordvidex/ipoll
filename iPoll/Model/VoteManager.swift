//
//  VoteManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 20.03.2022.
//

import Foundation

enum Action {
    case vote
    case fetch
}

protocol VoteManagerDelegate: AnyObject {
    func didFetchPoll(_ voteManager: VoteManager,sender: Action, poll: Poll)
    func didFail(_ voteManager: VoteManager,sender: Action, with error: IPollError)
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
                    delegate?.didFetchPoll(self, sender: .fetch, poll: poll)
                case .failure(let error):
                    delegate?.didFail(self, sender: .fetch, with: error)
            }
        }
    }
    
    func vote(pollId: String, optionId: String) {
        network.vote(pollId: pollId, optionId: optionId) { result in
            switch result {
                case .success(let poll):
                    delegate?.didFetchPoll(self, sender: .vote, poll: poll)
                case .failure(let error):
                    delegate?.didFail(self, sender: .vote, with: error)
                    
            }
        }
    }
}
