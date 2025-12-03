//
//  ChartAnythingApp.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData

@main
struct ChartAnythingApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MeasurementType.self,
            Measurement.self,
            ChartConfiguration.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
