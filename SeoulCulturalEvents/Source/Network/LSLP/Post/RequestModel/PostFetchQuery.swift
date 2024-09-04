//
//  PostFetchQuery.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/20/24.
//

import Foundation

struct PostFetchQuery {
    var next: String?
    let limit: String = "10"
    var productID: String?
    
    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case next, limit
    }
}
