//
//  AIService.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import Foundation

enum AIServiceError: LocalizedError {
    case missingAPIKey
    case networkError(Error)
    case serverError(statusCode: Int, body: String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "AIML_API_KEY not found in Info.plist or is invalid"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode, let body):
            let snippet = body.prefix(200)
            return "Server error (\(statusCode)): \(snippet)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

final class AIService {
    private let model = "claude-sonnet-4-5"
    private let endpoint = "https://api.aimlapi.com/v1/chat/completions"
    
    private func getAPIKey() throws -> String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "AIML_API_KEY") as? String,
              !key.isEmpty,
              !key.hasPrefix("$(") else {
            throw AIServiceError.missingAPIKey
        }
        return key
    }
    
    func ping() async throws -> String {
        let apiKey = try getAPIKey()
        
        guard let url = URL(string: endpoint) else {
            throw AIServiceError.networkError(NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 24,
            "temperature": 0,
            "messages": [
                ["role": "user", "content": "ping"]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw AIServiceError.networkError(error)
        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIServiceError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.networkError(NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"]))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let bodyText = String(data: data, encoding: .utf8) ?? "<no body>"
            throw AIServiceError.serverError(statusCode: httpResponse.statusCode, body: bodyText)
        }
        
        struct ChatResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String?
                }
                let message: Message
            }
            let choices: [Choice]
        }
        
        let decoded: ChatResponse
        do {
            decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        } catch {
            throw AIServiceError.decodingError(error)
        }
        
        return decoded.choices.first?.message.content ?? "<empty>"
    }
}
