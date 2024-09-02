//
//  LikeModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/23/24.
//

import Foundation

struct LikeModel: Codable {
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}
