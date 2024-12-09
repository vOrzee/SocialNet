//
//  AudioPlayerView.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    let urlString: String
    @State private var isPlaying = false
    @State private var audioPlayer: AVPlayer?

    var body: some View {
        HStack {
            Button(action: togglePlayPause) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
            }
            Text("Аудиозапись")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .onAppear {
            if let url = URL(string: urlString) {
                audioPlayer = AVPlayer(url: url)
            }
        }
        .onDisappear {
            audioPlayer?.pause()
        }
    }

    private func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}
