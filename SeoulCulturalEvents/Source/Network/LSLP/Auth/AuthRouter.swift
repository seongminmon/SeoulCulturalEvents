//
//  AuthRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Moya

enum AuthRouter {
    // 회원가입
    case signUp(query: SignUpQuery)
    // 로그인
    case signIn(query: SignInQuery)
    // 엑세스 토큰 갱신
    case refresh
    // 탈퇴
    case withdraw
}

extension AuthRouter: TargetType {
    var path: String {
        switch self {
        case .signUp:
            return "users/join"
        case .signIn:
            return "users/login"
        case .refresh:
            return "auth/refresh"
        case .withdraw:
            return "users/withdraw"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signUp:
            return .post
        case .signIn:
            return .post
        case .refresh:
            return .get
        case .withdraw:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signUp(let query):
            return .requestJSONEncodable(query)
        case .signIn(let query):
            return .requestJSONEncodable(query)
        case .refresh:
            return .requestPlain
        case .withdraw:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signUp:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json
            ]
        case .signIn:
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
        }
    }
}
