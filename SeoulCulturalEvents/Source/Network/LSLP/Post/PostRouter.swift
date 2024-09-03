//
//  PostRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Moya

enum PostRouter {
    // 포스트 이미지 업로드
    case postImageFiles(files: [Data])
    // 포스트 작성
    case createPost(query: PostQuery)
    // 포스트 조회
    case fetchPostList(query: PostFetchQuery)
    // 특정 포스트 조회
    case fetchPost(postID: String)
    // 포스트 수정
    case editPost(postID: String, query: PostQuery)
    // 포스트 삭제
    case deletePost(postID: String)
    // 유저별 작성한 포스트 조회
    case fetchUserPostList(userID: String, query: PostFetchQuery)
}

extension PostRouter: TargetType {
    var path: String {
        switch self {
        case .postImageFiles:
            return "posts/files"
        case .createPost:
            return "posts"
        case .fetchPostList:
            return "posts"
        case .fetchPost(let id):
            return "posts/\(id)"
        case .editPost(let id, _):
            return "posts/\(id)"
        case .deletePost(let id):
            return "posts/\(id)"
        case .fetchUserPostList(let id, _):
            return "posts/users/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postImageFiles:
            return .post
        case .createPost:
            return .post
        case .fetchPostList:
            return .get
        case .fetchPost:
            return .get
        case .editPost:
            return .put
        case .deletePost:
            return .delete
        case .fetchUserPostList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .postImageFiles(let files):
            let multipartFormData: [MultipartFormData] = files.enumerated().map { index, data in
                MultipartFormData(
                    provider: .data(data),
                    name: "files",
                    fileName: "files\(index).jpg",
                    mimeType: "image/jpeg"
                )
            }
            return .uploadMultipart(multipartFormData)
        case .createPost(let query):
            return .requestJSONEncodable(query)
        case .fetchPostList(let query):
            let parameters: [String : Any] = [
                "next": query.next ?? "",
                "limit": query.limit,
                "product_id": query.productID ?? ""
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .fetchPost:
            return .requestPlain
        case .editPost(_, let query):
            return .requestJSONEncodable(query)
        case .deletePost:
            return .requestPlain
        case .fetchUserPostList(_, let query):
            let parameters: [String : Any] = [
                "next": query.next ?? "",
                "limit": query.limit,
                "product_id": query.productID ?? ""
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postImageFiles:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.multipart,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .createPost:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .fetchPostList:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .fetchPost:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .editPost:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .deletePost:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .fetchUserPostList:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        }
    }
}
