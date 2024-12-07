//
//  PostRowView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct PostRowView: View {
    let post: Post
    var onMenuTapped: ((Post) -> Void)? = nil
    var onLikeTapped: ((Post) -> Void)? = nil
    var onCommentTapped: ((Post) -> Void)? = nil
    var onBookmarkTapped: ((Post) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsyncImage(url: URL(string: post.authorAvatar ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(post.author)
                        .font(.headline)
                    Text(post.published, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
                
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .onTapGesture {
                        onMenuTapped?(post)
                    }

            }

            Text(post.content)
                .font(.body)

            if let attachment = post.attachment, attachment.type == "IMAGE" {
                HStack {
                    Spacer()
                    AsyncImage(url: URL(string: attachment.url)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                    }
                    .frame(height: 200)
                    Spacer()
                }
            }

            HStack {
                HStack {
                    Image(systemName: post.likedByMe ? "heart.fill" : "heart")
                    Text("\(post.likeOwnerIds.count)")
                }
                .onTapGesture {
                    onLikeTapped?(post)
                }

                HStack {
                    Image(systemName: "bubble.left")
                    Text("\(post.comments?.count ?? 0)")
                }
                .onTapGesture {
                    onCommentTapped?(post)
                }

                Spacer()

                Image(systemName: "bookmark")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        onBookmarkTapped?(post)
                    }
                
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}
