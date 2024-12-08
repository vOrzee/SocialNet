//
//  PostDetailView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct PostDetailView: View {
    @State var post: Post
    @StateObject private var commentsViewModel = CommentsViewModel()
    @State private var commentText: String = ""

    var body: some View {
        VStack {
            List {
                PostRowView(
                    post: $post,
                    onCommentTapped: nil
                )
                .padding(.bottom)

                ForEach(commentsViewModel.comments) { comment in
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
        Task {
            await commentsViewModel.loadComments(for: post.id)
        }
    }
    
    private func sendComment() {
        guard !commentText.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Комментарий пустой")
            return
        }
        Task {
            await commentsViewModel.addComment(to: post.id, content: commentText)
            commentText = ""
            loadComments()
        }
    }
}
