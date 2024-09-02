//
//  CommentModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import Foundation

struct CommentModel: Decodable {
    let id: String
    let content: String
    let createdAt: String
    let creator: UserModel
    
    enum CodingKeys: String, CodingKey {
        case id = "comment_id"
        case content, createdAt, creator
    }
}
