//
//  NetworkService.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/posts/latest",
            stringMethod: "GET",
            queryItems: ["count": "150"]
        ) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])))
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
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
                    fetchComments(forPostId: posts[index].id) { result in
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

    
    func fetchComments(forPostId postId: Int, completion: @escaping (Result<[Comment], Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/posts/\(postId)/comments",
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
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder.withCustomDateDecoding()
                let comments = try decoder.decode([Comment].self, from: data)
                completion(.success(comments))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUser(userId: Int, completion: @escaping (Result<User, Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/users/\(userId)",
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
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
