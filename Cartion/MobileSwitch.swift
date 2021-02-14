//
//  MobileSwitch.swift
//  Cartion
//
//  Created by bellcon on 2021/01/14.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - MobileSwitch
struct MobileSwitch: Codable {
    let status: String
    let statusCode: Int
    let data: SwitchData
    let success: Bool
}

// MARK: - DataClass
struct SwitchData: Codable {
    let mobileSwitch: Int
    let hornList: [SwitchList]
}

// MARK: - HornList
struct SwitchList: Codable {
    let userId: String
    let hornType: String
    let hornId, hornName: String
    let categoryName: String
    let mobileSwitch, seq: Int
    let type: String

    init(userId: String, hornType: String, hornId: String, hornName: String, categoryName: String, mobileSwitch: Int, seq: Int, type: String) {
        self.userId = userId
        self.hornType = hornType
        self.hornId = hornId
        self.hornName = hornName
        self.categoryName = categoryName
        self.mobileSwitch = mobileSwitch
        self.seq = seq
        self.type = type
    }
}

struct PutSwitch: Codable {
    let userId: String
    let mobileSwitch, seq: Int
    
    init(userId: String, mobileSwitch: Int, seq: Int) {
        self.userId = userId
        self.mobileSwitch = mobileSwitch
        self.seq = seq
    }
}
