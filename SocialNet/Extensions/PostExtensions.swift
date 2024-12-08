//
//  PostExtension.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//

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
            comments: comments
        )
    }
}
