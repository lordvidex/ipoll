//
//  Weak.swift
//  iPoll
//
//  Created by Evans Owamoyo on 05.04.2022.
//
import Foundation

class Weak<T: AnyObject> {
    weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}
