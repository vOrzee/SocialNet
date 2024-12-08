//
//  UserService.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//

import Foundation

final class UserApiService {
    static let shared = UserApiService()
    
    private init() {}
    
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
