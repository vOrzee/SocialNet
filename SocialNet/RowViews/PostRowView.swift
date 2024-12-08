//
//  PostRowView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct PostRowView: View {
    @State var post: Post
    @State private var isViewActive: Bool = true
    var onMenuTapped: ((Post) -> Void)? = nil
    var onLikeTapped: ((Post) -> Void)? = nil
    var onCommentTapped: ((Post) -> Void)? = nil
    var onBookmarkTapped: ((Post) -> Void)? = nil

    var body: some View {
        if isViewActive {
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
                            handleMenuTapped()
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
                        handleLikeTapped()
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
    
    private func handleLikeTapped() {
        if let customAction = onLikeTapped {
            customAction(post)
        } else {
            // Базовая реализация:
            PostApiService.shared.updateLike(postId: post.id, isLike: !post.likedByMe) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let updatedPost):
                        self.post = self.post.updateLikes(likeOwnerIds: updatedPost.likeOwnerIds, likedByMe: updatedPost.likedByMe)
                    case .failure(let error):
                        print("Ошибка при обновлении лайка: \(error)")
                    }
                }
            }
        }
    }
    
    private func handleMenuTapped() {
        if let customAction = onMenuTapped {
            customAction(post)
        } else {
            // Базовая реализация: Удаление поста
            PostApiService.shared.deletePost(postId: post.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Пост \(post.id) удалён")
                        isViewActive = false
                    case .failure(let error):
                        print("Ошибка при удалении поста: \(error)")
                    }
                }
            }
        }
    }
}
