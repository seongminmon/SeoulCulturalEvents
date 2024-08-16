//
//  EditProfileQuery.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import Foundation

struct EditProfileQuery: Encodable {
    let nick: String?
    let phoneNum: String?
    let birthDay: String?
    let profile: Data?
}
