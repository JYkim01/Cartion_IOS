//
//  Change.swift
//  Cartion
//
//  Created by bellcon on 2021/01/20.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation


// MARK: - Change
struct SwitchChange: Codable {
    let status: String
    let statusCode: Int
    let data: SwitchNull?
    let success: Bool
}

class SwitchNull: Codable, Hashable {

    public static func == (lhs: SwitchNull, rhs: SwitchNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(SwitchNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SwitchNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
