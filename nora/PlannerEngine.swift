//
//  PlannerEngine.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import Foundation

class PlannerEngine {
    func generatePlan(rawText: String, referenceDate: Date) -> [TimeBlockDraftItem] {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: referenceDate)
        
        let blocks: [(title: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int)] = [
            ("Gym", 7, 0, 8, 0),
            ("Breakfast", 8, 0, 8, 30),
            ("CAD Work", 9, 0, 11, 0),
            ("Lunch", 12, 30, 13, 0),
            ("Team Meeting", 17, 30, 18, 0),
            ("Homework", 18, 0, 20, 0)
        ]
        
        return blocks.compactMap { block in
            guard let startDate = calendar.date(bySettingHour: block.startHour, minute: block.startMinute, second: 0, of: baseDate),
                  let endDate = calendar.date(bySettingHour: block.endHour, minute: block.endMinute, second: 0, of: baseDate) else {
                return nil
            }
            
            return TimeBlockDraftItem(
                title: block.title,
                startAt: startDate,
                endAt: endDate
            )
        }
    }
}
