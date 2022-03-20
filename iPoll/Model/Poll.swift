//
//  Poll.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import Foundation

struct Poll: Codable {
    let id: String
    let title: String
//    let finished: Bool
    let isAnonymous: Bool
//    let startTime: Date
//    let endTime: Date?
    let options: [PollOption]?
    
    var totalVotes: Int {
        var count = 0
        if let options = options {
            for option in options {
                count += option.votesId.count
            }
        }
        return count
    }
}

struct PollOption: Codable {
    let id: String
    let title: String
    let votesId: [String]
}
