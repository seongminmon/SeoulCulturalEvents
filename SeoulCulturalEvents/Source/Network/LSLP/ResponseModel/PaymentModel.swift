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
    let id: String
    let content: String
    let createdAt: String
    let creator: UserModel
    
    enum CodingKeys: String, CodingKey {
        case id = "comment_id"
        case content, createdAt, creator
    }
}
