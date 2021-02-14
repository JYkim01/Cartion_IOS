//
//  UserInfo.swift
//  Cartion
//
//  Created by bellcon on 2021/01/15.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - UserInfo
struct UserInfo: Codable {
    let status: String
    let statusCode: Int
    let data: UserServerData
    let success: Bool
}

// MARK: - DataClass
struct UserServerData: Codable {
    let phoneNumber: String
    let devices: [Device]
    let userId: String

    enum CodingKeys: String, CodingKey {
        case phoneNumber, devices
        case userId = "userId"
    }
}

// MARK: - Device
struct Device: Codable {
    let deviceId, deviceMac, userId, deviceName: String
    let useYn, registerTime, modifyTime: String

    init(deviceId: String, deviceMac: String, userId: String, deviceName: String, useYn: String, registerTime: String, modifyTime: String) {
        self.deviceId = deviceId
        self.deviceMac = deviceMac
        self.userId = userId
        self.deviceName = deviceName
        self.useYn = useYn
        self.registerTime = registerTime
        self.modifyTime = modifyTime
    }
}
