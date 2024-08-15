//
//  LSLPRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya

enum LSLPRouter {
    case signIn(query: SignInQuery)
//    case fetchProfile
//    case editProfile
//    case refresh
}

extension LSLPRouter: TargetType {
    var baseURL: URL {
        return URL(string: APIURL.lslpURL + "v1")!
    }
    
    var path: String {
        switch self {
        case .signIn:
            return "/users/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .signIn:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .signIn(let query):
            return .requestJSONEncodable(query)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signIn:
            return [
                LSLPHeader.contentType.rawValue: LSLPHeader.json.rawValue,
                LSLPHeader.sesacKey.rawValue: APIKey.lslpKey
            ]
        }
    }
}
