//
//  CommentRowView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct CommentRowView: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            AsyncImage(url: URL(string: comment.authorAvatar ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(comment.author)
                    .font(.headline)
                Text(comment.content)
                    .font(.body)
                Text(comment.published, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

