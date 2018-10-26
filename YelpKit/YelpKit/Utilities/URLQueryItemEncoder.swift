//
//  URLQueryItemEncoder.swift
//
//  Created by Kasey Schindler on 10/23/18.
//  Copyright © 2018 Curiously Creative, LLC. All rights reserved.
//

import Foundation

/// Encodes any encodable to a URLQueryItem list
struct URLQueryItemEncoder {
    static func encode<T: Encodable>(_ encodable: T) throws -> [URLQueryItem] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(encodable)
        let parameters = try JSONDecoder().decode([String : HTTPParameter].self, from: data)
        
        return parameters.map { URLQueryItem(name: $0, value: $1.description) }
    }
}
