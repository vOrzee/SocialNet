//
//  PostApiService.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import Foundation

final class PostApiService {
    static let shared = PostApiService()
    
    private init() {}
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/posts",
            stringMethod: "GET"
        ) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }

            do {
                let decoder = JSONDecoder.withCustomDateDecoding()
                var posts = try decoder.decode([Post].self, from: data)

                let group = DispatchGroup()
                for index in posts.indices {
                    group.enter()
                    CommentApiService.shared.fetchComments(forPostId: posts[index].id) { result in
                        switch result {
                        case .success(let comments):
                            posts[index].comments = comments
                        case .failure(let error):
                            print("Ошибка загрузки комментариев для поста \(posts[index].id): \(error)")
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    completion(.success(posts))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateLike(postId: Int, isLike: Bool, completion: @escaping (Result<Post, Error>) -> Void) {
        let method = isLike ? "POST" : "DELETE"
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/posts/\(postId)/likes",
            stringMethod: method
        ) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }

            do {
                let decoder = JSONDecoder.withCustomDateDecoding()
                let updatedPost = try decoder.decode(Post.self, from: data)
                completion(.success(updatedPost))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchAuthorPosts(authorId: Int, completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/\(authorId)/wall",
            stringMethod: "GET"
        ) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }

            do {
                let decoder = JSONDecoder.withCustomDateDecoding()
                var posts = try decoder.decode([Post].self, from: data)

                let group = DispatchGroup()
                for index in posts.indices {
                    group.enter()
                    CommentApiService.shared.fetchComments(forPostId: posts[index].id) { result in
                        switch result {
                        case .success(let comments):
                            posts[index].comments = comments
                        case .failure(let error):
                            print("Ошибка загрузки комментариев для поста \(posts[index].id): \(error)")
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    completion(.success(posts))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func addPost(content: String, completion: @escaping (Result<Post, Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/posts",
            stringMethod: "POST",
            body: ["content": content]
        ) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server"])))
                return
            }

            do {
                let decoder = JSONDecoder.withCustomDateDecoding()
                let newPost = try decoder.decode(Post.self, from: data)
                completion(.success(newPost))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func deletePost(postId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/posts/\(postId)",
            stringMethod: "DELETE"
        ) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Failed to delete post"])))
                return
            }

            completion(.success(()))
        }.resume()
    }

}
