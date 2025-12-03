//
//  DataManager.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//
import Foundation
import SwiftData

class DataManager {
    static func setupInitialData(context: ModelContext) {
        // Check if we already have data
        let fetchDescriptor = FetchDescriptor<MeasurementType>()
        let existingTypes = try? context.fetch(fetchDescriptor)
        
        if let existingTypes = existingTypes, !existingTypes.isEmpty {
            return // Data already exists
        }
        
        // Create measurement types
        let glucose = MeasurementType(name: "Glucose", unit: "mg/dL", colorHex: "#FF6B6B", emoji: "🩸", isSystemType: true)
        let ketones = MeasurementType(name: "Ketones", unit: "mmol/L", colorHex: "#4ECDC4", emoji: "🔥", isSystemType: true)
        let weight = MeasurementType(name: "Weight", unit: "lbs", colorHex: "#95E1D3", emoji: "⚖️", isSystemType: true)
        
        context.insert(glucose)
        context.insert(ketones)
        context.insert(weight)
        
        // Add some sample measurements for testing
        addSampleMeasurements(context: context, glucose: glucose, ketones: ketones, weight: weight)
        
        try? context.save()
    }
    
    private static func addSampleMeasurements(context: ModelContext, glucose: MeasurementType, ketones: MeasurementType, weight: MeasurementType) {
        let calendar = Calendar.current
        let now = Date()
        
        // Add 14 days of sample data
        for day in 0..<14 {
            if let date = calendar.date(byAdding: .day, value: -day, to: now) {
                // Glucose readings (2 per day)
                let morningGlucose = Measurement(value: Double.random(in: 85...110), timestamp: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: date)!, measurementType: glucose)
                let eveningGlucose = Measurement(value: Double.random(in: 90...115), timestamp: calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date)!, measurementType: glucose)
                
                // Ketone readings (1 per day)
                let ketoneReading = Measurement(value: Double.random(in: 0.5...3.0), timestamp: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date)!, measurementType: ketones)
                
                // Weight (1 per day)
                let weightReading = Measurement(value: Double.random(in: 165...175), timestamp: calendar.date(bySettingHour: 7, minute: 0, second: 0, of: date)!, measurementType: weight)
                
                context.insert(morningGlucose)
                context.insert(eveningGlucose)
                context.insert(ketoneReading)
                context.insert(weightReading)
            }
        }
    }
    
    static func calculateGKI(glucose: Double, ketones: Double) -> Double {
        // GKI = Glucose (mg/dL) ÷ (Ketones (mmol/L) × 18)
        return glucose / (ketones * 18.0)
    }
}
