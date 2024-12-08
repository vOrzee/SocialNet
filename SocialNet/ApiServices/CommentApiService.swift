//
//  CommentService.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//


import Foundation

final class CommentApiService {
    static let shared = CommentApiService()
    
    private init() {}
    
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
    
    func addComment(postId: Int, content: String, completion: @escaping (Result<Comment, Error>) -> Void) {
        guard let request = DataCreator.buildRequest(
            pathStringUrl: "/api/posts/\(postId)/comments",
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
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder.withCustomDateDecoding()
                let comment = try decoder.decode(Comment.self, from: data)
                completion(.success(comment))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
