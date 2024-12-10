//
//  DataCreator.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//
import Foundation
import KeychainSwift

struct DataCreator {
    static let baseURL = URL(string: "http://94.228.125.136:8080")!
    private static let keychain = KeychainSwift()
    
    private static var apiKey: String {
        keychain.get("apiKey") ?? ""
    }

    private static var authToken: String {
        keychain.get("authToken") ?? ""
    }
    
    static func buildRequest(pathStringUrl: String, stringMethod: String, queryItems: [String: String] = [:], body: [String: Any]? = nil) -> URLRequest? {
        var components = URLComponents(url: baseURL.appendingPathComponent(pathStringUrl), resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = stringMethod
        request.addValue(apiKey, forHTTPHeaderField: "Api-Key")
        
        if !authToken.isEmpty {
            request.addValue(authToken, forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                print("Ошибка сериализации JSON: \(error)")
                return nil
            }
        }
        return request
    }
    
    static func createMultipartBody(
        parameters: [String: String],
        fileData: Data?,
        fileName: String,
        mimeType: String,
        boundary: String
    ) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        if let fileData = fileData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    static func createUploadRequest(fileData: Data, fileName: String, boundary: String) -> URLRequest? {
        let url = URL(string: "http://94.228.125.136:8080/api/media")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Заголовки
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "Api-Key")
        if !authToken.isEmpty {
            request.addValue(authToken, forHTTPHeaderField: "Authorization")
        }

        // Тело запроса
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        return request
    }
}

//struct Fetcher {

//    static func fetch<T: Decodable>(
//        pathStringUrl: String,
//        stringMethod: String,
//        queryItems: [String: String] = [:],
//        body: [String: Any]? = nil,
//        decodeTo type: T.Type
//    ) async throws -> T {
//        guard let request = buildRequest(
//            pathStringUrl: pathStringUrl,
//            stringMethod: stringMethod,
//            queryItems: queryItems,
//            body: body
//        ) else {
//            throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Не удалось построить запрос"])
//        }
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NSError(domain: "InvalidResponse", code: 500, userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ сервера"])
//        }
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//            if let responseBody = String(data: data, encoding: .utf8) {
//                print("Ошибка сервера: \(responseBody)")
//            }
//            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка: \(httpResponse.statusCode)"])
//        }
//
//        do {
//            let decoder = JSONDecoder.withCustomDateDecoding()
//            return try decoder.decode(T.self, from: data)
//        } catch {
//            throw NSError(domain: "DecodingError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ошибка декодирования: \(error)"])
//        }
//    }
//
//    static func fetchMultipart<T: Decodable>(
//        pathStringUrl: String,
//        stringMethod: String,
//        parameters: [String: String],
//        fileData: Data?,
//        fileName: String,
//        mimeType: String,
//        decodeTo type: T.Type
//    ) async throws -> T {
//        let boundary = "Boundary-\(UUID().uuidString)"
//        guard var request = buildRequest(
//            pathStringUrl: pathStringUrl,
//            stringMethod: stringMethod
//        ) else {
//            throw NSError(domain: "InvalidRequest", code: 400, userInfo: [NSLocalizedDescriptionKey: "Не удалось построить запрос"])
//        }
//
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        request.httpBody = createMultipartBody(
//            parameters: parameters,
//            fileData: fileData,
//            fileName: fileName,
//            mimeType: mimeType,
//            boundary: boundary
//        )
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw NSError(domain: "InvalidResponse", code: 500, userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ сервера"])
//        }
//
//        guard (200...299).contains(httpResponse.statusCode) else {
//            if let responseBody = String(data: data, encoding: .utf8) {
//                print("Ошибка сервера: \(responseBody)")
//            }
//            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка: \(httpResponse.statusCode)"])
//        }
//
//        do {
//            let decoder = JSONDecoder.withCustomDateDecoding()
//            return try decoder.decode(T.self, from: data)
//        } catch {
//            throw NSError(domain: "DecodingError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ошибка декодирования: \(error)"])
//        }
//    }
//}
