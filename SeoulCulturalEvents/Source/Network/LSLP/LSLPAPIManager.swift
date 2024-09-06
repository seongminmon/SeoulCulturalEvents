//
//  LSLPAPIManager.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Alamofire
import Moya
import RxSwift

final class LSLPAPIManager {
    static let shared = LSLPAPIManager()
    private init() {}
    
    // 토큰 갱신 필요없는 경우(로그인, 회원가입)
    func callRequest<Router: TargetType, T: Decodable>(
        api: Router,
        model: T.Type
    ) -> Single<Result<T, LSLPError>> {
        return Single<Result<T, LSLPError>>.create { observer in
            let provider = MoyaProvider<Router>()
            provider.request(api) { result in
                
                switch result {
                case .success(let response):
                    print("상태코드: \(response.statusCode)")
                    
                    do {
                        let data = try response.map(T.self)
                        observer(.success(.success(data)))
                    } catch {
                        observer(.success(.failure(.decoding)))
                    }
                    
                case .failure(let error):
                    let statusCode = error.response?.statusCode ?? -1
                    print("에러코드: \(statusCode)")
                    let lslpError = LSLPError(rawValue: statusCode) ?? .unknown
                    observer(.success(.failure(lslpError)))
                }
            }
            return Disposables.create()
        }
    }
    
    // 응답값 있는 경우
    func callRequestWithRetry<Router: TargetType, T: Decodable>(
        api: Router,
        model: T.Type
    ) -> Single<Result<T, LSLPError>> {
        return Single<Result<T, LSLPError>>.create { observer in
            let provider = MoyaProvider<Router>(session: Session(interceptor: AuthInterceptor.shared))
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    print("상태코드: \(response.statusCode)")
                    
                    do {
                        let data = try response.map(T.self)
                        observer(.success(.success(data)))
                    } catch {
                        observer(.success(.failure(.decoding)))
                    }
                    
                case .failure(let error):
                    let statusCode = error.response?.statusCode ?? -1
                    print("에러코드: \(statusCode)")
                    let lslpError = LSLPError(rawValue: statusCode) ?? .unknown
                    observer(.success(.failure(lslpError)))
                }
            }
            return Disposables.create()
        }
    }
    
    // 응답값이 없는 경우(포스트 삭제, 댓글 삭제)
    func callRequestWithRetry<Router: TargetType>(
        api: Router
    ) -> Single<Result<Void, LSLPError>> {
        return Single<Result<Void, LSLPError>>.create { observer in
            let provider = MoyaProvider<Router>(session: Session(interceptor: AuthInterceptor.shared))
            provider.request(api) { result in
                switch result {
                case .success(let response):
                    print("상태코드: \(response.statusCode)")
                    if response.statusCode == 200 {
                        observer(.success(.success(())))
                    } else {
                        observer(.success(.failure(.unknown)))
                    }
                    
                case .failure(let error):
                    let statusCode = error.response?.statusCode ?? -1
                    print("에러코드: \(statusCode)")
                    let lslpError = LSLPError(rawValue: statusCode) ?? .unknown
                    observer(.success(.failure(lslpError)))
                }
            }
            return Disposables.create()
        }
    }
    
    // 엑세스 토큰 갱신
    func refresh(handler: @escaping (Result<RefreshModel, LSLPError>) -> Void) {
        let provider = MoyaProvider<AuthRouter>()
        provider.request(.refresh) { result in
            switch result {
            case .success(let response):
                do {
                    print("엑세스 토큰 갱신 성공")
                    let data = try response.map(RefreshModel.self)
                    UserDefaultsManager.refresh(data.accessToken)
                    handler(.success(data))
                } catch {
                    print("엑세스 토큰 갱신 디코딩 실패")
                    handler(.failure(.decoding))
                }
                
            case .failure(let error):
                print("엑세스 토큰 갱신 실패")
                let statusCode = error.response?.statusCode ?? -1
                print("에러코드: \(statusCode)")
                let lslpError = LSLPError(rawValue: statusCode) ?? .unknown
                UserDefaultsManager.removeAll()
                handler(.failure(lslpError))
            }
        }
    }
}
