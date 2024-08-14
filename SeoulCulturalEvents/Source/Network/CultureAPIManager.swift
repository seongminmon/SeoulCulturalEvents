//
//  CultureAPIManager.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation

struct CultureParameter {
    let startDate: Int
    let endDate: Int
    let codeName: CodeName?
    let title: String?
    let date: Date?
}

final class CultureAPIManager {
    
    static let shared = CultureAPIManager()
    private init() {}
    
    func callRequest(_ parameter: CultureParameter) {
        let startDate = "\(parameter.startDate)"
        let endDate = "\(parameter.endDate)"
        let codeName = "\(parameter.codeName?.rawValue ?? "%20")"
        let title = "\(parameter.title ?? "%20")"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = parameter.date != nil ? formatter.string(from: parameter.date!) : "%20"
        
        let url = URL(string: "\(APIURL.cultureURL)\(startDate)/\(endDate)/\(codeName)/\(title)/\(dateStr)")!
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
                let value = try? JSONDecoder().decode(CultureResponse.self, from: data) {
                dump(value)
            }
        }.resume()
    }
}
