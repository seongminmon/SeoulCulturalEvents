//
//  SignInModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/15/24.
//

import Foundation

// 로그인
struct SignInModel: Decodable {
    let id: String
    let email: String
    let nick: String
    let profile: String?
    let access: String
    let refresh: String
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email, nick
        case profile = "profileImage"
        case access = "accessToken"
        case refresh = "refreshToken"
    }
}
