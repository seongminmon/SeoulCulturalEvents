//
//  EditProfileQuery.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/16/24.
//

import Foundation

struct EditProfileQuery: Encodable {
    var nick: String?
    var phoneNum: String?
    var birthDay: String?
    var profile: Data?
}
