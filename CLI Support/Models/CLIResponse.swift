//
//  CLIResponse.swift
//  Listr
//
//  Created by Guilherme Rambo on 01/03/20.
//  Copyright © 2020 Guilherme Rambo. All rights reserved.
//

#if DEBUG

import Foundation

enum CLIResponse: Hashable {
    case message(String)
    case data(Data)
}

extension CLIResponse {
    static let empty = CLIResponse.message("")
}

extension CLIResponse: Codable {

    private enum CodingKeys: String, CodingKey {
        case stringValue = "sv"
        case dataValue = "dv"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let data = try? container.decode(Data.self, forKey: .dataValue) {
            self = .data(data)
        } else if let str = try? container.decode(String.self, forKey: .stringValue) {
            self = .message(str)
        } else {
            let ctx = DecodingError.Context(codingPath: [], debugDescription: "Missing stringValue or dataValue.")
            throw DecodingError.dataCorrupted(ctx)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .data(let data):
            try container.encode(data, forKey: .dataValue)
        case .message(let str):
            try container.encode(str, forKey: .stringValue)
        }
    }

}

#endif
