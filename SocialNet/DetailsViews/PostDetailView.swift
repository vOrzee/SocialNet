//
//  PostDetailView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post // Пост, переданный из списка

    var body: some View {
        VStack {
            PostRowView(
                post: post,
                onMenuTapped: nil,
                onLikeTapped: nil,
                onCommentTapped: nil,
                onBookmarkTapped: nil
            )
                .padding(.bottom)

            List(post.comments ?? []) { comment in
                CommentRowView(comment: comment)
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Post Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PostDetailView(post: Post(
        id: 1,
        authorId: 1,
        author: "John Doe",
        authorAvatar: "https://via.placeholder.com/40",
        content: "This is a detailed view of the post.",
        published: Date(),
        likedByMe: false,
        likeOwnerIds: [1, 2],
        attachment: Attachment(
            url: "https://via.placeholder.com/200",
            type: "IMAGE"
        ),
        comments: [
            Comment(
                id: 1,
                postId: 1,
                authorId: 2,
                author: "Alice",
                authorAvatar: "https://via.placeholder.com/40",
                content: "Great post!",
                published: Date(),
                likeOwnerIds: [],
                likedByMe: true
            )
        ]
    ))
}
