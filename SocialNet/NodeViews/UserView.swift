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
    @StateObject var postsViewModel: PostsViewModel = PostsViewModel()
    @State var isCurrentUser: Bool = false
    @State private var filteredPosts: [Post] = []
    @State private var searchText: String = ""
    @State private var selectedPost: Post?
    @State private var countPosts = 0
    @Environment(\.modelContext) private var context
    @State private var isSettingsPresented = false
    @State private var showAddPostView = false
    @State private var editedPost: Post?
    @State private var isMapPresented = false
    @State private var selectedCoordinates: Coordinates?

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
                                Text("\(postsViewModel.posts.count)")
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
                    .navigationDestination(isPresented: Binding(
                        get: { editedPost != nil },
                        set: { if !$0 { editedPost = nil } }
                    )) {
                        if let post = editedPost {
                            AddPostView(postPreparation: post, attachmentType: post.attachment?.type, postsViewModel: postsViewModel)
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
            .sheet(isPresented: $showAddPostView) {
                AddPostView(postsViewModel: postsViewModel)
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
        }
    }
    
    private func loadUser() {
        Task {
            await usersViewModel.loadUser(userId: userId)
            await postsViewModel.loadPosts(authorId: userId)
            self.filteredPosts = postsViewModel.posts
            self.countPosts = postsViewModel.posts.count
        }
    }
    
    private func filterPosts() {
        if searchText.isEmpty {
            filteredPosts = postsViewModel.posts
        } else {
            filteredPosts = postsViewModel.posts.filter {
                $0.content.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    private func showAddPostAlert() {
        showAddPostView = true
    }
}
