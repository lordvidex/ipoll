//
//  IPollError.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation

struct IPollError: Error, Decodable {
    var message: String
    var statusCode: Int?
    var error: String?
    
    init(message: String?) {
        self.message = message ?? "An Error Occured"
    }
}
