//
//  ContentView.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
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
                Text("Сохранённое")
                    .tabItem {
                        Label("Сохранённое", systemImage: "heart")
                    }
            }
        case .unauthenticated:
            LoginView(authViewModel: authViewModel)
        }
    }
}

