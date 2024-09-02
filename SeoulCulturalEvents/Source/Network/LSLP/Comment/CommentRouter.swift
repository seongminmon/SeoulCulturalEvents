//
//  CommentRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Moya

enum CommentRouter {
    // 댓글 작성
    case createComment(postID: String, query: CommentQuery)
    // 댓글 수정
    case editComment(postID: String, commentID: String, query: CommentQuery)
    // 댓글 삭제
    case deleteComment(postID: String, commentID: String)
}

extension CommentRouter: LSLPRouter {
    var path: String {
        switch self {
        case .createComment(let id, _):
            return "posts/\(id)/comments"
        case .editComment(let postID, let commentID, _):
            return "posts/\(postID)/comments/\(commentID)"
        case .deleteComment(let postID, let commentID):
            return "posts/\(postID)/comments/\(commentID)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createComment:
            return .post
        case .editComment:
            return .put
        case .deleteComment:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .createComment(_, let query):
            return .requestJSONEncodable(query)
        case .editComment(_, _, let query):
            return .requestJSONEncodable(query)
        case .deleteComment:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .createComment:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .editComment:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .deleteComment:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        }
    }
}
