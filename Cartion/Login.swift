//
//  Login.swift
//  Cartion
//
//  Created by bellcon on 2020/10/22.
//  Copyright © 2020 belicon. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct Login: Codable {
    let status: String
    let statusCode: Int
    let data: LoginData
    let success: Bool
}

struct LoginAuth: Codable {
    let status: String
    let statusCode: Int
    let data: TokenData
    let success: Bool
}

// MARK: - DataClass
struct LoginData: Codable {
    let eulaYn: String
    let token: Token
}

struct TokenData: Codable {
    let token: Token
}

// MARK: - Token
struct Token: Codable {
    let accessToken, refreshToken: String
}
