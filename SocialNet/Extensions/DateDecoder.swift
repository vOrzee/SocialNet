//
//  DateDecoder.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import Foundation

extension JSONDecoder {
    static func withCustomDateDecoding() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Пробуем с миллисекундами
            let formatterWithMilliseconds = ISO8601DateFormatter()
            formatterWithMilliseconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatterWithMilliseconds.date(from: dateString) {
                return date
            }

            // Пробуем без миллисекунд
            let formatterWithoutMilliseconds = ISO8601DateFormatter()
            formatterWithoutMilliseconds.formatOptions = [.withInternetDateTime]
            if let date = formatterWithoutMilliseconds.date(from: dateString) {
                return date
            }

            // Пробуем стандартный формат
            let standardFormatter = DateFormatter()
            standardFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = standardFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        return decoder
    }
}
