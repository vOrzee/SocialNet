//
//  AttachmentView.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//


import SwiftUI
import AVKit

struct AttachmentView: View {
    let attachment: Attachment

    var body: some View {
        Group {
            switch attachment.type.uppercased() {
            case "IMAGE":
                AsyncImage(url: URL(string: attachment.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            case "VIDEO":
                if let url = URL(string: attachment.url) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200) // Высота видео
                        .cornerRadius(10)
                } else {
                    Text("Ошибка загрузки видео")
                        .foregroundColor(.red)
                }
            case "AUDIO":
                AudioPlayerView(urlString: attachment.url)
            default:
                Text("Здесь прицепили чтто-то неизвестное")
            }
        }
    }
}
