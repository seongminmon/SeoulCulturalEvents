//
//  TargetType+.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/3/24.
//

import Foundation
import Moya

extension TargetType {
    var baseURL: URL {
        return URL(string: APIURL.lslpURL + "v1/")!
    }
    
    // MARK: - retry 동작 위함
    var validationType: ValidationType {
        return .successCodes
    }
}
