//
//  Comment.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import Foundation

struct Comment: Identifiable, Codable {
    let id: Int
    let postId: Int
    let authorId: Int
    let author: String
    let authorAvatar: String?
    let content: String
    let published: Date
    let likeOwnerIds: [Int]
    let likedByMe: Bool
}
