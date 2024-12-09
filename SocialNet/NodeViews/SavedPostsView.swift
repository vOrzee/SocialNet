//
//  SavedPostView.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

import SwiftUI
import SwiftData

struct SavedPostsView: View {
    @Environment(\.modelContext) private var context
    @Query(FetchDescriptor<SavedPost>()) private var savedPosts: [SavedPost]

    var body: some View {
        List {
            Section(header: Text("Сохранённые посты").font(.headline)) {
                ForEach(savedPosts) { post in
                    SavedPostRowView(post: post)
                        .listRowSeparator(.hidden)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let post = savedPosts[index]
                        context.delete(post)
                    }
                    do {
                        try context.save()
                    } catch {
                        print("Ошибка удаления поста: \(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Сохранённое")
    }
}
