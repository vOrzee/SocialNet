//
//  MainView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct MainView: View {
    @State private var users: [User] = []
    @State private var filteredPosts: [Post] = []
    @State private var searchText: String = ""
    @State private var selectedPost: Post?
    @State private var onViewCreated: Bool = false
    @ObservedObject var authViewModel: AuthViewModel = AuthViewModel()
    @StateObject var postsViewModel: PostsViewModel = PostsViewModel()
    @StateObject var usersViewModel: UsersViewModel = UsersViewModel()
    @Environment(\.modelContext) private var context
    @State private var isMapPresented = false
    @State private var selectedCoordinates: Coordinates?

    var body: some View {
        NavigationStack {
            VStack {
                if postsViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    
                    ZStack {
                        TextField("Поиск по имени или логину", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .onChange(of: searchText) { _, _ in
                                filterPosts()
                            }
                        HStack{
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(8.0)
                                .padding(.trailing)
                        }
                    }

                    AvatarScrollView(users: users, authViewModel: authViewModel)

                    List($filteredPosts) { post in
                        PostRowView(post: post, authViewModel: authViewModel,
                            onTrashTapped: { post in
                                Task {
                                    await postsViewModel.deletePost(postId: post.id)
                                    filteredPosts = postsViewModel.posts
                                }
                            },
                            onLikeTapped: { post in
                                Task {
                                    await postsViewModel.updateLike(post: post)
                                    filteredPosts = postsViewModel.posts
                                }
                            },
                            onCommentTapped: { post in
                                selectedPost = post // Переход к комментариям поста
                            },
                            onCoordsTapped: { coords in
                                selectedCoordinates = coords
                                isMapPresented = true
                            },
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
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .navigationDestination(isPresented: Binding(
                        get: { selectedPost != nil },
                        set: { if !$0 { selectedPost = nil } }
                    )) {
                        if let post = selectedPost {
                            PostDetailView(post: post, authVewModel: authViewModel)
                        }
                    }
                }
            }
            .onAppear {
                if !onViewCreated {
                    loadData()
                    onViewCreated = true
                }
            }
            .sheet(isPresented: $isMapPresented) {
                if let coords = selectedCoordinates {
                    MapView(coordinatePoint: coords)
                } else {
                    MapView()
                }
            }
            .background(Color(.systemBackground))
            .keyboardDismissToolbar()
        }
    }
    
    private func loadData() {
        Task {
            await postsViewModel.loadPosts()
            let authorIds = Array(Set(postsViewModel.posts.map { $0.authorId }))
            users = await usersViewModel.loadUsers().filter { authorIds.contains($0.id) }
            filteredPosts = postsViewModel.posts
        }
    }

    private func filterPosts() {
        if searchText.isEmpty {
            filteredPosts = postsViewModel.posts
        } else {
            let findedAuthorsIds = users.filter { user in
                user.name.lowercased().contains(searchText.lowercased()) || user.login.lowercased().contains(searchText.lowercased())
            }.map { $0.id }
            filteredPosts = postsViewModel.posts.filter {
                findedAuthorsIds.contains($0.authorId)
            }
        }
    }
}

