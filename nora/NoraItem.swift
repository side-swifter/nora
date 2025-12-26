//
//  NoraItem.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/24/25.
//

import Foundation
import SwiftData

enum NoraMode: String, CaseIterable, Codable {
    case inPerson
    case online
}

@Model
final class NoraItem {
    // Stored (SwiftData-friendly)
    var id: UUID
    var title: String
    var startAt: Date
    var endAt: Date?
    var modeRaw: String?
    var locationOrLink: String?
    var notes: String?
    var createdAt: Date

    // Computed (nice for SwiftUI)
    var isEvent: Bool {
        endAt != nil
    }
    
    var isReminder: Bool {
        endAt == nil
    }

    var mode: NoraMode? {
        get {
            guard let modeRaw else { return nil }
            return NoraMode(rawValue: modeRaw)
        }
        set { modeRaw = newValue?.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        startAt: Date,
        endAt: Date? = nil,
        mode: NoraMode? = nil,
        locationOrLink: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.startAt = startAt
        self.endAt = endAt
        self.modeRaw = mode?.rawValue
        self.locationOrLink = locationOrLink
        self.notes = notes
        self.createdAt = createdAt
    }
}
