//
//  PaymentQuery.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/1/24.
//

import Foundation

struct PaymentQuery: Encodable {
    let impUID: String
    let postID: String
    
    enum CodingKeys: String, CodingKey {
        case impUID = "imp_uid"
        case postID = "post_id"
    }
}
