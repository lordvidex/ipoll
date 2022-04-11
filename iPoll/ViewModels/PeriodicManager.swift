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
        self._listeners = []
        startTimer()
    }
    
    /// shared Periodic manager with frequency of 60 seconds
    static var shared = PeriodicManager(period: 60)
    
    private var _listeners: [Any]!
    
    var listeners: [PeriodicManagerDelegate] {
        purgeNil()
        
        var array = [PeriodicManagerDelegate]()
        
        for listener in _listeners {
            if let listener = listener as? Weak<AnyObject>,
            let object = listener.object as? PeriodicManagerDelegate {
                array.append(object)
            }
        }
        return array
    }
    
    let period: TimeInterval
    private var timer: Timer!
    
    func startTimer() {
        if timer == nil {
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
        _listeners.append(Weak(listener as AnyObject))
    }
    
    func hasListener(_ listener: PeriodicManagerDelegate) -> Bool {
        purgeNil()
        return _listeners.contains { each in
            if let weakEl = each as? Weak<AnyObject>,
               let obj = weakEl.object {
                return obj === listener
            }
            return false
        }
    }
    
    func removeListener(_ listener: PeriodicManagerDelegate) {
        purgeNil()
        _listeners.removeAll { weakElement in
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
        _listeners.removeAll { weakEl in
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
        for listener in _listeners {
            if let listener = listener as? Weak<AnyObject>,
               let delegate = listener.object as? PeriodicManagerDelegate {
                DispatchQueue.global(qos: .utility).async { [weak self] in
                    if let self = self {
                        delegate.didCallUpdate(self, with: timer, period: self.period)
                    }
                }
            }
        }
    }
    
    /// Used to remove `nil` elements from array
    func purgeNil() {
        _listeners.removeAll { elem in
            if let elem = elem as? Weak<AnyObject> {
                return elem.object == nil
            } else {
                return true
            }
        }
    }
    
    deinit {
        // remove all listeners
        removeListener { _ in true} 
        _listeners = nil
        stopTimer()
    }
        
}
