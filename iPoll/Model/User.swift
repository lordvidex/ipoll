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
    var participatedPolls: [Poll]? = []
    var createdPolls: [Poll]? = []
}
