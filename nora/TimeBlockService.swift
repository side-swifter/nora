//
//  TimeBlockService.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import Foundation

struct TimeBlockDraftItem: Identifiable {
    var id = UUID()
    var title: String
    var startAt: Date
    var endAt: Date?
    
    var isEvent: Bool {
        endAt != nil
    }
}

class TimeBlockService {
    static func makeDraft(for baseDate: Date) -> (transcript: String, items: [TimeBlockDraftItem]) {
        let transcript = "Tomorrow: Gym 7–8, Breakfast 8–8:30, CAD 9–11, Lunch 12:30–1, Meeting 5:30–6, Homework 6–8"
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: baseDate)) ?? baseDate
        
        var items: [TimeBlockDraftItem] = []
        
        if let gymStart = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: tomorrow),
           let gymEnd = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow) {
            items.append(TimeBlockDraftItem(title: "Gym", startAt: gymStart, endAt: gymEnd))
        }
        
        if let breakfastStart = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow),
           let breakfastEnd = calendar.date(bySettingHour: 8, minute: 30, second: 0, of: tomorrow) {
            items.append(TimeBlockDraftItem(title: "Breakfast", startAt: breakfastStart, endAt: breakfastEnd))
        }
        
        if let cadStart = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow),
           let cadEnd = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: tomorrow) {
            items.append(TimeBlockDraftItem(title: "CAD", startAt: cadStart, endAt: cadEnd))
        }
        
        if let lunchStart = calendar.date(bySettingHour: 12, minute: 30, second: 0, of: tomorrow),
           let lunchEnd = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: tomorrow) {
            items.append(TimeBlockDraftItem(title: "Lunch", startAt: lunchStart, endAt: lunchEnd))
        }
        
        if let meetingStart = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: tomorrow),
           let meetingEnd = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow) {
            items.append(TimeBlockDraftItem(title: "Meeting", startAt: meetingStart, endAt: meetingEnd))
        }
        
        if let homeworkStart = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow),
           let homeworkEnd = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: tomorrow) {
            items.append(TimeBlockDraftItem(title: "Homework", startAt: homeworkStart, endAt: homeworkEnd))
        }
        
        return (transcript, items)
    }
}
