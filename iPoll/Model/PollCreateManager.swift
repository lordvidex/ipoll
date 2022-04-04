//
//  PollCreateManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 04.04.2022.
//

import UIKit

enum TimeCause {
    case start
    case end
}

// MARK: - PollCreateManagerDelegate
protocol PollCreateManagerDelegate: AnyObject {
    func didTogglePollHasTime(_ viewModel: PollCreateManager, value: Bool)
    
    func startTimeDidChange(_ viewModel: PollCreateManager,
                            cause: TimeCause,
                            to date: Date)
    
    func endTimeDidChange(_ viewModel: PollCreateManager,
                          cause: TimeCause,
                          to date: Date)
    
    func didToggleVoterAnonState(_ viewModel: PollCreateManager, value: Bool)
}

// MARK: Delegate Extension
/// defines default implementation to avoid necessary protocol stubs in ViewControllers that conform
/// to this protocol
extension PollCreateManagerDelegate {
    func didToggleVoterAnonState(_ viewModel: PollCreateManager, value: Bool) {
        
    }
}

// MARK: - PollCreateManagerProtocol
protocol PollCreateManagerProtocol {
    var delegate: PollCreateManagerDelegate? { get set }
    var startTime: Date { get set }
    var endTime: Date? { get set }
    var hasTime: Bool { get set }
    var options: [String] { get }
    
}

// MARK: - PollCreateManager [ViewModel]
class PollCreateManager: PollCreateManagerProtocol {
    
    weak var delegate: PollCreateManagerDelegate?
    
    public static let shared = PollCreateManager()
    
    var hasTime = false {
        didSet {
            if oldValue != hasTime {
                delegate?.didTogglePollHasTime(self, value: hasTime)
            }
        }
    }
    
    var isVoterAnonymous = true {
        didSet {
            if oldValue != isVoterAnonymous {
                delegate?.didToggleVoterAnonState(self, value: isVoterAnonymous)
            }
        }
    }
    
    var startTime: Date = .now {
        didSet {
            delegate?.startTimeDidChange(self, cause: .start, to: startTime)
            
            // the endTime must not be less than the startTime
            if let endTime = endTime,
                endTime < startTime {
                delegate?.endTimeDidChange(self, cause: .start, to: startTime)
            }
        }
    }
    
    var endTime: Date? = Calendar.current.date(byAdding: .day, value: 1, to: .now) {
        didSet {
            if let endTime = endTime {
                delegate?.endTimeDidChange(self, cause: .end, to: endTime)
            }
            
            // the startTime must not be greater than the endTime
            if let endTime = endTime,
               endTime < startTime {
                delegate?.startTimeDidChange(self, cause: .end, to: endTime)
            }
        }
    }
    
    var options = ["Option 1", "Option 2"]
    private var _optionCount = 2
    var optionCount: Int {
        _optionCount += 1
        return _optionCount
        
    }
    
}
