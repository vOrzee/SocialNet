//
//  ApiView.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

struct ApiView: View {
    
    @State var key: String = ""
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("Закрытое тестирование")
                .font(.title2)
                .padding()
            TextField("API-key", text: $key)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            Button {
                authViewModel.setApiKey(value: key)
            } label: {
                Text("Вперёд!")
            }
            Spacer()
        }
        .padding()
        .keyboardDismissToolbar()
    }
}

