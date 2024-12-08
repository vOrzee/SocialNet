//
//  DataCreator.swift
//  SocialNet
//
//  Created by Роман Лешин on 07.12.2024.
//

import Foundation

struct DataCreator {
    static let baseURL = URL(string: "http://94.228.125.136:8080")!
    
    static func buildRequest(pathStringUrl: String, stringMethod: String, queryItems: [String: String] = [:], body: [String: Any]? = nil) -> URLRequest? {
        var components = URLComponents(url: baseURL.appendingPathComponent(pathStringUrl), resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = stringMethod
        request.addValue(AuthService.shared.apiKey, forHTTPHeaderField: "Api-Key")
        request.addValue(AuthService.shared.authToken, forHTTPHeaderField: "Authorization")

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
}
