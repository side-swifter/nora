//
//  AIClient.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import Foundation

enum AIClientError: Error {
    case missingAPIKey
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case httpError(Int, String)
}

class AIClient {
    private let baseURL = "https://api.aimlapi.com/v1/chat/completions"
    private let model = "anthropic/claude-opus-4-5"
    
    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "AIML_API_KEY") as? String
    }
    
    func generatePlan(transcript: String, referenceDate: Date) async throws -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty, apiKey != "your_aiml_api_key_here" else {
            throw AIClientError.missingAPIKey
        }
        
        guard let url = URL(string: baseURL) else {
            throw AIClientError.invalidURL
        }
        
        let systemPrompt = """
        You are Nora, a scheduling assistant. Parse the user's natural language input into a structured daily schedule.
        
        Rules:
        - Single-day plan only
        - Default start time: 9:00 AM if missing
        - Default duration: 60 minutes if not specified
        - Sequential blocks (no overlaps)
        - Times must be realistic (start < end)
        - Output ONLY valid JSON matching the schema
        - No prose, no explanations
        
        Reference date: \(formatDate(referenceDate))
        """
        
        let jsonSchema: [String: Any] = [
            "type": "object",
            "properties": [
                "blocks": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "title": ["type": "string"],
                            "start_time": ["type": "string", "description": "HH:mm format"],
                            "end_time": ["type": "string", "description": "HH:mm format"]
                        ],
                        "required": ["title", "start_time", "end_time"],
                        "additionalProperties": false
                    ]
                ]
            ],
            "required": ["blocks"],
            "additionalProperties": false
        ]
        
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 2048,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": transcript]
            ],
            "response_format": [
                "type": "json_schema",
                "json_schema": [
                    "name": "schedule_plan",
                    "strict": true,
                    "schema": jsonSchema
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIClientError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIClientError.httpError(httpResponse.statusCode, errorMessage)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIClientError.invalidResponse
        }
        
        return content
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd (EEEE)"
        return formatter.string(from: date)
    }
}
