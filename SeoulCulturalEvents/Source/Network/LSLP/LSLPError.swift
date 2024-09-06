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
    case decoding = -1
    case unknown = -2
    
    // 회원 가입
    case emptyRequired = 400
    case whiteSpace = 402
    case duplicated = 409
    
    // 로그인
    case invalid = 401
    
    // 엑세스 토큰 갱신
    case forbidden = 403
    case refreshToken = 418
    
    // 탈퇴
    case accessToken = 419
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
        case .decoding:
            return "디코딩 에러"
        case .accessToken:
            return "엑세스 토큰이 만료되었습니다."
        case .refreshToken:
            return "리프레시 토큰이 만료되었습니다.\n다시 로그인 해주세요."
        case .unknown:
            return "알 수 없는 에러"
        case .emptyRequired:
            return "필수값을 채워주세요."
        case .whiteSpace:
            return "공백이 포함된 닉네임은 사용할 수 없습니다."
        case .duplicated:
            return "이미 가입된 유저입니다."
        case .invalid:
            return "인증할 수 없습니다."
        case .forbidden:
            return "접근 권한이 없습니다."
        }
    }
}

//// 내 프로필 조회
//    case invalidAccessToken = 401
//    case forbidden = 403
//    case accessToken = 419
