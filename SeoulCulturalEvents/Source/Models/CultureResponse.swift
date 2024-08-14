//
//  CultureResponse.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/14/24.
//

import Foundation

struct CultureResponse: Decodable {
    let culturalEventInfo: CulturalEventInfo
}

struct CulturalEventInfo: Decodable {
    let totalCount: Int
    var list: [CulturalEvent]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "list_total_count"
        case list = "row"
    }
}

struct CulturalEvent: Decodable {
    let mainImage: String
    let title: String
    let codeName: String
    
    let startDate: String
    let endDate: String
    
    let place: String
    let organizationName: String
    let guName: String
    let longitude: String
    let latitude: String
    
    let price: String
    let isFree: String
    let useTarget: String
    
    let link: String
    
    enum CodingKeys: String, CodingKey {
        case mainImage = "MAIN_IMG"
        case title = "TITLE"
        case codeName = "CODENAME"
        case startDate = "STRTDATE"
        case endDate = "END_DATE"
        case place = "PLACE"
        case organizationName = "ORG_NAME"
        case guName = "GUNAME"
        case longitude = "LOT"
        case latitude = "LAT"
        case price = "USE_FEE"
        case isFree = "IS_FREE"
        case useTarget = "USE_TRGT"
        case link = "ORG_LINK"
    }
}