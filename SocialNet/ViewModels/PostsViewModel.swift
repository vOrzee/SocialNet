//
//  PostsViewModel.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//

import Foundation

@Observable
@MainActor
final class PostsViewModel: ObservableObject {
    var posts: [Post] = []
    var isLoading: Bool = false
    var error: String? = nil
    var lastUpdatePost: Post? = nil

    func loadPosts(authorId: Int? = nil) async {
        isLoading = true
        error = nil
        do {
            let path = authorId == nil ? "/api/posts" : "/api/\(authorId!)/wall"
            guard let request = DataCreator.buildRequest(pathStringUrl: path, stringMethod: "GET") else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            var loadedPosts = try JSONDecoder.withCustomDateDecoding().decode([Post].self, from: data)

            await withTaskGroup(of: (Int, [Comment]?).self) { group in
                for index in loadedPosts.indices {
                    group.addTask {
                        guard let commentRequest = DataCreator.buildRequest(
                            pathStringUrl: "/api/posts/\(loadedPosts[index].id)/comments",
                            stringMethod: "GET"
                        ) else {
                            return (index, nil)
                        }

                        do {
                            let (commentData, commentResponse) = try await URLSession.shared.data(for: commentRequest)
                            guard let httpCommentResponse = commentResponse as? HTTPURLResponse, (200...299).contains(httpCommentResponse.statusCode) else {
                                return (index, nil)
                            }

                            let comments = try JSONDecoder.withCustomDateDecoding().decode([Comment].self, from: commentData)
                            return (index, comments)
                        } catch {
                            return (index, nil)
                        }
                    }
                }

                for await (index, comments) in group {
                    if let comments = comments {
                        loadedPosts[index] = loadedPosts[index].addComments(comments: comments)
                    }
                }
            }

            posts = loadedPosts
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func addPost(post: Post) async {
        do {
            // Формируем тело запроса
            var body: [String: Any] = [
                "id": 0,
                "authorId": post.authorId,
                "author": post.author,
                "authorAvatar": post.authorAvatar ?? "",
                "content": post.content,
                "published": ISO8601DateFormatter().string(from: post.published),
                "link": post.link ?? ""
            ]
            
            // Добавляем координаты, если есть
            if let coords = post.coords {
                body["coords"] = [
                    "lat": coords.lat,
                    "long": coords.long
                ]
            }
            
            // Добавляем вложение, если есть
            if let attachment = post.attachment {
                body["attachment"] = [
                    "url": attachment.url,
                    "type": attachment.type
                ]
            }
            
            // Создаём запрос
            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/posts",
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
            
            // Декодируем ответ
            let newPost = try JSONDecoder.withCustomDateDecoding().decode(Post.self, from: data)
            posts.insert(newPost, at: 0)
        } catch {
            self.error = "Ошибка создания поста: \(error.localizedDescription)"
        }
    }

    func updateLike(post: Post) async {
        do {
            let path = "/api/posts/\(post.id)/likes"
            print(post.likedByMe ? "DELETE" : "POST")
            guard let request = DataCreator.buildRequest(
                pathStringUrl: path,
                stringMethod: post.likedByMe ? "DELETE" : "POST"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            let updatedPost = try JSONDecoder.withCustomDateDecoding().decode(Post.self, from: data)
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index] = updatedPost
            }
            lastUpdatePost = updatedPost
        } catch {
            self.error = error.localizedDescription
            lastUpdatePost = nil
        }
    }

    func deletePost(postId: Int) async {
        do {
            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/posts/\(postId)",
                stringMethod: "DELETE"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            posts.removeAll { $0.id == postId }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func upload(_ fileData: Data, fileName: String = "file") async -> String? {
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let request = DataCreator.createUploadRequest(fileData: fileData, fileName: fileName, boundary: boundary) else {
            self.error = "Ошибка создания запроса"
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Ошибка ответа сервера"])
            }

            let decoder = JSONDecoder()
            let uploadResponse = try decoder.decode(MediaResponse.self, from: data)
            return uploadResponse.url
        } catch {
            self.error = "Ошибка загрузки файла: \(error.localizedDescription)"
            return nil
        }
    }
}
