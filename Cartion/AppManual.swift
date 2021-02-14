//
//  AppManual.swift
//  Cartion
//
//  Created by bellcon on 2021/01/11.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation


// MARK: - Category
struct AppManual: Codable {
    let status: String
    let statusCode: Int
    let data: ManualData
    let success: Bool
}

// MARK: - DataClass
struct ManualData: Codable {
    let appManualList: [AppManualList]
}

// MARK: - AppManualList
struct AppManualList: Codable {
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
