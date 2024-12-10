//
//  AddPostView.swift
//  SocialNet
//
//  Created by Роман Лешин on 10.12.2024.
//


import SwiftUI
import PhotosUI
import MediaPlayer


struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Данные поста
    @State private var postText: String = ""
    @State private var attachmentType: String? = nil
    @State private var attachmentData: Data? = nil
    @State private var link: String = ""
    @State private var coordinates: Coordinates? = nil
    @ObservedObject var postsViewModel: PostsViewModel
    
    // Выбор медиа
    @State private var showMediaPicker = false
    @State private var showMapView = false
    @State private var selectedMediaType: UTType? = nil
    @State private var audioData: Data? = nil
    @State private var showAudioPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Текст поста")) {
                    TextEditor(text: $postText)
                        .frame(height: 150)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                }
                
                Section(header: Text("Медиа")) {
                    Picker("Тип вложения", selection: $attachmentType) {
                        Text("Нет").tag(nil as String?)
                        Text("Картинка").tag("IMAGE")
                        Text("Видео").tag("VIDEO")
                        Text("Аудио").tag("AUDIO")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: attachmentType) { _, newValue in
                        requestMediaLibraryAccess { granted in
                            if granted {
                                if newValue == "AUDIO" {
                                    showAudioPicker = true
                                } else if newValue != nil {
                                    showMediaPicker = true
                                } else {
                                    attachmentData = nil
                                }
                            } else {
                                print("Доступ к медиатеке не разрешен.")
                            }
                        }
                    }
                }
                
                Section(header: Text("Ссылка")) {
                    TextField("Введите ссылку", text: $link)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                Section(header: Text("Геометка")) {
                    Button("Добавить геометку") {
                        showMapView = true
                    }
                    if let coordinates {
                        Text("Координаты: \(coordinates.lat), \(coordinates.long)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Добавить пост")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        savePost()
                    }
                    .disabled(postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showMediaPicker) {
                PhotosPickerView(selectedMediaType: $selectedMediaType, attachmentData: $attachmentData)
            }
            .sheet(isPresented: $showMapView) {
                MapView($coordinates)
            }
            .sheet(isPresented: $showAudioPicker) {
                AudioPickerView(audioData: $audioData)
            }

        }
    }
    
    private func savePost() {
        Task {
            var attachment: Attachment? = nil
            if let attachmentData {
                let mediaUrl = await postsViewModel.upload(attachmentData)
                if let attachmentType, let mediaUrl {
                    attachment = Attachment(url: mediaUrl, type: attachmentType)
                }
            }
            let newPost = Post(
                id: 0,
                authorId: 0,
                author: "string",
                authorAvatar: nil,
                content: postText,
                published: Date(),
                likedByMe: false,
                likeOwnerIds: [],
                attachment: attachment,
                coords: coordinates,
                link: link
            )
            await postsViewModel.addPost(post: newPost)
            dismiss()
        }
    }
    
    private func requestMediaLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            MPMediaLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized)
                }
            }
        case .authorized:
            completion(true)
        default:
            completion(false)
        }
    }
}

