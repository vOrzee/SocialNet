//
//  PostRowView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct PostRowView: View {
    @Binding var post: Post
    @State private var isViewActive: Bool = true
    @ObservedObject var authViewModel: AuthViewModel
    var onTrashTapped: ((Post) -> Void)? = nil
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
                    if(authViewModel.currentUserId == post.authorId) {
                        Image(systemName: "trash")
                            .onTapGesture {
                                onTrashTapped?(post)
                            }
                    }
                    
                }
                
                Text(post.content)
                    .font(.body)
                
                if let attachment = post.attachment {
                    AttachmentView(attachment: attachment)
                }
                
                if let link = post.link, let url = URL(string: link) {
                    Link(link, destination: url)
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
                    
                    if let coords = post.coords {
                        Image(systemName: "location.fill")
                            .foregroundColor(.orange)
                            .onTapGesture {
                                print("Координаты: \(coords.lat), \(coords.long)")
                            }
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
}
