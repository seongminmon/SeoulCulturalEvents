//
//  Formatter.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation
import Then

enum Formatter {
    static let dateFormatter = DateFormatter().then {
        $0.locale = Locale(identifier: "ko_KR")
        $0.timeZone = TimeZone(identifier: "KST")
    }
    
    static let isoDateFormatter = ISO8601DateFormatter().then {
        $0.timeZone = TimeZone(secondsFromGMT: 0)
    }
}
