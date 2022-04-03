//
//  MockPersistentService.swift
//  iPollTests
//
//  Created by Evans Owamoyo on 03.04.2022.
//

import Foundation
@testable import iPoll

class MockPersistentService: PersistenceServiceProtocol {

    var invokedFetchPolls = false
    var invokedFetchPollsCount = 0
    var stubbedFetchPollsResult: [Poll]! = []

    func fetchPolls() -> [Poll] {
        invokedFetchPolls = true
        invokedFetchPollsCount += 1
        return stubbedFetchPollsResult
    }

    var invokedFetchPoll = false
    var invokedFetchPollCount = 0
    var invokedFetchPollParameters: (id: String, Void)?
    var invokedFetchPollParametersList = [(id: String, Void)]()
    var stubbedFetchPollResult: Poll!

    func fetchPoll(with id: String) -> Poll? {
        invokedFetchPoll = true
        invokedFetchPollCount += 1
        invokedFetchPollParameters = (id, ())
        invokedFetchPollParametersList.append((id, ()))
        return stubbedFetchPollResult
    }

    var invokedSavePoll = false
    var invokedSavePollCount = 0
    var invokedSavePollParameters: (poll: Poll, Void)?
    var invokedSavePollParametersList = [(poll: Poll, Void)]()

    func savePoll(_ poll: Poll) {
        invokedSavePoll = true
        invokedSavePollCount += 1
        invokedSavePollParameters = (poll, ())
        invokedSavePollParametersList.append((poll, ()))
    }
}
