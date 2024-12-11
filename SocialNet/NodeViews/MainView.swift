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
    @State private var editedPost: Post?
    @State private var onViewCreated: Bool = false
    @ObservedObject var authViewModel: AuthViewModel = AuthViewModel()
    @StateObject var postsViewModel: PostsViewModel = PostsViewModel()
    @StateObject var usersViewModel: UsersViewModel = UsersViewModel()
    @Environment(\.modelContext) private var context
    @State private var isMapPresented = false
    @State private var selectedCoordinates: Coordinates?
    @State private var lastVisibleIndex: Int?

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
                    ScrollViewReader { proxy in
                        List(Array($filteredPosts.enumerated()), id: \.element.id) { index, post in
                            if index == 0 {
                                HStack {
                                    Spacer()
                                    Text("Свежее")
                                        .font(.headline)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            } else if !Calendar.current.isDate(filteredPosts[index].published, inSameDayAs: filteredPosts[index - 1].published) {
                                HStack {
                                    Spacer()
                                    Text(formatDate(filteredPosts[index].published))
                                        .font(.headline)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                            }
                            PostRowView(post: post, authViewModel: authViewModel,
                                    onEditTapped: { post in
                                        editedPost = post
                                    },
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
                                        selectedPost = post
                                    },
                                    onCoordsTapped: { coords in
                                        selectedCoordinates = coords
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
                            .onAppear {
                                if index > filteredPosts.count - 6 {
                                    lastVisibleIndex = index
                                    loadMorePosts(postId: filteredPosts[index].id)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .onChange(of: filteredPosts.count) { _, _ in
                            if let lastVisibleIndex {
                                proxy.scrollTo(filteredPosts[lastVisibleIndex].id, anchor: .bottom)
                            }
                        }
                        .refreshable {
                            loadData()
                        }
                    }
                    .navigationDestination(isPresented: Binding(
                        get: { selectedPost != nil },
                        set: { if !$0 { selectedPost = nil } }
                    )) {
                        if let post = selectedPost {
                            PostDetailView(post: post, authVewModel: authViewModel)
                        }
                    }
                    .navigationDestination(isPresented: Binding(
                        get: { editedPost != nil },
                        set: { if !$0 { editedPost = nil } }
                    )) {
                        if let post = editedPost {
                            AddPostView(postPreparation: post, attachmentType: post.attachment?.type, postsViewModel: postsViewModel)
                        }
                    }
                }
            }
            .onChange(of: selectedCoordinates, { oldValue, newValue in
                isMapPresented = true
            })
            .onChange(of: postsViewModel.posts.count) { oldValue, newValue in
                filterPosts()
            }
            .sheet(isPresented: $isMapPresented) {
                MapView(coordinatePoint: selectedCoordinates, .constant(nil))
            }
            .onAppear {
                if !onViewCreated {
                    loadData()
                    onViewCreated = true
                }
                filterPosts()
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
    
    private func loadMorePosts(postId: Int) {
        Task {
            let minId = postsViewModel.posts.min { $0.id < $1.id }?.id ?? 0
            await postsViewModel.getBefore(postId: postId)
            let newPosts = postsViewModel.posts.filter { post in
                post.id > minId
            }
            let authorIds = Array(Set(postsViewModel.posts.map { $0.authorId }))
            users = await usersViewModel.loadUsers().filter { authorIds.contains($0.id) }
            if searchText.isEmpty {
                filteredPosts.append(contentsOf: newPosts)
            } else {
                let findedAuthorsIds = users.filter { user in
                    user.name.lowercased().contains(searchText.lowercased()) || user.login.lowercased().contains(searchText.lowercased())
                }.map { $0.id }
                filteredPosts.append(contentsOf: newPosts.filter {
                    findedAuthorsIds.contains($0.authorId)
                })
            }
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

