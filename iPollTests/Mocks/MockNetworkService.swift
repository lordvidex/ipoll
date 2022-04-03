//
//  MockNetworkService.swift
//  iPollTests
//
//  Created by Evans Owamoyo on 03.04.2022.
//

import Foundation
@testable import iPoll

class MockNetworkService: NetworkServiceProtocol {

    var invokedBaseUrlGetter = false
    var invokedBaseUrlGetterCount = 0
    var stubbedBaseUrl: String! = ""

    var baseUrl: String {
        invokedBaseUrlGetter = true
        invokedBaseUrlGetterCount += 1
        return stubbedBaseUrl
    }

    var invokedGetUser = false
    var invokedGetUserCount = 0
    var stubbedGetUserCompletionResult: (Result<User, IPollError>, Void)?

    func getUser(completion: @escaping (Result<User, IPollError>) -> Void) {
        invokedGetUser = true
        invokedGetUserCount += 1
        if let result = stubbedGetUserCompletionResult {
            completion(result.0)
        }
    }

    var invokedCreatePoll = false
    var invokedCreatePollCount = 0
    var invokedCreatePollParameters: (title: String, options: [String])?
    var invokedCreatePollParametersList = [(title: String, options: [String])]()
    var stubbedCreatePollCompletionResult: (Result<Poll, IPollError>, Void)?

    func createPoll(title: String, options: [String], completion: @escaping (Result<Poll, IPollError>) -> Void) {
        invokedCreatePoll = true
        invokedCreatePollCount += 1
        invokedCreatePollParameters = (title, options)
        invokedCreatePollParametersList.append((title, options))
        if let result = stubbedCreatePollCompletionResult {
            completion(result.0)
        }
    }

    var invokedGetPoll = false
    var invokedGetPollCount = 0
    var invokedGetPollParameters: (id: String, Void)?
    var invokedGetPollParametersList = [(id: String, Void)]()
    var stubbedGetPollCompletionResult: (Result<Poll, IPollError>, Void)?

    func getPoll(_ id: String, completion: @escaping (Result<Poll, IPollError>) -> Void) {
        invokedGetPoll = true
        invokedGetPollCount += 1
        invokedGetPollParameters = (id, ())
        invokedGetPollParametersList.append((id, ()))
        if let result = stubbedGetPollCompletionResult {
            completion(result.0)
        }
    }

    var invokedVote = false
    var invokedVoteCount = 0
    var invokedVoteParameters: (pollId: String, optionId: String)?
    var invokedVoteParametersList = [(pollId: String, optionId: String)]()
    var stubbedVoteCompletionResult: (Result<Poll, IPollError>, Void)?

    func vote(pollId: String, optionId: String, completion: @escaping (Result<Poll, IPollError>) -> Void) {
        invokedVote = true
        invokedVoteCount += 1
        invokedVoteParameters = (pollId, optionId)
        invokedVoteParametersList.append((pollId, optionId))
        if let result = stubbedVoteCompletionResult {
            completion(result.0)
        }
    }
}
