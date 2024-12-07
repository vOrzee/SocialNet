//
//  User.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

struct User: Codable, Identifiable {
    let id: Int
    let login: String
    let name: String
    let avatar: String?
}
