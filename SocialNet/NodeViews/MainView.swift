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
    @State private var isLoading = true
    @State private var selectedPost: Post?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    AvatarScrollView(users: users)
                    HStack {
                        Spacer()
                        
                        Text("Свежее")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                    List(posts) { post in
                        PostRowView(
                            post: post) { post in
                                print("Меню поста \(post.id)")
                            }
                            onLikeTapped: { post in
                                print("Пост \(post.id) понравился")
                            }
                            onCommentTapped: { post in
                                selectedPost = post // Переход к деталям поста
                            }
                            onBookmarkTapped: { post in
                                print("Сохранить пост \(post.id)")
                            }
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
            .onAppear {
                loadData()
            }
        }
    }
    
    private func loadData() {
        NetworkService.shared.fetchPosts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedPosts):
                    self.posts = loadedPosts
                    
                    // Уникальные идентификаторы авторов
                    let authorIds = Array(Set(loadedPosts.map { $0.authorId }))
                    let dispatchGroup = DispatchGroup()

                    // Загружаем данные авторов
                    authorIds.forEach { authorId in
                        dispatchGroup.enter()
                        NetworkService.shared.fetchUser(userId: authorId) { result in
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
                        print("Все авторы загружены: \(self.users)")
                        self.isLoading = false
                    }
                    
                case .failure(let error):
                    print("Ошибка загрузки постов: \(error)")
                    self.isLoading = false
                }
            }
        }
    }


}

#Preview {
    MainView()
}
