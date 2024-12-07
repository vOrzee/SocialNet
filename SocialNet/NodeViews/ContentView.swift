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
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
