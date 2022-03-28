//
//  NSSet+Array.swift
//  iPoll
//
//  Created by Evans Owamoyo on 28.03.2022.
//

import Foundation

extension NSSet {
    ///Converts a Set to an array of a particular type
    ///
    /// returns an empty array if type casting fails
    func toArray<T>(of type: T.Type) -> [T] {
        allObjects as? [T] ?? []
    }
}
