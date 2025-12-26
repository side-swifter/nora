//
//  noraApp.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/24/25.
//

import SwiftUI
import SwiftData

@main
struct noraApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            NoraItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Migration failed - delete old container and create fresh one
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

