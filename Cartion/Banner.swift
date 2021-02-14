//
//  Banner.swift
//  Cartion
//
//  Created by bellcon on 2021/01/04.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - Banner
struct Banner: Codable {
    let status: String
    let statusCode: Int
    let data: BannerData
    let success: Bool
}

// MARK: - DataClass
struct BannerData: Codable {
    let bannerList: [BannerList]
}

// MARK: - BannerList
struct BannerList: Codable {
    let imageGroup, imageName: String
    let imageURL: String
    let linkURL: String
    let seq, registerTime, modifyTime: String

    enum CodingKeys: String, CodingKey {
        case imageGroup, imageName
        case imageURL = "imageUrl"
        case linkURL = "linkUrl"
        case seq, registerTime, modifyTime
    }
}
