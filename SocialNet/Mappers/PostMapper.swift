//
//  PostMapper.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

extension SavedPost {
    static func from(post: Post) -> SavedPost {
        return SavedPost(
            id: post.id,
            authorId: post.authorId,
            author: post.author,
            authorAvatar: post.authorAvatar,
            content: post.content,
            published: post.published,
            likedByMe: post.likedByMe,
            likeOwnerIds: post.likeOwnerIds,
            attachment: post.attachment,
            comments: post.comments
        )
    }
}
