//
//  PaymentModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/1/24.
//

import Foundation

// 결제 내역 리스트
struct PaymentList: Decodable {
    let data: [PaymentModel]
}

// 결제 영수증 검증
struct PaymentModel: Decodable {
    let buyerID: String
    let postID: String
    let merchantUID: String
    let productName: String
    let price: Int
    let paidAt: String
    
    enum CodingKeys: String, CodingKey {
        case buyerID = "buyer_id"
        case postID = "post_id"
        case merchantUID = "merchant_uid"
        case productName, price, paidAt
    }
}
