//
//  Date+.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation

extension Date {
    func toString(_ dateFormat: String = "yyyy-MM-dd") -> String {
        Formatter.dateFormatter.dateFormat = dateFormat
        return Formatter.dateFormatter.string(from: self)
    }
}
