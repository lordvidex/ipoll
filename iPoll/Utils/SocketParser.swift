//
//  SocketParser.swift
//  iPoll
//
//  Created by Evans Owamoyo on 21.03.2022.
//

import Foundation

struct SocketParser {
    static func convert<T: Decodable>(data: Any) throws -> T {
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        return try decoder.decode(T.self, from: jsonData)
    }
}
