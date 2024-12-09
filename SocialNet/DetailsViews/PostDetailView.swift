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
    @State var isActive: Bool = true
    var postsViewModel: PostsViewModel = PostsViewModel()
    @Environment(\.modelContext) private var context
    @ObservedObject var authVewModel: AuthViewModel

    var body: some View {
        if isActive {
            VStack {
                List {
                    PostRowView(
                        post: $post, authViewModel: authVewModel,
                        onTrashTapped: { post in
                            Task {
                                await postsViewModel.deletePost(postId: post.id)
                                isActive = false
                            }
                        },
                        onLikeTapped: { post in
                            Task {
                                await postsViewModel.updateLike(post: post)
                                guard let updatedPost = postsViewModel.lastUpdatePost else {
                                    isActive = false
                                    return
                                }
                                self.post = updatedPost
                            }
                        },
                        onCommentTapped: nil,
                        onBookmarkTapped: { post in
                            context.insert(SavedPost.from(post: post))
                            do {
                                try context.save()
                                print("Пост сохранён")
                            } catch {
                                print("Ошибка сохранения поста: \(error.localizedDescription)")
                            }
                        }
                    )
                    .padding(.bottom)
                    
                    ForEach($commentsViewModel.comments) { comment in
                        CommentRowView(comment: comment, authViewModel: authVewModel,
                            onTrashTapped: { comment in
                                Task { await commentsViewModel.deleteComment(from: post.id, commentId: comment.id) }
                            },
                            onLikeTapped: { comment in
                                Task{ await commentsViewModel.updateLike(postId: comment.postId, commentId: comment.id, currentLikeStatus: comment.likedByMe) }
                            }
                        )
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
