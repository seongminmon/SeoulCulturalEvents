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
    func callRequest<T: Decodable>(api: LSLPRouter, model: T.Type) -> Single<Result<T, LSLPError>> {
        return Single<Result<T, LSLPError>>.create { observer in
            let provider = MoyaProvider<LSLPRouter>()
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
                    print("에러코드: \(error.response?.statusCode ?? -1)")
                    observer(.success(.failure(.unknown)))
                }
            }
            return Disposables.create()
        }
    }
    
    // 응답값 있는 경우
    func callRequestWithRetry<T: Decodable>(api: LSLPRouter, model: T.Type) -> Single<Result<T, LSLPError>> {
        return Single<Result<T, LSLPError>>.create { observer in
            let provider = MoyaProvider<LSLPRouter>(session: Session(interceptor: AuthInterceptor.shared))
            
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
                    print("에러코드: \(error.response?.statusCode ?? -1)")
                    observer(.success(.failure(.unknown)))
                }
            }
            return Disposables.create()
        }
    }
    
    // 응답값이 없는 경우(포스트 삭제)
    func callRequestWithRetry(api: LSLPRouter) -> Single<Result<Void, LSLPError>> {
        return Single<Result<Void, LSLPError>>.create { observer in
            let provider = MoyaProvider<LSLPRouter>(session: Session(interceptor: AuthInterceptor.shared))
            
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
                    print("에러코드: \(error.response?.statusCode ?? -1)")
                    observer(.success(.failure(.unknown)))
                }
            }
            return Disposables.create()
        }
    }
    
    // 엑세스 토큰 갱신
    func refresh(handler: @escaping (Result<RefreshModel, LSLPError>) -> Void) {
        let provider = MoyaProvider<LSLPRouter>()
        provider.request(.refresh) { result in
            switch result {
            case .success(let response):
                do {
                    print("엑세스 토큰 갱신 성공")
                    let data = try response.map(RefreshModel.self)
                    UserDefaultsManager.shared.refresh(data.accessToken)
                    handler(.success(data))
                } catch {
                    print("엑세스 토큰 갱신 디코딩 실패")
                    handler(.failure(.decoding))
                }
                
            case .failure(_):
                print("엑세스 토큰 갱신 실패")
                UserDefaultsManager.shared.removeAll()
                handler(.failure(.refreshToken))
            }
        }
    }
}

// MARK: - 엑세스 토큰 갱신
final class AuthInterceptor: RequestInterceptor {
    static let shared = AuthInterceptor()
    private init() {}
    
    // Request가 전송되기 전
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(APIURL.lslpURL) == true else {
            completion(.success(urlRequest))
            return
        }
        
        print("Adapt - 헤더 세팅")
        var urlRequest = urlRequest
        urlRequest.setValue(UserDefaultsManager.shared.accessToken, forHTTPHeaderField: LSLPHeader.authorization.rawValue)
        completion(.success(urlRequest))
    }
    
    // Request가 전송된 후
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == LSLPError.accessToken.rawValue else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        // 토큰 갱신 API 호출
        LSLPAPIManager.shared.refresh { result in
            switch result {
            case .success(_):
                print("Retry - 토큰 재발급 성공")
                completion(.retry)
            case .failure(let error):
                // 갱신 실패 -> 로그인 화면으로 전환
                print("Retry - 토큰 재발급 실패")
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
