//
//  String+.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation

extension String {
    func toDate(_ dateFormat: String = "yyyy-MM-dd HH:mm:ss.S") -> Date? {
        Formatter.dateFormatter.dateFormat = dateFormat
        return Formatter.dateFormatter.date(from: self)
    }
}
