//
//  MainView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct MainView: View {
    @State private var users: [User] = []
    @State private var posts: [Post] = []
    @State private var filteredPosts: [Post] = []
    @State private var isLoading = true
    @State private var searchText: String = ""
    @State private var selectedPost: Post?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
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

                    AvatarScrollView(users: users)

                    List(filteredPosts) { post in
                        PostRowView(post: post,
                        onCommentTapped: { post in
                            selectedPost = post // Переход к комментариям поста
                        },
                        onBookmarkTapped: { post in
                            print("Сохранить пост \(post.id)")
                        })
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .navigationDestination(isPresented: Binding(
                        get: { selectedPost != nil },
                        set: { if !$0 { selectedPost = nil } }
                    )) {
                        if let post = selectedPost {
                            PostDetailView(post: post)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .keyboardDismissToolbar()
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        PostApiService.shared.fetchPosts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedPosts):
                    self.posts = loadedPosts
                    self.filteredPosts = loadedPosts
                    // Уникальные идентификаторы авторов
                    let authorIds = Array(Set(loadedPosts.map { $0.authorId }))
                    let dispatchGroup = DispatchGroup()

                    // Загружаем данные авторов
                    authorIds.forEach { authorId in
                        dispatchGroup.enter()
                        UserApiService.shared.fetchUser(userId: authorId) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let user):
                                    self.users.append(user)
                                case .failure(let error):
                                    print("Ошибка загрузки автора с ID \(authorId): \(error)")
                                }
                                dispatchGroup.leave()
                            }
                        }
                    }

                    // Обработка завершения всех запросов авторов
                    dispatchGroup.notify(queue: .main) {
                        self.isLoading = false
                    }
                    
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error)")
                    self.isLoading = false
                }
            }
        }
    }

    private func filterPosts() {
        if searchText.isEmpty {
            filteredPosts = posts
        } else {
            let findedAuthorsIds = users.filter { user in
                user.name.lowercased().contains(searchText.lowercased()) || user.login.lowercased().contains(searchText.lowercased())
            }.map { $0.id }
            filteredPosts = posts.filter {
                findedAuthorsIds.contains($0.authorId)
            }
        }
    }
}

