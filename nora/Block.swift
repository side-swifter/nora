//
//  Block.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/24/25.
//

import Foundation
import SwiftData

enum ItemKind: String, Codable {
    case event
    case reminder
}

enum EventMode: String, Codable {
    case inPerson
    case online
}

@Model
final class Block {
    var id: UUID
    var title: String
    var kind: ItemKind
    var scheduledAt: Date
    var eventMode: EventMode?
    var locationOrLink: String?
    var notes: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        kind: ItemKind,
        scheduledAt: Date,
        eventMode: EventMode? = nil,
        locationOrLink: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.scheduledAt = scheduledAt
        self.eventMode = eventMode
        self.locationOrLink = locationOrLink
        self.notes = notes
        self.createdAt = createdAt
    }
}
