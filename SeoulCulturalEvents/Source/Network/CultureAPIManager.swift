//
//  CultureAPIManager.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya

final class CultureAPIManager {
    static let shared = CultureAPIManager()
    private init() {}
    
    func callRequest(_ parameter: CultureParameter) {
        let provider = MoyaProvider<CultureRouter>()
        provider.request(.cultures(parameter)) { result in
            switch result {
            case .success(let response):
                let data = try? response.map(CultureResponse.self)
                dump(data)
            case .failure(let error):
                print(error)
            }
        }
    }
}
