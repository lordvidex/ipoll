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
    var date1: Date!
    var date2: Date!
    var dto: PollDto!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        poll = Poll(id: "1",
                    title: "Test Title",
                    isAnonymous: true,
                    hasTimeLimit: false,
                    startTime: .now,
                    endTime: nil,
                    options: [])
        
        networkService = MockNetworkService()
        persistentService = MockPersistentService()
        pollViewModel = PollViewModel(networkService: networkService, persistentService: persistentService)
        
        date1 = .now
        date2 = Calendar.current.date(byAdding: .month, value: 1, to: date1)
        dto = PollDto(title: "Evans",
                      options: ["Option1", "Option2"],
                      hasTimeLimit: true,
                      isAnonymous: true,
                      startTime: date1,
                      endTime: date2)
    }
    
    override func tearDownWithError() throws {
        pollViewModel = nil
        date1 = nil
        date2 = nil
        dto = nil
        try super.tearDownWithError()
    }
    
    
    func testVoteCountForEmptyPollVotesIsZero() {
        let options = [PollOption]()
        poll = Poll(id: "2",
                    title: "Empty Poll",
                    isAnonymous: true,
                    hasTimeLimit: false,
                    startTime: .now,
                    endTime: nil,
                    options: options)
        XCTAssertEqual(poll.totalVotes, 0)
    }
    
    func testVoteCountForPollEqualsSum() {
        
        // Given
        let options = [
            PollOption(id: "Option1", title: "Option 1", votesId: ["user1", "user2"]),
            PollOption(id: "Option2", title: "Option 2", votesId: ["user3", "user4"])
        ]
        poll = Poll(id: "1",
                    title: "Test Title",
                    isAnonymous: true,
                    hasTimeLimit: false,
                    startTime: .now,
                    endTime: nil,
                    options: options)
        
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
    
    func testThatCreateDtoDoesNotEncodeNilValues() throws {
        // Given
        dto = PollDto(title: dto.title,
                      options: dto.options,
                      hasTimeLimit: false,
                      isAnonymous: true,
                      startTime: nil,
                      endTime: nil)
        
        // When
        let dictionary = try encodeDtoToDictionary(dto)
        
        // Then
        XCTAssertNotNil(dictionary)
        XCTAssertFalse(dictionary!.contains { $0.key == "startTime" })
        XCTAssertFalse(dictionary!.contains { $0.key == "endTime" })
    }
    
    func testThatCreateDtoEncodesProperly() throws {
        // Given
        
        // When
        let dictionary = try encodeDtoToDictionary(dto)
        
        // Then
        XCTAssertNotNil(dictionary)
        XCTAssertEqual(dictionary?["title"] as? String, "Evans")
        XCTAssertEqual(dictionary?["options"] as? [String], ["Option1", "Option2"])
        XCTAssertEqual(dictionary?["hasTime"] as? Bool, true)
        XCTAssertEqual(dictionary?["startTime"] as? String,
                       DateFormatter.iso8601Full.string(from: date1))
        XCTAssertEqual(dictionary?["endTime"] as? String,
                       DateFormatter.iso8601Full.string(from: date2!))
        
    }
    
    func encodeDtoToDictionary(_ dto: PollDto) throws -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(.iso8601Full)
        let data = try encoder.encode(dto)
        let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return dictionary
    }

}
