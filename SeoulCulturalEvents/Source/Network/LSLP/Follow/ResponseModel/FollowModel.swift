//
//  FollowModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/26/24.
//

import Foundation

struct FollowModel: Decodable {
    let nick: String
    let opponentNick: String
    let followingStatus: Bool
    
    enum CodingKeys: String, CodingKey {
        case nick
        case opponentNick = "opponent_nick"
        case followingStatus = "following_status"
    }
}
