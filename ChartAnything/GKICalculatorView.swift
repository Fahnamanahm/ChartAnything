//
//  GKICalculatorView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData
import Charts

/// View that automatically calculates and displays GKI (Glucose-Ketone Index)
/// GKI = Glucose (mg/dL) ÷ (Ketones (mmol/L) × 18)
/// This metric is used to track metabolic health and ketosis levels
struct GKICalculatorView: View {
    // MARK: - Queries
    /// Fetch all measurements to find glucose and ketone readings
    @Query private var measurements: [Measurement]
    @Query private var measurementTypes: [MeasurementType]
    
    // MARK: - Date Filtering
    let startDate: Date?
    let endDate: Date
    
    // MARK: - Computed Properties
    
    /// Filter measurements by date range
    var filteredMeasurements: [Measurement] {
        if let start = startDate {
            return measurements.filter { $0.timestamp >= start && $0.timestamp <= endDate }
        }
        return measurements
    }
    
    /// Find the Glucose measurement type
    var glucoseType: MeasurementType? {
        measurementTypes.first { $0.name == "Glucose" }
    }
    
    /// Find the Ketones measurement type
    var ketonesType: MeasurementType? {
        measurementTypes.first { $0.name == "Ketones" }
    }
    
    /// Get all GKI calculations from paired glucose/ketone measurements
    /// Groups measurements by day and calculates GKI for each day
    var gkiData: [(date: Date, gki: Double)] {
        guard let glucoseType = glucoseType,
              let ketonesType = ketonesType else {
            return []
        }
        
        // Get glucose and ketone measurements (filtered by date)
        let glucoseMeasurements = filteredMeasurements.filter { $0.measurementType?.id == glucoseType.id }
        let ketoneMeasurements = filteredMeasurements.filter { $0.measurementType?.id == ketonesType.id }
        
        var results: [(date: Date, gki: Double)] = []
        let calendar = Calendar.current
        
        // For each glucose measurement, find a ketone measurement from the same day
        for glucoseMeasurement in glucoseMeasurements {
            let glucoseDate = calendar.startOfDay(for: glucoseMeasurement.timestamp)
            
            // Find ketone measurement from same day
            if let ketone = ketoneMeasurements.first(where: {
                calendar.startOfDay(for: $0.timestamp) == glucoseDate
            }) {
                // Calculate GKI = Glucose ÷ (Ketones × 18)
                let gki = DataManager.calculateGKI(
                    glucose: glucoseMeasurement.value,
                    ketones: ketone.value
                )
                results.append((date: glucoseMeasurement.timestamp, gki: gki))
            }
        }
        
        return results.sorted { $0.date < $1.date }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // MARK: Header
            HStack {
                Text("GKI")
                    .font(.headline)
                Text("(Glucose-Ketone Index)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // MARK: GKI Chart or Empty State
            if gkiData.isEmpty {
                // Show message if no GKI data available
                Text("Add glucose and ketone measurements on the same day to see GKI")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                // Display GKI chart
                GKIChartView(gkiData: gkiData)
            }
        }
        .padding()
    }
}

/// Chart view specifically for displaying GKI data
struct GKIChartView: View {
    let gkiData: [(date: Date, gki: Double)]
    
    var body: some View {
        VStack(alignment: .leading) {
            // GKI interpretation guide
            HStack(spacing: 15) {
                gkiLegendItem(color: .green, range: "< 3", meaning: "Therapeutic")
                gkiLegendItem(color: .yellow, range: "3-6", meaning: "Moderate")
                gkiLegendItem(color: .orange, range: "6-9", meaning: "Low")
                gkiLegendItem(color: .red, range: "> 9", meaning: "High")
            }
            .font(.caption2)
            
            // Chart display
            Chart(gkiData, id: \.date) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("GKI", item.gki)
                )
                .foregroundStyle(gkiColor(for: item.gki))
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", item.date),
                    y: .value("GKI", item.gki)
                )
                .foregroundStyle(gkiColor(for: item.gki))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns color based on GKI value ranges
    private func gkiColor(for gki: Double) -> Color {
        switch gki {
        case ..<3: return .green      // Therapeutic ketosis
        case 3..<6: return .yellow    // Moderate
        case 6..<9: return .orange    // Low ketosis
        default: return .red          // High (not in ketosis)
        }
    }
    
    /// Creates a legend item showing GKI range and interpretation
    private func gkiLegendItem(color: Color, range: String, meaning: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 0) {
                Text(range)
                    .bold()
                Text(meaning)
            }
        }
    }
}
