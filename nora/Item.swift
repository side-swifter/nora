//
//  Item.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/24/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var text: String
    var createdAt: Date
    
    init(text: String, createdAt: Date = Date()) {
        self.text = text
        self.createdAt = createdAt
    }
}
