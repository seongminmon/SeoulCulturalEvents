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

enum LSLPError: Error {
    case accessToken
    case refreshToken
    case decoding
    case unknown
}

final class LSLPAPIManager {
    static let shared = LSLPAPIManager()
    private init() {}
    
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
                    
                case .failure(_):
                    observer(.success(.failure(.unknown)))
                }
            }
            return Disposables.create()
        }
    }
    
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
                    
                case .failure(_):
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
                    UserDefaultsManager.shared.accessToken = data.accessToken
                    handler(.success(data))
                } catch {
                    print("엑세스 토큰 갱신 디코딩 실패")
                    handler(.failure(.decoding))
                }
                
            case .failure(_):
                print("엑세스 토큰 갱신 실패")
                UserDefaultsManager.shared.accessToken = ""
                UserDefaultsManager.shared.refreshToken = ""
                handler(.failure(.refreshToken))
            }
        }
    }
}

// MARK: - 엑세스 토큰 갱신
final class AuthInterceptor: RequestInterceptor {
    static let shared = AuthInterceptor()
    private init() {}
    
    // TODO: - 계속 토큰 재발급하는 문제 해결하기
    
    // Request가 전송되기 전
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(APIURL.lslpURL) == true,
              UserDefaultsManager.shared.accessToken != "",
              UserDefaultsManager.shared.refreshToken != ""
        else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(UserDefaultsManager.shared.accessToken, forHTTPHeaderField: LSLPHeader.authorization.rawValue)
        
        print("adator")
        completion(.success(urlRequest))
    }
    
    // Request가 전송된 후
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("retry 진입")
        guard let response = request.task?.response as? HTTPURLResponse,
                response.statusCode == 419 else {
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
                print("Retry - 토큰 재발급 실패")
                // 갱신 실패 -> 로그인 화면으로 전환
//                SceneDelegate.changeWindow(SignInViewController())
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
