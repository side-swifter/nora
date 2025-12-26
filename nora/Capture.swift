//
//  Capture.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/24/25.
//

import Foundation
import SwiftData

@Model
final class Capture {
    var id: UUID
    var text: String
    var createdAt: Date
    var source: String
    var isProcessed: Bool
    
    init(id: UUID = UUID(), text: String, createdAt: Date = Date(), source: String = "manual", isProcessed: Bool = false) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.source = source
        self.isProcessed = isProcessed
    }
}
