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
    /// Filters out GKI values > 9.0
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
                
                // Only include GKI values <= 9.0
                if gki <= 9.0 {
                    results.append((date: glucoseMeasurement.timestamp, gki: gki))
                }
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

/// Chart view specifically for displaying GKI data with tap-to-view functionality
struct GKIChartView: View {
    let gkiData: [(date: Date, gki: Double)]
    
    // MARK: Chart Selection State
    @State private var selectedDate: Date?
    
    /// Find the GKI data point closest to the selected date
    var selectedDataPoint: (date: Date, gki: Double)? {
        guard let selectedDate = selectedDate else { return nil }
        return gkiData.min(by: { abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate)) })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // MARK: Legend and Selected Value Display
            HStack {
                // Updated GKI interpretation guide
                VStack(alignment: .leading, spacing: 4) {
                    gkiLegendItem(color: .green, text: "Therapeutic ketosis: 0.5 to 1.0")
                    gkiLegendItem(color: .yellow, text: "High ketosis: 1.01 to 3.0")
                    gkiLegendItem(color: .orange, text: "Moderate ketosis: 3.01 to 6.0")
                    gkiLegendItem(color: .red, text: "Low ketosis: 6.01 to 9.0")
                }
                .font(.caption2)
                
                Spacer()
                
                // Show selected GKI value when tapping chart
                if let selected = selectedDataPoint {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("GKI: \(selected.gki, specifier: "%.2f")")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(gkiColor(for: selected.gki))
                        Text(selected.date, format: .dateTime.month().day())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Chart display with fixed Y-axis range
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
                
                // Highlight selected point
                if let selectedDataPoint = selectedDataPoint,
                   selectedDataPoint.date == item.date {
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("GKI", item.gki)
                    )
                    .foregroundStyle(gkiColor(for: item.gki))
                    .symbolSize(100)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [1, 3, 6, 9]) {
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYScale(domain: 0.5...9.0)
            .chartXSelection(value: $selectedDate)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns color based on updated GKI value ranges
    private func gkiColor(for gki: Double) -> Color {
        switch gki {
        case 0.5...1.0: return .green      // Therapeutic ketosis
        case 1.01...3.0: return .yellow    // High ketosis
        case 3.01...6.0: return .orange    // Moderate ketosis
        case 6.01...9.0: return .red       // Low ketosis
        default: return .gray              // Outside range (shouldn't happen with filtering)
        }
    }
    
    /// Creates a legend item with colored dot and text
    private func gkiLegendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
        }
    }
}
