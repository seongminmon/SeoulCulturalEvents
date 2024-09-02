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

extension ProfileRouter: LSLPRouter {
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
