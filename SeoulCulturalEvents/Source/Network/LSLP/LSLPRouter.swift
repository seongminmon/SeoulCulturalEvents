//
//  LSLPRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya

protocol LSLPRouter: TargetType {}

extension LSLPRouter {
    var baseURL: URL {
        return URL(string: APIURL.lslpURL + "v1/")!
    }
    
    // MARK: - retry 동작 위함
    var validationType: ValidationType {
        return .successCodes
    }
}
