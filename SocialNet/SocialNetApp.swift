//
//  SocialNetApp.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import SwiftUI
import SwiftData

@main
struct SocialNetApp: App {
    @StateObject private var appSettings = AppSettings()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedPost.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        }
        .modelContainer(sharedModelContainer)
    }
}
