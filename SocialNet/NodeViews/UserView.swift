//
//  UserView.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//

import SwiftUI

struct UserView: View {
    let userId: Int
    @State var user: User? = nil
    @State var isCurrentUser: Bool = false
    @State private var posts: [Post] = []
    @State private var filteredPosts: [Post] = []
    @State private var searchText: String = ""
    @State private var selectedPost: Post?
    @State private var countPosts = 0
    @State private var isLoading = true
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            isCurrentUser = AuthService.shared.currentUserId == userId
                            loadUser()
                        }
                } else if let user = user {
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
                                        print("Редактироваю")
                                    }) {
                                        Text("Редактировать")
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
                        
                        ForEach(filteredPosts) { post in
                            PostRowView(post: post,
                            onCommentTapped: { post in
                                selectedPost = post // Переход к комментариям поста
                            },
                            onBookmarkTapped: { post in
                                print("Сохранить пост \(post.id)")
                            })
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
                            PostDetailView(post: post)
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
                        Button(action: logout) {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func loadUser() {
        UserApiService.shared.fetchUser(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                    PostApiService.shared.fetchAuthorPosts(authorId: user.id) { result in
                        switch result {
                        case .success(let posts):
                            self.posts = posts
                            self.filteredPosts = posts
                            self.countPosts = posts.count
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .failure(let error):
                    print(error)
                }
                isLoading = false
            }
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
        PostApiService.shared.addPost(content: content) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newPost):
                    self.posts.insert(newPost, at: 0)
                    self.filteredPosts.insert(newPost, at: 0)
                    self.countPosts += 1
                    print("Пост добавлен: \(newPost.id)")
                case .failure(let error):
                    print("Ошибка добавления поста: \(error)")
                }
            }
        }
    }
    
    private func logout() {
        AuthService.shared.logout()
        isLoggedIn = false
    }
}

#Preview {
    NavigationStack {
        UserView(
            userId: UserDefaults.standard.integer(forKey: "isCurrentUser"), user: User(
                id: 1,
                login: "annaux_designer",
                name: "Анна Мищенко",
                avatar: "https://via.placeholder.com/80"
            ),
            isCurrentUser: true, isLoggedIn: .constant(true)
        )
    }
}
