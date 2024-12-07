//
//  AvatarPicker.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import SwiftUI
import PhotosUI

struct AvatarPicker: View {
    @Binding var selectedImage: UIImage?
    @State private var isPickerPresented: Bool = false

    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .padding()
            } else {
                Button(action: { isPickerPresented = true }) {
                    Text("Выбрать аватар")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}
