//
//  SignUpModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/15/24.
//

import Foundation

// 회원가입 / 탈퇴
struct SignUpModel: Decodable {
    let id: String
    let email: String
    let nick: String
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email, nick
    }
}
