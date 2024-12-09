//
//  FaceIDViewModel.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

import SwiftUI
import LocalAuthentication

@MainActor // Гарантирует выполнение в главном потоке
class FaceIDViewModel: ObservableObject {
    @Published var isFaceIDEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isFaceIDEnabled, forKey: "isFaceIDEnabled")
        }
    }
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    private var context = LAContext() // Контекст для работы с Face ID

    init() {
        self.isFaceIDEnabled = UserDefaults.standard.bool(forKey: "isFaceIDEnabled")
    }

    func authenticate() async {
        // Сбрасываем ошибки
        errorMessage = nil
        isAuthenticated = false

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = "Face ID не доступен на этом устройстве."
            return
        }

        let reason = "Для входа в аккаунт используйте Face ID"

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            isAuthenticated = success
            errorMessage = nil
        } catch {
            isAuthenticated = false
            errorMessage = error.localizedDescription
        }
    }

    func resetContext() {
        context = LAContext()
    }
}

