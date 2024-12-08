//
//  AuthService.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import Foundation
import KeychainSwift

final class AuthService {
    static let shared = AuthService()
    private let keychain = KeychainSwift()
    var apiKey: String {
        keychain.get("apiKey") ?? ""
    }
    var authToken: String {
        keychain.get("authToken") ?? ""
    }
    var currentUserId: Int {
        UserDefaults.standard.integer(forKey: "currentUserId")
    }
    
    private init() {}
    
    func setApiKey(value: String) {
        keychain.set(value, forKey: "apiKey")
    }
    
    func logout() {
        keychain.set("", forKey: "authToken")
        UserDefaults.standard.set(-1, forKey: "currentUserId")
    }
    
    func authenticate(
        login: String,
        password: String,
        completion: @escaping (Result<AuthResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "/api/users/authentication", relativeTo: DataCreator.baseURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "login=\(login)&pass=\(password)"
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                keychain.set(authResponse.token, forKey: "authToken")
                UserDefaults.standard.set(authResponse.id, forKey: "currentUserId")
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func register(
        login: String,
        password: String,
        name: String,
        avatar: Data?,
        completion: @escaping (Result<AuthResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "/api/users/registration", relativeTo: DataCreator.baseURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "Api-Key")

        if let avatar = avatar {
            // Регистрация с аватаркой (multipart/form-data)
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = DataCreator.createMultipartBody(
                parameters: ["login": login, "pass": password, "name": name],
                fileData: avatar,
                fileName: "avatar.jpg",
                mimeType: "image/jpeg",
                boundary: boundary
            )
        } else {
            // Регистрация без аватарки (x-www-form-urlencoded)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            let bodyString = "login=\(login)&pass=\(password)&name=\(name)"
            request.httpBody = bodyString.data(using: .utf8)
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                keychain.set(authResponse.token, forKey: "authToken")
                UserDefaults.standard.set(authResponse.id, forKey: "currentUserId")
                completion(.success(authResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
