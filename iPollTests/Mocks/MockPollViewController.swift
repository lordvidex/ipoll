//
//  PollWasUpdatedProtocol.swift
//  iPollTests
//
//  Created by Evans Owamoyo on 03.04.2022.
//

import Foundation
@testable import iPoll

/// Class that mocks only `updatePolls` function for class [PollViewController]
class MockPollViewController: PollViewController {

    var invokedFinishedFetchingPolls = false
    var invokedFinishedFetchingPollsCount = 0
    
    
    override func finishedFetchingPolls(_ success: Bool) {
        invokedFinishedFetchingPolls = true
        invokedFinishedFetchingPollsCount += 1
        super.finishedFetchingPolls(success)
    }

}


