//
//  LoginView.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import SwiftUI
import PhotosUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var login: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var isLoginMode: Bool = true
    @State private var selectedAvatar: UIImage?
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        ScrollView {
            VStack {
                Text(isLoginMode ? "Вход" : "Регистрация")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Логин", text: $login)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                SecureField("Пароль", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                if !isLoginMode {
                    TextField("Имя", text: $name)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    AvatarPicker(selectedImage: $selectedAvatar)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
                
                Button(action: handleAuthAction) {
                    Text(isLoginMode ? "Войти" : "Зарегистрироваться")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)
                
                Button(action: { isLoginMode.toggle() }) {
                    Text(isLoginMode ? "Создать аккаунт" : "Уже есть аккаунт? Войти")
                        .foregroundColor(.blue)
                        .padding()
                }
                
                if isLoading {
                    ProgressView()
                        .padding(.top)
                }
                
                HStack {
                    Button("сбросить ключ", systemImage: "server.rack") {
                        authViewModel.setApiKey(value: "")
                    }
                    .padding()
                    Spacer()
                }
                
                Spacer()
            }
        }
        .padding()
        .keyboardDismissToolbar()
    }
    
    private func handleAuthAction() {
        Utils.hideKeyboard()
        guard !login.isEmpty, !password.isEmpty else {
            authViewModel.errorMessage = "Введите логин и пароль"
            return
        }

        Task {
            if isLoginMode {
                await authViewModel.authenticate(login: login, password: password)
            } else {
                await authViewModel.register(
                    login: login,
                    password: password,
                    name: name,
                    avatar: selectedAvatar?.jpegData(compressionQuality: 0.8)
                )
            }
        }
    }
}
