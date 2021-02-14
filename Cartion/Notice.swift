//
//  Notice.swift
//  Cartion
//
//  Created by bellcon on 2021/01/20.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation


// MARK: - Notice
struct Notice: Codable {
    let status: String
    let statusCode: Int
    let data: NoticeData
    let success: Bool
}

// MARK: - DataClass
struct NoticeData: Codable {
    let noticeList: [NoticeList]
}

// MARK: - NoticeList
struct NoticeList: Codable {
    let noticeId: String?
    let title, body: String
    let pubStartDate, pubEndDate: String?

    init(noticeId: String, title: String, body: String, pubStartDate: String, pubEndDate: String) {
        self.noticeId = noticeId
        self.title = title
        self.body = body
        self.pubStartDate = pubStartDate
        self.pubEndDate = pubEndDate
    }
}
