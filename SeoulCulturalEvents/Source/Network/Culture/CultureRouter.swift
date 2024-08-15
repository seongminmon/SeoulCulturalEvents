//
//  CultureRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya

struct CultureParameter {
    let startDate: Int
    let endDate: Int
    let codeName: CodeName?
    let title: String?
    let date: Date?
}

enum CultureRouter {
    case cultures(_ parameter: CultureParameter)
}

extension CultureRouter: TargetType {
    var baseURL: URL {
        return URL(string: APIURL.cultureURL)!
    }
    
    var path: String {
        switch self {
        case .cultures(let parameter):
            let startDate = "\(parameter.startDate)"
            let endDate = "\(parameter.endDate)"
            let codeName = "\(parameter.codeName?.rawValue ?? "%20")"
            let title = "\(parameter.title ?? "%20")"
            let dateStr = parameter.date?.toString() ?? "%20"
            return "\(startDate)/\(endDate)/\(codeName)/\(title)/\(dateStr)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .cultures:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .cultures:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .cultures:
            return nil
        }
    }
}
