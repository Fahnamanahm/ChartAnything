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
    // ┌─────────────────────────────────────────────────────────────┐
    // │ SHARED MODEL CONTAINER                                      │
    // │ Creates the SwiftData storage for all app data              │
    // └─────────────────────────────────────────────────────────────┘
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MeasurementType.self,
            Measurement.self,
            ChartConfiguration.self,
            ChartCustomizationModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // ✅ CALL setupInitialData on first launch to create default measurement types
            DataManager.setupInitialData(context: container.mainContext)
            
            return container
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
