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
    var comments: [Comment]? = []
    let coords: Coordinates?
    let link: String?
}

extension Post {
    func updateLikes(
        likeOwnerIds: [Int]? = nil,
        likedByMe: Bool? = nil
    ) -> Post {
        return Post(
            id: id,
            authorId: authorId,
            author: author,
            authorAvatar: authorAvatar,
            content: content,
            published: published,
            likedByMe: likedByMe ?? self.likedByMe,
            likeOwnerIds: likeOwnerIds ?? self.likeOwnerIds,
            attachment: attachment,
            comments: comments,
            coords: coords,
            link: link
        )
    }
    
    func addComments(
        comments: [Comment]? = nil
    ) -> Post {
        return Post(
            id: id,
            authorId: authorId,
            author: author,
            authorAvatar: authorAvatar,
            content: content,
            published: published,
            likedByMe: likedByMe,
            likeOwnerIds: likeOwnerIds,
            attachment: attachment,
            comments: comments,
            coords: coords,
            link: link
        )
    }
}
