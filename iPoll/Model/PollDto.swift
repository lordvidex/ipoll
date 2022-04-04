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
    let isAnonymous: Bool
    let startTime: Date?
    let endTime: Date?
    
    enum CodingKeys: String, CodingKey {
        case title, options, hasTime, startTime, endTime, anonymous
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(options, forKey: .options)
        try container.encode(hasTimeLimit, forKey: .hasTime)
        try container.encode(isAnonymous, forKey: .anonymous)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
    }
    
//    func toParams() -> [String: Any]
}
