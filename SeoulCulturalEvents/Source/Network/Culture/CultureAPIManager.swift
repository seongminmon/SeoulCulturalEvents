//
//  CultureAPIManager.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya
import RxMoya
import RxSwift

final class CultureAPIManager {
    static let shared = CultureAPIManager()
    private init() {}
    
    func callRequest(_ parameter: CultureParameter) -> Single<Result<CultureResponse, MoyaError>> {
        return Single<Result<CultureResponse, MoyaError>>.create { observer in
            let provider = MoyaProvider<CultureRouter>()
            provider.request(.fetchCulturalEvents(parameter)) { result in
                switch result {
                case .success(let response):
                    do {
                        let data = try response.map(CultureResponse.self)
                        observer(.success(.success(data)))
                    } catch {
                        observer(.success(.failure(.jsonMapping(response))))
                    }
                    
                case .failure(let error):
                    observer(.success(.failure(error)))
                }
            }
            return Disposables.create()
        }
    }
}
