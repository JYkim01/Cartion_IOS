//
//  Category.swift
//  Cartion
//
//  Created by bellcon on 2021/01/07.
//  Copyright © 2021 belicon. All rights reserved.
//

import Foundation

// MARK: - Category
struct Category: Codable {
    let status: String
    let statusCode: Int
    let data: CategoryData
    let success: Bool
}

// MARK: - DataClass
struct CategoryData: Codable {
    let categoryList: [CategoryList]
}

// MARK: - CategoryList
struct CategoryList: Codable {
    let categoryId, categoryName: String

    init(categoryId: String, categoryName: String) {
        self.categoryId = categoryId
        self.categoryName = categoryName
    }
}
