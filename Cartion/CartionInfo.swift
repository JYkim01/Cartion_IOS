//
//  CartionInfo.swift
//  Cartion
//
//  Created by bellcon on 2021/01/11.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - CartionInfo
struct CartionInfo: Codable {
    let status: String
    let statusCode: Int
    let data: InfoData
    let success: Bool
}

// MARK: - DataClass
struct InfoData: Codable {
    let useAppList: [UseAppList]
}

// MARK: - UseAppList
struct UseAppList: Codable {
    let imageGroup, imageName: String
    let imageUrl: String
    let linkUrl, seq, registerTime, modifyTime: String
    
    init(imageGroup: String, imageName: String, imageUrl: String, linkUrl: String, seq: String, registerTime: String, modifyTime: String) {
        self.imageGroup = imageGroup
        self.imageName = imageName
        self.imageUrl = imageUrl
        self.linkUrl = linkUrl
        self.seq = seq
        self.registerTime = registerTime
        self.modifyTime = modifyTime
    }
}
