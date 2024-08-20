//
//  PostQuery.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import Foundation

struct PostQuery: Encodable {
    let title: String?
    let productID: String?
    let content: String?
    var content1: String?
    var content2: String?
    var content3: String?
    var content4: String?
    var content5: String?
    var price: Int?
    let files: [String]
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case title, content, content1, content2, content3, content4, content5, price, files
    }
}
