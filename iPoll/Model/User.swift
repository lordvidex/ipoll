//
//  User.swift
//  iPoll
//
//  Created by Evans Owamoyo on 19.03.2022.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String?
    let participatedPolls: [Poll]
    let createdPolls: [Poll]
}
