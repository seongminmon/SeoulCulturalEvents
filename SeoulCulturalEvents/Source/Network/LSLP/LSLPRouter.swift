//
//  LSLPRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya

/*
 ✅: 구현 완료 ⭐️: 구현 필요 ❌: 사용 X
 
 - 회원인증
    [✅] 회원가입
    [❌] 이메일 중복 확인
    [✅] 로그인
    [✅] 엑세스 토큰 갱신
    [✅] 탈퇴
 
 - 포스트
    [✅] 포스트 이미지 업로드
    [✅] 포스트 작성
    [✅] 포스트 조회
    [✅] 특정 포스트 조회
    [⭐️] 포스트 수정
    [✅] 포스트 삭제
    [⭐️] 유저별 작성한 포스트 조회
 
    [❌] 해시태그 검색
 
 - 댓글
    [⭐️] 댓글 작성
    [⭐️] 댓글 수정
    [⭐️] 댓글 삭제
 
 - 좋아요
    [✅] 포스트 좋아요/좋아요 취소
    [⭐️] 좋아요한 포스트 조회
 
 - 팔로우
    [⭐️] 팔로우
    [⭐️] 팔로우 취소
 
 - 프로필
    [✅] 내 프로필 조회
    [✅] 내 프로필 수정
    [⭐️] 다른유저 프로필 조회
    [❌] 유저검색
 */

enum LSLPRouter {
    // MARK: - 유저
    case signIn(query: SignInQuery)
    case signUp(query: SignUpQuery)
    case refresh
    case withdraw
    case fetchProfile
    case editProfile(query: EditProfileQuery)
    
    // MARK: - 포스트
    case fetchPostList(query: PostFetchQuery)
    case fetchPost(postID: String)
    case postImageFiles(files: [Data])
    case createPost(query: PostQuery)
    case deletePost(postID: String)
    case postLike(postID: String, query: LikeModel)
}

extension LSLPRouter: TargetType {
    var baseURL: URL {
        return URL(string: APIURL.lslpURL + "v1/")!
    }
    
    var path: String {
        switch self {
        case .signIn:
            return "users/login"
        case .signUp:
            return "users/join"
        case .refresh:
            return "auth/refresh"
        case .withdraw:
            return "users/withdraw"
        case .fetchProfile:
            return "users/me/profile"
        case .editProfile:
            return "users/me/profile"
            
        case .fetchPostList:
            return "posts"
        case .fetchPost(let id):
            return "posts/\(id)"
        case .postImageFiles:
            return "posts/files"
        case .createPost:
            return "posts"
        case .deletePost(let id):
            return "posts/\(id)"
        case .postLike(let id, _):
            return "posts/\(id)/like"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        case .signUp:
            return .post
        case .refresh:
            return .get
        case .withdraw:
            return .get
        case .fetchProfile:
            return .get
        case .editProfile:
            return .put
            
        case .fetchPostList:
            return .get
        case .fetchPost:
            return .get
        case .postImageFiles:
            return .post
        case .createPost:
            return .post
        case .deletePost:
            return .delete
        case .postLike:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signIn(let query):
            return .requestJSONEncodable(query)
        case .signUp(let query):
            return .requestJSONEncodable(query)
        case .refresh:
            return .requestPlain
        case .withdraw:
            return .requestPlain
        case .fetchProfile:
            return .requestPlain
        case .editProfile(let query):
            var multipartData = [MultipartFormData]()
            
            // JSON 데이터를 개별 필드로 추가
            if let nick = query.nick {
                let nickFormData = MultipartFormData(provider: .data(nick.data(using: .utf8)!), name: "nick")
                multipartData.append(nickFormData)
            }
            if let phoneNum = query.phoneNum {
                let phoneNumFormData = MultipartFormData(provider: .data(phoneNum.data(using: .utf8)!), name: "phoneNum")
                multipartData.append(phoneNumFormData)
            }
            if let birthDay = query.birthDay {
                let birthDayFormData = MultipartFormData(provider: .data(birthDay.data(using: .utf8)!), name: "birthDay")
                multipartData.append(birthDayFormData)
            }
            
            // 프로필 이미지 추가
            if let profileData = query.profile {
                let profileFormData = MultipartFormData(
                    provider: .data(profileData),
                    name: "profile",
                    fileName: "profile.jpg",
                    mimeType: "image/jpeg"
                )
                multipartData.append(profileFormData)
            }
            
            return .uploadCompositeMultipart(multipartData, urlParameters: [:])
            
        case .fetchPostList(let query):
            let parameters: [String : Any] = [
                "next": query.next ?? "",
                "limit": query.limit,
                "product_id": query.productID ?? ""
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case .fetchPost:
            return .requestPlain
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
        case .deletePost:
            return .requestPlain
        case .postLike(_, let query):
            return .requestJSONEncodable(query)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signIn:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json
            ]
        case .signUp:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json
            ]
        case .refresh:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken,
                LSLPHeader.refresh: UserDefaultsManager.refreshToken
            ]
        case .withdraw:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .fetchProfile:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .editProfile:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.multipart,
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
        case .deletePost:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .postLike:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        }
    }
    
    // MARK: - retry 동작 위함
    var validationType: ValidationType {
        return .successCodes
    }
}
