//
//  IPollError.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation

struct IPollError: Error {
    var message: String
    init(message: String?) {
        self.message = message ?? "An Error Occured"
    }
}
