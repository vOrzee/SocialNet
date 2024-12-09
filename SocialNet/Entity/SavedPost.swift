//
//  SavedPost.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

import Foundation
import SwiftData

@Model
class SavedPost: Identifiable {
    @Attribute(.unique) var id: Int
    var authorId: Int
    var author: String
    var authorAvatar: String?
    var content: String
    var published: Date
    var likedByMe: Bool
    var likeOwnerIds: [Int]
    var attachment: Attachment?
    var comments: [Comment]?

    init(
        id: Int,
        authorId: Int,
        author: String,
        authorAvatar: String? = nil,
        content: String,
        published: Date,
        likedByMe: Bool,
        likeOwnerIds: [Int],
        attachment: Attachment? = nil,
        comments: [Comment]? = nil
    ) {
        self.id = id
        self.authorId = authorId
        self.author = author
        self.authorAvatar = authorAvatar
        self.content = content
        self.published = published
        self.likedByMe = likedByMe
        self.likeOwnerIds = likeOwnerIds
        self.attachment = attachment
        self.comments = comments
    }
}

