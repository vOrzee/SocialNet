//
//  AppSetting.swift
//  SocialNet
//
//  Created by Роман Лешин on 09.12.2024.
//

import SwiftUI

class AppSettings: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
}
