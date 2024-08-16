//
//  SignUpQuery.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/15/24.
//

import Foundation

struct SignUpQuery: Encodable {
    let email: String
    let password: String
    let nick: String
//    var phoneNumber: String?
//    var birthDay: String?
}
