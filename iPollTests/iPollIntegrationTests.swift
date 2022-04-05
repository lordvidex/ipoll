//
//  iPollIntegrationTests.swift
//  iPollIntegrationTests
//
//  Created by Evans Owamoyo on 03.04.2022.
//

import XCTest
@testable import iPoll

class iPollIntegrationTests: XCTestCase {
    var viewController: MockPollViewController!
    var viewModel: PollViewModel!
    var user: User!
    var polls: [Poll]!
    var networkService: MockNetworkService!
    var persistentService: MockPersistentService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        polls = [
            Poll(id: "1",
                 title: "1",
                 isAnonymous: true,
                 hasTimeLimit: false,
                 startTime: .now,
                 endTime: nil,
                 options: nil),
            Poll(id: "2",
                 title: "2",
                 isAnonymous: true,
                 hasTimeLimit: false,
                 startTime: .now,
                 endTime: nil,
                 options: nil)]
        user = User(id: "user1",
                    name: "Swift Tester",
                    participatedPolls: [polls[0]],
                    createdPolls: [polls[1]])
        
        networkService = MockNetworkService()
        persistentService = MockPersistentService()
        viewModel = PollViewModel(networkService: networkService,
                                  persistentService: persistentService)
        viewController = MockPollViewController(pollViewModel: viewModel)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        viewController = nil
        try super.tearDownWithError()
    }
    
    func testThatViewControllerisDelegateWhenViewIsLoaded() {
        // When
        viewController.initViewModel()
        
        // Then
        XCTAssertNotNil(viewModel.delegate)
        XCTAssertIdentical(viewModel.delegate!, viewController)
    }
    
    func testThatNetworkPollsAreFetchedOnViewLoaded() {
        // Given
        networkService.stubbedGetUserCompletionResult = (.success(user), ())
        
        // When
        viewController.initViewModel()
        
        // Then
        XCTAssertTrue(networkService.invokedGetUser) // gets the user and his polls from the server
        XCTAssertEqual(viewModel.participatedPolls!, [polls[0]])
    }
    
    func testThatViewModelUpdatesViewOnPollsFetched() {
        // Given
        networkService.stubbedGetUserCompletionResult = (.success(user), ())
        
        // When
        viewController.initViewModel()
        // Then
        XCTAssertTrue(viewController.invokedFinishedFetchingPolls) // delegate method called
        XCTAssertEqual(viewController.invokedFinishedFetchingPollsCount, 1)
    }
    
    func testThatPersistentPollsAreFetchedOnViewLoaded() {
        // Given
        persistentService.stubbedFetchPollsResult = polls
        
        // When
        viewController.initViewModel()
        
        // Then
        XCTAssertTrue(persistentService.invokedFetchPolls)
        XCTAssertEqual(persistentService.invokedFetchPollsCount, 1)
        XCTAssertEqual(viewModel.visitedPolls, polls)
    }
}
