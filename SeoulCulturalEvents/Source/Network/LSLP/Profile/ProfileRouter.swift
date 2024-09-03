//
//  ProfileRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Moya

enum ProfileRouter {
    // 내 프로필 조회
    case fetchMyProfile
    // 내 프로필 수정
    case editProfile(query: EditProfileQuery)
    // 다른 유저 프로필 조회
    case fetchProfile(userID: String)
    // 유저 검색
    case searchUser(nick: String)
}

extension ProfileRouter: TargetType {
    var path: String {
        switch self {
        case .fetchMyProfile:
            return "users/me/profile"
        case .editProfile:
            return "users/me/profile"
        case .fetchProfile(let id):
            return "users/\(id)/profile"
        case .searchUser:
            return "users/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchMyProfile:
            return .get
        case .editProfile:
            return .put
        case .fetchProfile:
            return .get
        case .searchUser:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchMyProfile:
            return .requestPlain
        case .editProfile(let query):
            var multipartData = [MultipartFormData]()
            
            // JSON 데이터를 개별 필드로 추가
            if let nick = query.nick, let data = nick.data(using: .utf8) {
                multipartData.append(MultipartFormData(provider: .data(data), name: "nick"))
            }
            if let nick = query.phoneNum, let data = nick.data(using: .utf8) {
                multipartData.append(MultipartFormData(provider: .data(data), name: "phoneNum"))
            }
            if let nick = query.birthDay, let data = nick.data(using: .utf8) {
                multipartData.append(MultipartFormData(provider: .data(data), name: "birthDay"))
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
            return .uploadMultipart(multipartData)
        case .fetchProfile:
            return .requestPlain
        case .searchUser(let id):
            let parameters: [String : Any] = [
                "nick": id
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchMyProfile:
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
        case .fetchProfile:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .searchUser:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        }
    }
}
