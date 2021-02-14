//
//  CustomHorn.swift
//  Cartion
//
//  Created by bellcon on 2021/01/07.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation


// MARK: - Horn
struct CustomHorn: Codable {
    let status: String
    let statusCode: Int
    let data: CustomHornData
    let success: Bool
}

// MARK: - HornData
struct CustomHornData: Codable {
    let hornList: [CustomHornList]
}

// MARK: - HornList
struct CustomHornList: Codable {
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
