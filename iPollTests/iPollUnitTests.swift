//
//  iPollUnitTests.swift
//  iPollUnitTests
//
//  Created by Evans Owamoyo on 03.04.2022.
//

import XCTest
@testable import iPoll

class iPollUnitTests: XCTestCase {
    
    var pollViewModel: PollViewModel!
    var networkService: MockNetworkService!
    var persistentService: MockPersistentService!
    var poll: Poll!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        poll = Poll(id: "1", title: "Test Title", isAnonymous: true, options: [])
        
        networkService = MockNetworkService()
        persistentService = MockPersistentService()
        pollViewModel = PollViewModel(networkService: networkService, persistentService: persistentService)
    }
    
    override func tearDownWithError() throws {
        pollViewModel = nil
        try super.tearDownWithError()
    }
    
    
    func testVoteCountForEmptyPollVotesIsZero() {
        let options = [PollOption]()
        poll = Poll(id: "2", title: "Empty Poll", isAnonymous: true, options: options)
        XCTAssertEqual(poll.totalVotes, 0)
    }
    
    func testVoteCountForPollEqualsSum() {
        
        // Given
        let options = [
            PollOption(id: "Option1", title: "Option 1", votesId: ["user1", "user2"]),
            PollOption(id: "Option2", title: "Option 2", votesId: ["user3", "user4"])
        ]
        poll = Poll(id: "1", title: "Test Title", isAnonymous: true, options: options)
        
        // When
        var total = 0
        poll.options!.forEach { total += $0.votesId.count }
        
        // Then
        XCTAssertEqual(poll.totalVotes, total)
    }
    
    func testExtensionNSSetToArray() {
        // Given
        let array = ["1", "2", "3"]
        let set: NSSet = NSSet(array: array)
        
        // When
        let items = set.toArray(of: String.self)
        
        // Then
        XCTAssertEqual(array, items)
    }
    
    func testThatFetchVisitedPollsSetsLocalVariable() {
        // Given
        persistentService.stubbedFetchPollsResult = [poll]
        
        // When
        pollViewModel.fetchVisitedPolls()
        
        // Then
        XCTAssertTrue(persistentService.invokedFetchPolls)
        XCTAssertEqual(pollViewModel.visitedPolls, [poll])
    }
    
}
