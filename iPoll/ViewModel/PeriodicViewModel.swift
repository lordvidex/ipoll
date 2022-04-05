//
//  PeriodicViewModel.swift
//  iPoll
//
//  Created by Evans Owamoyo on 05.04.2022.
//

import Foundation

//
//  PeriodicManager.swift
//  iPoll
//
//  Created by Evans Owamoyo on 05.04.2022.
//
import Foundation

// MARK: - PeriodicManagerDelegate
protocol PeriodicManagerDelegate: AnyObject {
    func didCallUpdate(_ manager: PeriodicManager,
                       with timer: Timer,
                       period: TimeInterval)
}

// MARK: - PeriodicManagerProtocol
protocol PeriodicManagerProtocol {
    var period: TimeInterval { get }
    func startTimer()
    func stopTimer()
    func addListener(_ listener: PeriodicManagerDelegate)
    func removeListener(_ listener: PeriodicManagerDelegate)
    func removeListener(where: (PeriodicManagerDelegate) -> Bool)
}

// MARK: - PeriodicManager
/// ViewModel that updates it's listeners periodically
class PeriodicManager: PeriodicManagerProtocol {
    
    init(period: TimeInterval) {
        self.period = period
        self.listeners = []
        startTimer()
    }
    
    private var listeners: [Any]!
    
    let period: TimeInterval
    private var timer: Timer!
    
    func startTimer() {
        if timer != nil {
            timer = Timer.scheduledTimer(timeInterval: period,
                                         target: self,
                                         selector: #selector(update),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func stopTimer() {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
    }
    
    func addListener(_ listener: PeriodicManagerDelegate) {
        purgeNil()
        listeners.append(Weak(listener as AnyObject))
    }
    
    func removeListener(_ listener: PeriodicManagerDelegate) {
        purgeNil()
        listeners.removeAll { weakElement in
            if let weakElement = weakElement as? Weak<AnyObject>,
               let object = weakElement.object {
                return object === listener
            } else {
                return true
            }
        }
    }
    
    func removeListener(where: (PeriodicManagerDelegate) -> Bool) {
        purgeNil()
        listeners.removeAll { weakEl in
            if let weakElement = weakEl as? Weak<AnyObject>,
               let object = weakElement.object {
                if let object = object as? PeriodicManagerDelegate {
                    return `where`(object)
                } else {
                    // stored not type of PeriodicManagerDelegate or nil
                    return true // remove
                }
            } else {
                return true
            }
        }
    }
    
    @objc func update(_ timer: Timer) {
        purgeNil()
        for listener in listeners {
            if let listener = listener as? Weak<AnyObject>,
               let delegate = listener.object as? PeriodicManagerDelegate {
                delegate.didCallUpdate(self, with: timer, period: period)
            }
        }
    }
    
    /// Used to remove `nil` elements from array
    func purgeNil() {
        listeners.removeAll { elem in
            if let elem = elem as? Weak<AnyObject> {
                return elem.object == nil
            } else {
                return true
            }
        }
    }
    
    deinit {
        // remove all listeners
        removeListener { _ in
            return true
        }
        listeners = nil
        stopTimer()
    }
    
}
