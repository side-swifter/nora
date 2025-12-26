//
//  DraftBlock.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/25/25.
//

import Foundation

struct DraftBlock: Identifiable {
    let id = UUID()
    var title: String
    var startAt: Date
    var endAt: Date?
    
    var isEvent: Bool {
        endAt != nil
    }
}

// MARK: - Stub Parser (v0)
func generateDraftPlan(from transcript: String, referenceDate: Date) -> [DraftBlock] {
    // v0: Ignore transcript, return fixed plan for tomorrow
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: referenceDate)) ?? referenceDate
    
    var blocks: [DraftBlock] = []
    
    // Gym: 7:00 AM - 8:00 AM
    if let gymStart = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: tomorrow),
       let gymEnd = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow) {
        blocks.append(DraftBlock(title: "Gym", startAt: gymStart, endAt: gymEnd))
    }
    
    // Breakfast: 8:00 AM - 8:30 AM
    if let breakfastStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow),
       let breakfastEnd = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: tomorrow) {
        blocks.append(DraftBlock(title: "Breakfast", startAt: breakfastStart, endAt: breakfastEnd))
    }
    
    // CAD: 9:00 AM - 11:00 AM
    if let cadStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow),
       let cadEnd = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: tomorrow) {
        blocks.append(DraftBlock(title: "CAD", startAt: cadStart, endAt: cadEnd))
    }
    
    // Lunch: 12:30 PM - 1:00 PM
    if let lunchStart = calendar.date(bySettingHour: 12, minute: 30, second: 0, of: tomorrow),
       let lunchEnd = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: tomorrow) {
        blocks.append(DraftBlock(title: "Lunch", startAt: lunchStart, endAt: lunchEnd))
    }
    
    // Meeting: 5:30 PM - 6:00 PM
    if let meetingStart = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: tomorrow),
       let meetingEnd = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow) {
        blocks.append(DraftBlock(title: "Meeting", startAt: meetingStart, endAt: meetingEnd))
    }
    
    // Homework: 6:00 PM - 8:00 PM
    if let homeworkStart = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow),
       let homeworkEnd = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: tomorrow) {
        blocks.append(DraftBlock(title: "Homework", startAt: homeworkStart, endAt: homeworkEnd))
    }
    
    return blocks
}
