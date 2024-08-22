//
//  PostModel.swift
//  SeoulCulturalEvents
//
//  Created by 김성민 on 8/19/24.
//

import Foundation

// 포스트 작성 / 포스트 조회 / 특정 포스트 조회
struct PostModelList: Decodable {
    var data: [PostModel]
}

struct PostModel: Decodable {
    let postID: String
    let productID: String?
    let title: String?
    let content: String?
    let content1: String?
    let content2: String?
    let content3: String?
    let content4: String?
    let content5: String?
    let price: Int?
    
    let createdAt: String
    let creator: UserModel
    let files: [String]
    let likes: [String]
    let likes2: [String]
    let hashTags: [String]
    let comments: [CommentModel]
    
    enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case productID = "product_id"
        case title, content, content1, content2, content3, content4, content5, files, price
        case createdAt, creator, likes, likes2, hashTags, comments
    }
}
