//
//  FollowRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Moya

enum FollowRouter {
    // 팔로우
    case follow(userID: String)
    // 팔로우 취소
    case cancelFollow(userID: String)
}

extension FollowRouter: TargetType {
    var path: String {
        switch self {
        case .follow(let id):
            return "follow/\(id)"
        case .cancelFollow(let id):
            return "follow/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .follow:
            return .post
        case .cancelFollow:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .follow:
            return .requestPlain
        case .cancelFollow:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .follow:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .cancelFollow:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        }
    }
}
