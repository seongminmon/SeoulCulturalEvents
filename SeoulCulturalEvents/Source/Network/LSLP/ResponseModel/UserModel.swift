//
//  UserModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import Foundation

// 유저 검색
struct SearchUserModel: Decodable {
    var data: [UserModel]
}

struct UserModel: Decodable {
    let id: String
    let nick: String
    let profileImage: String?
    
    var isFollow: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case nick, profileImage
    }
}
