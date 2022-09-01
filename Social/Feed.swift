//
//  Feed.swift
//  Social
//
//  Created by Yongwoo Yoo on 2022/05/18.
//

import Foundation

struct Feed : Codable {
    let id: Int
    let detail: String
    let cardImageURL: String
    let comment: Comment
    var likeCount: Int
    var isLike: Bool?
    var commentCount: Int
}

struct Comment : Codable {
    let id: Int
    let name: String
    let content: String
}

