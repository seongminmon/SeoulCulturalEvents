//
//  UserModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import Foundation

// 유저 검색
struct SearchUserModel: Decodable {
    let data: [UserModel]
}

struct UserModel: Decodable {
    let id: String
    let nick: String
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case nick, profileImage
    }
}
