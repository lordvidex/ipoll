//
//  MockPollViewModel.swift
//  iPollTests
//
//  Created by Evans Owamoyo on 03.04.2022.
//

import Foundation
@testable import iPoll

class MockPollViewModel: PollViewModelProtocol {

    var stubbedNetwork: NetworkServiceProtocol!

    var network: NetworkServiceProtocol {
        return stubbedNetwork
    }

    var stubbedPersistent: PersistenceServiceProtocol!

    var persistent: PersistenceServiceProtocol {
        return stubbedPersistent
    }

    var stubbedDelegate: PollViewModelDelegate!

    var delegate: PollViewModelDelegate? {
        set {}
        get {
            return stubbedDelegate
        }
    }

    var stubbedCreatedPolls: [Poll]!

    var createdPolls: [Poll]? {
        return stubbedCreatedPolls
    }

    var stubbedVisitedPolls: [Poll]!

    var visitedPolls: [Poll]? {
        return stubbedVisitedPolls
    }

    var stubbedParticipatedPolls: [Poll]!

    var participatedPolls: [Poll]? {
        return stubbedParticipatedPolls
    }

    func fetchRemotePolls(completion: ( (Bool) -> Void)?) {}

    func createPoll(title: String,
        options: [String],
        completion: ((Result<Poll, IPollError>) -> Void)?) {}

    func fetchVisitedPolls() {}
}
