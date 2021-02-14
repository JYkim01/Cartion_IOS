//
//  FAQ.swift
//  Cartion
//
//  Created by bellcon on 2021/01/20.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - FAQ
struct FAQ: Codable {
    let status: String
    let statusCode: Int
    let data: FAQData
    let success: Bool
}

// MARK: - DataClass
struct FAQData: Codable {
    let faqList: [FAQList]
}

// MARK: - FAQList
struct FAQList: Codable {
    let faqID: JSONNull?
    let title, body: String
    
    enum CodingKeys: String, CodingKey {
        case faqID = "faqId"
        case title, body
    }
}
