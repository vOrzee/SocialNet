//
//  ViewExtensions.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import SwiftUI

extension View {
    func keyboardDismissToolbar() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(action: {
                    Utils.hideKeyboard()
                }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                }
            }
        }
    }
}
