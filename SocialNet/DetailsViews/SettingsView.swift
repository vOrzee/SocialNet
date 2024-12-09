//
//  SettingsView.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var faceIDViewModel = FaceIDViewModel()
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тема")) {
                    Toggle("Тёмный режим", isOn: $appSettings.isDarkMode)
                }

                Section(header: Text("Face ID")) {
                    Toggle("Использовать Face ID", isOn: $faceIDViewModel.isFaceIDEnabled)
                        .onChange(of: faceIDViewModel.isFaceIDEnabled) { oldValue, _ in
                            faceIDViewModel.errorMessage = nil // Сбрасываем предыдущие ошибки
                            if oldValue { // Пользователь пытается отключить Face ID
                                Task {
                                    await faceIDViewModel.authenticate() // Запускаем аутентификацию
                                    if !faceIDViewModel.isAuthenticated {
                                        faceIDViewModel.isFaceIDEnabled = true // Возвращаем старое значение, если аутентификация не удалась
                                    }
                                }
                            }
                        }

                    if let errorMessage = faceIDViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Настройки")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

