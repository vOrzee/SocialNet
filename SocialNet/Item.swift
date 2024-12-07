//
//  Item.swift
//  SocialNet
//
//  Created by Роман Лешин on 06.12.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
