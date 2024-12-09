//
//  UserView.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//

import SwiftUI

struct UserView: View {
    let userId: Int
    @ObservedObject var authViewModel: AuthViewModel
    var usersViewModel: UsersViewModel = UsersViewModel()
    var postsViewModel: PostsViewModel = PostsViewModel()
    @State var isCurrentUser: Bool = false
    @State private var posts: [Post] = []
    @State private var filteredPosts: [Post] = []
    @State private var searchText: String = ""
    @State private var selectedPost: Post?
    @State private var countPosts = 0
    @Environment(\.modelContext) private var context
    @State private var isSettingsPresented = false

    var body: some View {
        NavigationStack {
            Group {
                if usersViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            isCurrentUser = authViewModel.currentUserId == userId
                            loadUser()
                        }
                } else if let user = usersViewModel.user {
                    List {
                        HStack {
                            Spacer()
                            VStack {
                                AsyncImage(url: URL(string: user.avatar ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                                
                                Text(user.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("@\(user.login)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                if isCurrentUser {
                                    Button(action: {
                                        isSettingsPresented = true
                                    }) {
                                        Text("Редактировать настройки")
                                            .fontWeight(.semibold)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.orange)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            Spacer()
                        }.listRowSeparator(.hidden)
                        
                        HStack {
                            Spacer()
                            VStack {
                                Text("\(countPosts)")
                                    .font(.headline)
                                Text("публикаций")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if isCurrentUser {
                                Button(action: showAddPostAlert) {
                                    VStack {
                                        Image(systemName: "pencil")
                                            .font(.title2)
                                        
                                        Text("Добавить запись")
                                            .font(.caption)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        
                        ZStack {
                            TextField("Поиск по контенту", text: $searchText)
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
                        .listRowSeparator(.hidden)
                        
                        ForEach($filteredPosts) { post in
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
                    }
                    .listRowSeparator(.hidden)
                    .listStyle(.plain)
                    .navigationDestination(isPresented: Binding(
                        get: { selectedPost != nil },
                        set: { if !$0 { selectedPost = nil } }
                    )) {
                        if let post = selectedPost {
                            PostDetailView(post: post, authVewModel: authViewModel)
                        }
                    }
                } else {
                    Text("Пользователь не найден.")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Профиль")
            .toolbar {
                if isCurrentUser {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {authViewModel.logout()}) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView(authViewModel: authViewModel)
            }
            .onAppear {
                self.countPosts = posts.count
            }
        }
    }
    
    private func loadUser() {
        Task {
            await usersViewModel.loadUser(userId: userId)
            await postsViewModel.loadPosts(authorId: userId)
            self.posts = postsViewModel.posts
            self.filteredPosts = postsViewModel.posts
            self.countPosts = postsViewModel.posts.count
        }
    }
    
    private func filterPosts() {
        if searchText.isEmpty {
            filteredPosts = posts
        } else {
            filteredPosts = posts.filter {
                $0.content.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // TODO Временное решение, для тестирования функционала, заменю на View
    private func showAddPostAlert() {
        let alertController = UIAlertController(
            title: "Новый пост",
            message: "Введите текст для нового поста",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Текст поста"
        }
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { _ in
            guard let content = alertController.textFields?.first?.text, !content.isEmpty else {
                print("Пост пустой")
                return
            }
            addPost(content: content)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alertController, animated: true)
        }
    }
    
    private func addPost(content: String) {
        Task {
            await postsViewModel.addPost(content: content)
        }
    }
}
