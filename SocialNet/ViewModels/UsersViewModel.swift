//
//  UsersViewModel.swift
//  SocialNet
//
//  Created by Роман Лешин on 08.12.2024.
//

import Foundation

@Observable
final class UsersViewModel: ObservableObject {
    var user: User? = nil
    var isLoading: Bool = true
    var error: String? = nil
    
    func loadUser(userId: Int) async {
        isLoading = true
        error = nil
        do {
            // Генерация запроса
            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/users/\(userId)",
                stringMethod: "GET"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            // Выполнение запроса
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }

            // Декодирование ответа
            user = try JSONDecoder.withCustomDateDecoding().decode(User.self, from: data)
        } catch {
            self.error = "Ошибка загрузки пользователя: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func loadUsers() async -> [User] {
        isLoading = true
        error = nil
        var loadedUsers: [User] = []
        do {
            // Генерация запроса
            guard let request = DataCreator.buildRequest(
                pathStringUrl: "/api/users",
                stringMethod: "GET"
            ) else {
                throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to build request"])
            }

            // Выполнение запроса
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
            }
            // Декодирование ответа
            loadedUsers = try JSONDecoder.withCustomDateDecoding().decode([User].self, from: data)
        } catch {
            self.error = "Ошибка загрузки пользователей: \(error.localizedDescription)"
        }
        isLoading = false
        return loadedUsers
    }
}
