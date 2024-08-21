//
//  LSLPError.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/20/24.
//

import Foundation

enum LSLPError: Int, Error {
    // 공통 응답코드
    case invalidKey = 420
    case overcall = 429
    case invalidURL = 444
    case serverError = 500
    
    // 회원가입
    case emptyRequired = 400
    case whiteSpace = 402
    case duplicated = 409
    
    // 로그인
//    case emptyRequired = 400
    case invalidPassword = 401
    
    // 엑세스 토큰 갱신
//    case invalidAccessToken = 401
    case forbidden = 403
    case refreshToken = 418
    
    // 탈퇴
//    case invalidAccessToken = 401
//    case forbidden = 403
    case accessToken = 419
    
    // 내 프로필 조회
//    case invalidAccessToken = 401
//    case forbidden = 403
//    case accessToken = 419
    
    case decoding = -2
    case unknown = -1
}

extension LSLPError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "잘못된 APIKey입니다."
        case .overcall:
            return "과호출입니다."
        case .invalidURL:
            return "잘못된 URL입니다."
        case .serverError:
            return "서버 에러"
        case .forbidden:
            return "접근 권한이 없습니다."
        case .refreshToken:
            return "리프레시 토큰이 만료되었습니다."
        case .accessToken:
            return "엑세스 토큰이 만료되었습니다."
        default:
            return "알 수 없는 에러!"
        }
    }
}