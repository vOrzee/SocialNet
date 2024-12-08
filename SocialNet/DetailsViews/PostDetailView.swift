//
//  PostDetailView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    @State private var commentText: String = ""
    @State private var comments: [Comment] = []

    var body: some View {
        VStack {
            List {
                PostRowView(
                    post: post,
                    onCommentTapped: nil
                )
                .padding(.bottom)

                ForEach(comments) { comment in
                    CommentRowView(comment: comment)
                }
            }
            .listStyle(.plain)
            Spacer()
            HStack {
                TextField("Введите комментарий", text: $commentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .padding(.leading, 8)

                Button(action: {
                    sendComment()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()
            
        }
        .navigationTitle("Комментарии")
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDismissToolbar()
        .onAppear {
            loadComments()
        }
    }
    
    private func loadComments() {
        CommentApiService.shared.fetchComments(forPostId: post.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let comments):
                    withAnimation {
                        self.comments = comments
                    }
                case .failure(let error):
                    print("Error fetching comments: \(error)")
                }
            }
        }
    }
    
    private func sendComment() {
        guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Комментарий пустой")
            return
        }
        CommentApiService.shared.addComment(postId: post.id, content: commentText) { result in
            switch result {
            case .success:
                loadComments()
                commentText = ""
            case .failure(let error):
                print("Error fetching comments: \(error)")
            }
        }
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
