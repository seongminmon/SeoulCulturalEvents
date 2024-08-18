//
//  LSLPRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya

enum LSLPRouter {
    // MARK: - 유저
    case signIn(query: SignInQuery)
    case signUp(query: SignUpQuery)
    case refresh
    case withdraw
    case fetchProfile
    case editProfile(query: EditProfileQuery)
    
    // MARK: - 포스트
    
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
                let uniqueFileName = UUID().uuidString + ".png"
                let profileFormData = MultipartFormData(provider: .data(profileData), name: "profile", fileName: uniqueFileName, mimeType: "image/png")
                multipartData.append(profileFormData)
            }
            
            return .uploadCompositeMultipart(multipartData, urlParameters: [:])
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signIn:
            return [
                LSLPHeader.sesacKey.rawValue: APIKey.lslpKey,
                LSLPHeader.contentType.rawValue: LSLPHeader.json.rawValue
            ]
        case .signUp:
            return [
                LSLPHeader.sesacKey.rawValue: APIKey.lslpKey,
                LSLPHeader.contentType.rawValue: LSLPHeader.json.rawValue
            ]
        case .refresh:
            return [
                LSLPHeader.sesacKey.rawValue: APIKey.lslpKey,
                LSLPHeader.contentType.rawValue: LSLPHeader.json.rawValue,
                LSLPHeader.authorization.rawValue: UserDefaultsManager.shared.accessToken,
                LSLPHeader.refresh.rawValue: UserDefaultsManager.shared.refreshToken
            ]
        case .withdraw:
            return [
                LSLPHeader.sesacKey.rawValue: APIKey.lslpKey,
                LSLPHeader.contentType.rawValue: LSLPHeader.json.rawValue,
                LSLPHeader.authorization.rawValue: UserDefaultsManager.shared.accessToken
            ]
        case .fetchProfile:
            return [
                LSLPHeader.sesacKey.rawValue: APIKey.lslpKey,
                LSLPHeader.contentType.rawValue: LSLPHeader.json.rawValue,
                LSLPHeader.authorization.rawValue: UserDefaultsManager.shared.accessToken
            ]
        case .editProfile:
            return [
                LSLPHeader.sesacKey.rawValue: APIKey.lslpKey,
                LSLPHeader.contentType.rawValue: LSLPHeader.multipart.rawValue,
                LSLPHeader.authorization.rawValue: UserDefaultsManager.shared.accessToken
            ]
        }
    }
    
    // MARK: - retry 동작 위함
    var validationType: ValidationType {
        return .successCodes
    }
}
