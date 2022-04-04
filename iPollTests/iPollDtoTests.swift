//
//  iPollDtoTests.swift
//  iPollTests
//
//  Created by Evans Owamoyo on 04.04.2022.
//

import XCTest
@testable import iPoll

class IPollDtoTests: XCTestCase {
    var date1: Date!
    var date2: Date!
    var dto: PollDto!
    
    override func setUpWithError() throws {
        date1 = .now
        date2 = Calendar.current.date(byAdding: .month, value: 1, to: date1)
        dto = PollDto(title: "Evans",
                      options: ["Option1", "Option2"],
                      hasTimeLimit: true,
                      isAnonymous: true,
                      startTime: date1,
                      endTime: date2)
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        date1 = nil
        date2 = nil
        dto = nil
        try super.tearDownWithError()
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
