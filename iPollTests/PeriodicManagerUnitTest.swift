//
//  PeriodicManagerUnitTest.swift
//  iPollTests
//
//  Created by Evans Owamoyo on 05.04.2022.
//

import XCTest
@testable import iPoll

class PeriodicManagerUnitTest: XCTestCase {
    var periodicManager: PeriodicManager!
    var listener: PeriodicManagerDelegateMock!

    override func setUpWithError() throws {
        try super.setUpWithError()
        periodicManager = PeriodicManager(period: 2)
        listener = PeriodicManagerDelegateMock()
    }

    override func tearDownWithError() throws {
        listener = nil
        periodicManager.removeListener { _ in true }
        periodicManager = nil
    }
    
    func testAddListener() {
        // When
        periodicManager.addListener(listener)
        
        // Then
        XCTAssertTrue(periodicManager.hasListener(listener))
    }
    
    func testRemoveListenerOnEmpty() {
        // Given
        periodicManager.addListener(listener)
        
        // When
        periodicManager.removeListener(listener)
        
        // Then
        XCTAssertFalse(periodicManager.hasListener(listener))
    }
    
    func testWeakListenerReference() {
        // Given
        periodicManager.addListener(listener)
        XCTAssertEqual(periodicManager.listeners.count, 1)
        
        // When
        listener = nil
        
        // Then
        XCTAssertEqual(periodicManager.listeners.count, 0)
    }
    
    func testTimerCallsListeners() {
        // Given
        periodicManager = PeriodicManager(period: 0.1)
        periodicManager.addListener(listener)
        
        // When
        let expectation = XCTestExpectation(description: "wait for timer to tick")
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        
        // Then
        XCTAssertTrue(listener.invokedDidCallUpdate)
        XCTAssertGreaterThanOrEqual(listener.invokedDidCallUpdateCount, 4)
    }

}
