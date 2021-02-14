//
//  Horn.swift
//  Cartion
//
//  Created by bellcon on 2021/01/05.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - Horn
struct Horn: Codable {
    let status: String
    let statusCode: Int
    let data: HornData
    let total: Int
    let success: Bool
}

// MARK: - HornData
struct HornData: Codable {
    let hornList: [HornList]
}

// MARK: - HornList
struct HornList: Codable {
    let hornId, hornName, categoryName, wavPath: String
    let adpcmPath: String
    
    public init(hornId: String, hornName: String, categoryName: String, wavPath: String, adpcmPath: String) {
        self.hornId = hornId
        self.hornName = hornName
        self.categoryName = categoryName
        self.wavPath = wavPath
        self.adpcmPath = adpcmPath
    }
}

struct LocalHorn {
    let hornId, hornName, categoryName: String
    
    init(hornId: String, hornName: String, categoryName: String) {
        self.hornId = hornId
        self.hornName = hornName
        self.categoryName = categoryName
    }
}
