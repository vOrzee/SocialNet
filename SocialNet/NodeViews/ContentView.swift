//
//  ContentView.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isKeyProvided: Bool = !AuthService.shared.apiKey.isEmpty
    @State private var isLoggedIn: Bool = !AuthService.shared.authToken.isEmpty

    var body: some View {
        if isLoggedIn && isKeyProvided {
            TabView {
                MainView()
                    .tabItem {
                        Label("Главная", systemImage: "house")
                    }
                Text("Профиль")
                    .tabItem {
                        Label("Профиль", systemImage: "person")
                    }
                Text("Сохранённое")
                    .tabItem {
                        Label("Сохранённое", systemImage: "heart")
                    }
            }
        } else if isKeyProvided {
            LoginView(isLoggedIn: $isLoggedIn, isKeyProvided: $isKeyProvided)
        } else {
            ApiView(isKeyProvided: $isKeyProvided)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
