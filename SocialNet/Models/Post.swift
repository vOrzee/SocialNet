//
//  Post.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: Int
    let authorId: Int
    let author: String
    let authorAvatar: String?
    let content: String
    let published: Date
    let likedByMe: Bool
    let likeOwnerIds: [Int]
    let attachment: Attachment?
    var comments: [Comment]? = [] // Добавляем комментарии
}
