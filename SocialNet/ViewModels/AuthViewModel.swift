//
//  AuthViewModel.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

import Foundation
import KeychainSwift

@MainActor
@Observable
final class AuthViewModel: ObservableObject {

    enum State {
        case apiKeyNotProvided
        case authenticated
        case unauthenticated
    }

    private let keychain = KeychainSwift()
    private let userDefaults = UserDefaults.standard

    var isAuthenticated: Bool = false
    var currentUserId: Int {
        UserDefaults.standard.integer(forKey: "currentUserId")
    }
    
    var errorMessage: String? = nil
    var state: State = .apiKeyNotProvided

    private var apiKey: String {
        keychain.get("apiKey") ?? ""
    }

    private var authToken: String {
        keychain.get("authToken") ?? ""
    }

    init() {
        updateState()
    }

    func updateState() {
        if apiKey.isEmpty {
            state = .apiKeyNotProvided
        } else if !authToken.isEmpty {
            state = .authenticated
        } else {
            state = .unauthenticated
        }
    }

    func setApiKey(value: String) {
        keychain.set(value, forKey: "apiKey")
        updateState()
    }

    func logout() {
        keychain.set("", forKey: "authToken")
        userDefaults.set(-1, forKey: "currentUserId")
        isAuthenticated = false
        updateState()
    }

    func authenticate(login: String, password: String) async {
        do {
            let bodyString = "login=\(login)&pass=\(password)"
            let bodyData = bodyString.data(using: .utf8)
            
            var request = URLRequest(url: Fetcher.baseURL.appendingPathComponent("/api/users/authentication"))
            request.httpMethod = "POST"
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue(apiKey, forHTTPHeaderField: "Api-Key")
            request.httpBody = bodyData

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let errorData = String(data: data, encoding: .utf8) {
                    print("Ошибка сервера: \(errorData)")
                }
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 400)
            }

            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            keychain.set(authResponse.token, forKey: "authToken")
            userDefaults.set(authResponse.id, forKey: "currentUserId")
            isAuthenticated = true

            updateState()
        } catch {
            errorMessage = "Ошибка аутентификации: \(error.localizedDescription)"
        }
    }


    func register(login: String, password: String, name: String, avatar: Data? = nil) async {
        do {
            let parameters: [String: String] = ["login": login, "pass": password, "name": name]

            let request: URLRequest
            if let avatar = avatar {
                let boundary = "Boundary-\(UUID().uuidString)"
                guard var multipartRequest = Fetcher.buildRequest(
                    pathStringUrl: "/api/users/registration",
                    stringMethod: "POST"
                ) else {
                    throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
                }

                multipartRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                multipartRequest.httpBody = Fetcher.createMultipartBody(
                    parameters: parameters,
                    fileData: avatar,
                    fileName: "avatar.jpg",
                    mimeType: "image/jpeg",
                    boundary: boundary
                )
                request = multipartRequest
            } else {
                guard var formRequest = Fetcher.buildRequest(
                    pathStringUrl: "/api/users/registration",
                    stringMethod: "POST"
                ) else {
                    throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
                }

                formRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let formBody = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                formRequest.httpBody = formBody.data(using: .utf8)
                request = formRequest
            }

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)

            keychain.set(authResponse.token, forKey: "authToken")
            userDefaults.set(authResponse.id, forKey: "currentUserId")
            updateState()
        } catch {
            errorMessage = "Ошибка регистрации: \(error.localizedDescription)"
        }
    }

}
