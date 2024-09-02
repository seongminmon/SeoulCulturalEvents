//
//  AuthInterceptor.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Alamofire

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
        urlRequest.setValue(UserDefaultsManager.accessToken, forHTTPHeaderField: LSLPHeader.authorization)
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
                SceneDelegate.changeWindow(SignInViewController())
            }
        }
    }
}
