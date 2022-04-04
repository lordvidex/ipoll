//
//  PollDto.swift
//  iPoll
//
//  Created by Evans Owamoyo on 04.04.2022.
//

import Foundation

struct PollDto: Encodable {
    let title: String
    let options: [String]
    let hasTimeLimit: Bool
    let startTime: Date?
    let endTime: Date?
}
