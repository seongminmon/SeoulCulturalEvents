//
//  PostQuery.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import Foundation

struct PostQuery: Encodable {
    let title: String?
    let content: String?
    let content1: String?
    let content2: String?
    let content3: String?
    let content4: String?
    let content5: String?
    let productID: String?
    let files: [String]
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case title, content, content1, content2, content3, content4, content5, files
    }
}

enum ProductID {
    static let cultural = "ksm_culturalEvent"
    static let post = "ksm_post"
}
