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
            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/posts/\(postId)/comments",
                stringMethod: "GET"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            let loadedComments = try JSONDecoder.withCustomDateDecoding().decode([Comment].self, from: data)
            comments = loadedComments
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func addComment(to postId: Int, content: String) async {
        isLoading = true
        do {
            let body: [String: Any] = ["content": content]

            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/posts/\(postId)/comments",
                stringMethod: "POST",
                body: body
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            let newComment = try JSONDecoder.withCustomDateDecoding().decode(Comment.self, from: data)
            comments.append(newComment)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func deleteComment(from postId: Int, commentId: Int) async {
        isLoading = true
        error = nil
        do {
            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/posts/\(postId)/comments/\(commentId)",
                stringMethod: "DELETE"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            if let index = comments.firstIndex(where: { $0.id == commentId }) {
                comments.remove(at: index)
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func updateLike(postId: Int, commentId: Int, currentLikeStatus: Bool) async {
        isLoading = true
        error = nil
        do {
            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/posts/\(postId)/comments/\(commentId)/likes",
                stringMethod: currentLikeStatus ? "DELETE" : "POST"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }
            
            let updatedComment = try JSONDecoder.withCustomDateDecoding().decode(Comment.self, from: data)

            // Локально обновляем комментарий
            if let index = comments.firstIndex(where: { $0.id == commentId }) {
                comments[index] = updatedComment
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}


