//
//  AvatarScrollView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct AvatarScrollView: View {
    let users: [User]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(users) { user in
                    VStack {
                        AsyncImage(url: URL(string: user.avatar ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                        Text(user.name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
