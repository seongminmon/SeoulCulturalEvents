//
//  ProfileModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import Foundation

// 내 프로필 조회 / 내 프로필 수정
struct ProfileModel: Decodable {
    let id: String
    let email: String
    let nick: String
    
    let phoneNum: String?
    let birthDay: String?
    let profileImage: String?
    
    let followers: [UserModel]
    let following: [UserModel]
    let posts: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email, nick, phoneNum, birthDay, profileImage, followers, following, posts
    }
}
