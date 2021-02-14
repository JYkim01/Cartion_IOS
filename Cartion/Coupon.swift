//
//  Coupon.swift
//  Cartion
//
//  Created by bellcon on 2021/02/14.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - Coupon
struct Coupon: Codable {
    let status: String
    let statusCode: Int
    let data: CouponData
    let success: Bool
}

// MARK: - DataClass
struct CouponData: Codable {
    let couponList: [CouponList]
}

// MARK: - CouponList
struct CouponList: Codable {
    let userId, couponId, mobileSwitch, couponName: String
    let couponValue, couponText: String

    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case couponId = "couponId"
        case mobileSwitch, couponName, couponValue, couponText
    }
}
