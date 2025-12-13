//
//  DataManager.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//
import Foundation
import SwiftData

class DataManager {
    // ┌─────────────────────────────────────────────────────────────┐
    // │ SETUP INITIAL DATA                                          │
    // │ Creates default measurement types on first app launch       │
    // │ Glucose, Ketones, Weight are marked as system types         │
    // │ (cannot be deleted by user)                                 │
    // └─────────────────────────────────────────────────────────────┘
    static func setupInitialData(context: ModelContext) {
        // Check if we already have data
        let fetchDescriptor = FetchDescriptor<MeasurementType>()
        let existingTypes = try? context.fetch(fetchDescriptor)
        
        if let existingTypes = existingTypes, !existingTypes.isEmpty {
            return // Data already exists
        }
        
        // ┌─────────────────────────────────────────────────────────┐
        // │ CREATE DEFAULT MEASUREMENT TYPES                        │
        // │ These are always present and cannot be deleted          │
        // └─────────────────────────────────────────────────────────┘
        let glucose = MeasurementType(
            name: "Glucose",
            unit: "mg/dL",
            colorHex: "FF6B6B",  // Red
            emoji: "🩸"
        )
        
        let ketones = MeasurementType(
            name: "Ketones",
            unit: "mmol/L",
            colorHex: "4ECDC4",  // Teal
            emoji: "🔥"
        )
        
        let weight = MeasurementType(
            name: "Weight",
            unit: "Lbs",
            colorHex: "95E1D3",  // Light green
            emoji: "⚖️"
        )
        
        context.insert(glucose)
        context.insert(ketones)
        context.insert(weight)
        
        try? context.save()
    }
    
    // ┌─────────────────────────────────────────────────────────────┐
    // │ CALCULATE GKI                                               │
    // │ Formula: Glucose (mg/dL) ÷ (Ketones (mmol/L) × 18)         │
    // └─────────────────────────────────────────────────────────────┘
    static func calculateGKI(glucose: Double, ketones: Double) -> Double {
        return glucose / (ketones * 18.0)
    }
}
