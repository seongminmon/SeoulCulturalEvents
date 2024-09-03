//
//  LikeRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Moya

enum LikeRouter {
    // 포스트 좋아요 / 좋아요 취소
    case postLike(postID: String, query: LikeModel)
    // 좋아요한 포스트 조회
    case fetchLikePostList(query: PostFetchQuery)
}

extension LikeRouter: TargetType {
    var path: String {
        switch self {
        case .postLike(let id, _):
            return "posts/\(id)/like"
        case .fetchLikePostList:
            return "posts/likes/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postLike:
            return .post
        case .fetchLikePostList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postLike(_, let query):
            return .requestJSONEncodable(query)
        case .fetchLikePostList(let query):
            let parameters: [String : Any] = [
                "next": query.next ?? "",
                "limit": query.limit
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postLike:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .fetchLikePostList:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        }
    }
}
