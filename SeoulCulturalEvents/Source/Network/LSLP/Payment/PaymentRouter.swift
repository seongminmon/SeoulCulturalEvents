//
//  PaymentRouter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 9/2/24.
//

import Foundation
import Moya

enum PaymentRouter {
    // 결제 영수증 검증
    case paymentsValidation(query: PaymentQuery)
    // 결제 내역 리스트
    case fetchPayments
}

extension PaymentRouter: TargetType {
    var path: String {
        switch self {
        case .paymentsValidation:
            return "payments/validation"
        case .fetchPayments:
            return "payments/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .paymentsValidation:
            return .post
        case .fetchPayments:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .paymentsValidation(let query):
            return .requestJSONEncodable(query)
        case .fetchPayments:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .paymentsValidation:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        case .fetchPayments:
            return [
                LSLPHeader.sesacKey: APIKey.lslpKey,
                LSLPHeader.contentType: LSLPHeader.json,
                LSLPHeader.authorization: UserDefaultsManager.accessToken
            ]
        }
    }
}
