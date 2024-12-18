//
//  AuthResponse.swift
//  AuthResponse
//
//  Created by Роман Лешин on 06.12.2024.
//

struct AuthResponse: Identifiable, Codable {
    let id: Int
    let token: String
    let avatar: String?
}
