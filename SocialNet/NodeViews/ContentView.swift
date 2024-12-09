//
//  ContentView.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import SwiftUI
import SwiftData

struct LaunchScreenView: View {
    @State private var isLoading = true
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Image("LaunchIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}


struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var faceIDViewModel = FaceIDViewModel()
    @State private var isLoading = true

    var body: some View {
        if !isLoading {
            Group {
                switch authViewModel.state {
                case .apiKeyNotProvided:
                    ApiView(authViewModel: authViewModel)
                case .authenticated:
                    TabView {
                        MainView(authViewModel: authViewModel)
                            .tabItem {
                                Label("Главная", systemImage: "house")
                            }
                        UserView(
                            userId: authViewModel.currentUserId,
                            authViewModel: authViewModel
                        )
                        .tabItem {
                            Label("Профиль", systemImage: "person")
                        }
                        SavedPostsView()
                            .tabItem {
                                Label("Сохранённое", systemImage: "heart")
                            }
                    }
                case .unauthenticated:
                    LoginView(authViewModel: authViewModel)
                }
            }
            .onAppear {
                let credentials = authViewModel.state
                if credentials == .authenticated {
                    authViewModel.state = .unauthenticated
                    if faceIDViewModel.isFaceIDEnabled {
                        Task {
                            await faceIDViewModel.authenticate()
                        }
                    } else {
                        authViewModel.state = .authenticated
                    }
                }
            }
            .onChange(of: faceIDViewModel.isAuthenticated) { isAuthenticated, _ in
                if faceIDViewModel.isFaceIDEnabled {
                    authViewModel.state = .authenticated
                } else if !isAuthenticated {
                    authViewModel.state = .unauthenticated
                }
            }
        } else {
            LaunchScreenView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isLoading = false
                    }
                }
        }
    }
}

