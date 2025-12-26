//
//  PlannerEngine.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import Foundation

struct DraftItemDTO: Codable {
    let title: String
    let start_time: String
    let end_time: String
}

struct SchedulePlanResponse: Codable {
    let blocks: [DraftItemDTO]
}

enum PlannerError: Error {
    case aiError(AIClientError)
    case invalidJSON
    case invalidTimeFormat
    case invalidTimeRange
    case overlappingBlocks
}

class PlannerEngine {
    private let aiClient = AIClient()
    
    func generatePlan(rawText: String, referenceDate: Date, timezone: TimeZone = .current) async throws -> [TimeBlockDraftItem] {
        let jsonString: String
        
        do {
            jsonString = try await aiClient.generatePlan(transcript: rawText, referenceDate: referenceDate)
        } catch let error as AIClientError {
            throw PlannerError.aiError(error)
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw PlannerError.invalidJSON
        }
        
        let response: SchedulePlanResponse
        do {
            response = try JSONDecoder().decode(SchedulePlanResponse.self, from: jsonData)
        } catch {
            throw PlannerError.invalidJSON
        }
        
        var draftItems: [TimeBlockDraftItem] = []
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: referenceDate)
        
        for dto in response.blocks {
            guard let startDate = parseTime(dto.start_time, baseDate: baseDate, calendar: calendar),
                  let endDate = parseTime(dto.end_time, baseDate: baseDate, calendar: calendar) else {
                throw PlannerError.invalidTimeFormat
            }
            
            guard startDate < endDate else {
                throw PlannerError.invalidTimeRange
            }
            
            let item = TimeBlockDraftItem(
                title: dto.title,
                startAt: startDate,
                endAt: endDate
            )
            draftItems.append(item)
        }
        
        try validateNoOverlaps(draftItems)
        
        return draftItems
    }
    
    private func parseTime(_ timeString: String, baseDate: Date, calendar: Calendar) -> Date? {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              hour >= 0, hour < 24,
              minute >= 0, minute < 60 else {
            return nil
        }
        
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: baseDate)
    }
    
    private func validateNoOverlaps(_ items: [TimeBlockDraftItem]) throws {
        let sorted = items.sorted { $0.startAt < $1.startAt }
        
        for i in 0..<sorted.count - 1 {
            let current = sorted[i]
            let next = sorted[i + 1]
            
            if let currentEnd = current.endAt, currentEnd > next.startAt {
                throw PlannerError.overlappingBlocks
            }
        }
    }
}
