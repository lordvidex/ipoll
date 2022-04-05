//
//  PeriodicManagerDelegateMock.swift
//  iPollTests
//
//  Created by Evans Owamoyo on 05.04.2022.
//

import Foundation
@testable import iPoll

class PeriodicManagerDelegateMock: PeriodicManagerDelegate {
    
    var invokedDidCallUpdate = false
    var invokedDidCallUpdateCount = 0
    var invokedDidCallUpdateParameters: (manager: PeriodicManager, timer: Timer, period: TimeInterval)?
    var invokedDidCallUpdateParametersList = [(manager: PeriodicManager, timer: Timer, period: TimeInterval)]()
    
    func didCallUpdate(_ manager: PeriodicManager,
                       with timer: Timer,
                       period: TimeInterval) {
        invokedDidCallUpdate = true
        invokedDidCallUpdateCount += 1
        invokedDidCallUpdateParameters = (manager, timer, period)
        invokedDidCallUpdateParametersList.append((manager, timer, period))
    }
}
