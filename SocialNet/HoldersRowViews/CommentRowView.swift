//
//  CommentRowView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct CommentRowView: View {
    @Binding var comment: Comment
    @State var isExists: Bool = true
    @ObservedObject var authViewModel: AuthViewModel
    var onTrashTapped: ((Comment) -> Void)? = nil
    var onLikeTapped: ((Comment) -> Void)? = nil
    
    var body: some View {
        if isExists {
            HStack(alignment: .top, spacing: 8) {
                AsyncImage(url: URL(string: comment.authorAvatar ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Text(comment.author)
                            .font(.headline)
                        Spacer()
                        if(authViewModel.currentUserId == comment.authorId) {
                            Image(systemName: "trash")
                                .onTapGesture {
                                    onTrashTapped?(comment)
                                }
                        }
                    }
                    Text(comment.content)
                        .font(.body)
                    HStack {
                        Text(comment.published, style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Image(systemName: comment.likedByMe ? "heart.fill" : "heart")
                                .frame(maxHeight: 16)
                            Text("\(comment.likeOwnerIds.count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .onTapGesture {
                            onLikeTapped?(comment)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

