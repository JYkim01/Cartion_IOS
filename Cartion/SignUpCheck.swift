//
//  SignUp.swift
//  Cartion
//
//  Created by bellcon on 2021/01/19.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - SignUp
struct SignUp: Codable {
    let status: String
    let statusCode: Int
    let data: JSONNull?
    let success: Bool
}

struct SignUpCheck: Codable {
    let status: String
    let statusCode: Int
    let data: SignUpData
    let success: Bool
}

// MARK: - DataClass
struct SignUpData: Codable {
    let isAvailable: Bool
}

// MARK: - Encode/decode helpers
class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
