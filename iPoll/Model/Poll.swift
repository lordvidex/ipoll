//
//  Poll.swift
//  iPoll
//
//  Created by Evans Owamoyo on 06.03.2022.
//

import Foundation

struct Poll {
    let id: String
    let title: String
    let finished: Bool
    let startTime: Date
    let endTime: Date?
    let options: [PollOption]
}

struct PollOption {
    let id: String
    let title: String
    let votes: [String]
    
}
