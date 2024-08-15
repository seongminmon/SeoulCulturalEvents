//
//  LSLPAPIManager.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Moya
import RxSwift

final class LSLPAPIManager {
    static let shared = LSLPAPIManager()
    private init() {}
    
    func callRequest<T: Decodable>(api: LSLPRouter, model: T.Type) -> Single<Result<T, MoyaError>> {
        return Single<Result<T, MoyaError>>.create { observer in
            let provider = MoyaProvider<LSLPRouter>()
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    do {
                        let data = try response.map(T.self)
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
