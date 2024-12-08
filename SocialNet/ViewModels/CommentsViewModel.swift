//
//  CommentsViewModel.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//

import Foundation

@MainActor
final class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    func loadComments(for postId: Int) async {
        isLoading = true
        do {
            // Генерируем запрос
            guard let request = Fetcher.buildRequest(
                pathStringUrl: "/api/posts/\(postId)/comments",
                stringMethod: "GET"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            // Выполняем запрос
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            // Декодируем комментарии
            let loadedComments = try JSONDecoder.withCustomDateDecoding().decode([Comment].self, from: data)
            comments = loadedComments
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func addComment(to postId: Int, content: String) async {
        do {
            // Формируем тело запроса
            let body: [String: Any] = ["content": content]

            // Генерируем запрос
            guard let request = Fetcher.buildRequest(
                pathStringUrl: "/api/posts/\(postId)/comments",
                stringMethod: "POST",
                body: body
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            // Выполняем запрос
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            // Декодируем новый комментарий
            let newComment = try JSONDecoder.withCustomDateDecoding().decode(Comment.self, from: data)
            comments.append(newComment)
        } catch {
            self.error = error.localizedDescription
        }
    }

}


