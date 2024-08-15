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
            provider.request(.cultures(parameter)) { result in
                switch result {
                case .success(let response):
                    if let data = try? response.map(CultureResponse.self) {
                        observer(.success(.success(data)))
                    } else {
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

// 사용 예시
//let parameter = CultureParameter(startDate: 1, endDate: 5, codeName: nil, title: nil, date: nil)
//CultureAPIManager.shared.callRequest(parameter)
//    .subscribe(with: self) { owner, result in
//        switch result {
//        case .success(let data):
//            dump(data)
//        case .failure(let error):
//            dump(error.localizedDescription)
//        }
//    }
//    .disposed(by: disposeBag)
