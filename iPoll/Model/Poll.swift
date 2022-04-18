//
//  Poll.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import UIKit

struct Poll: Codable {
    let id: String
    let title: String
    let authorId: String?
    let isAnonymous: Bool
    let hasTimeLimit: Bool
    let startTime: Date
    let endTime: Date?
    let author: Author?
    let options: [PollOption]?
    var color: UIColor?
    
    enum CodingKeys: String, CodingKey {
        case id, title, authorId, isAnonymous, hasTimeLimit, startTime, endTime, author, options
    }
    
    mutating func copyWith(_ poll: Poll) -> Poll {
        
         Poll(id: poll.id,
             title: poll.title,
             authorId: poll.authorId ?? authorId,
             isAnonymous: poll.isAnonymous,
             hasTimeLimit: poll.hasTimeLimit,
             startTime: poll.startTime,
             endTime: poll.endTime ?? endTime,
             author: poll.author ?? author,
             options: poll.options ?? options,
             color: poll.color ?? color)
    }
    
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

struct Author: Codable {
    let name: String?
    let id: String
}

struct PollOption: Codable {
    let id: String
    let title: String
    let votesId: [String]
}
