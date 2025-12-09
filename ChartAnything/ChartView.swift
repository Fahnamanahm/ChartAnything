//
//  ChartView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import Charts

/// Displays a customizable chart for a measurement type
/// Supports lines, points, custom colors, sizes, and tap-to-view values
struct ChartView: View {
    let measurementType: MeasurementType
    let measurements: [Measurement]
    
    // MARK: Customization Options
    let pointSize: Double
    let pointColor: Color
    let showDataPoints: Bool
    let showLine: Bool
    let lineColor: Color
    let lineWidth: Double
    
    // MARK: Chart Selection State
    @State private var selectedDate: Date?
    
    /// Measurements sorted by timestamp (oldest to newest)
    var sortedMeasurements: [Measurement] {
        measurements.sorted { $0.timestamp < $1.timestamp }
    }
    
    /// Calculate Y-axis range with smart padding (20% of range, minimum 2 units, floor at 0)
        var yAxisRange: (min: Double, max: Double) {
            guard !sortedMeasurements.isEmpty else {
                return (0, 100)
            }
            
            let values = sortedMeasurements.map { $0.value }
            let minValue = values.min() ?? 0
            let maxValue = values.max() ?? 100
            
            // Calculate 20% padding with minimum of 2 units
            let range = maxValue - minValue
            let padding = max(range * 0.2, 2.0)
            
            // Never go below 0, add padding above
            return (min: max(0, minValue - padding), max: maxValue + padding)
        }
    
    /// Find the measurement closest to the selected date
    var selectedMeasurement: Measurement? {
        guard let selectedDate = selectedDate else { return nil }
        return sortedMeasurements.min(by: { abs($0.timestamp.timeIntervalSince(selectedDate)) < abs($1.timestamp.timeIntervalSince(selectedDate)) })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
                    // ┌─────────────────────────────────────────────────────────────┐
                    // │ SELECTED VALUE DISPLAY (when tapping chart)                │
                    // │ Title removed - now shown in ChartHeaderView               │
                    // └─────────────────────────────────────────────────────────────┘
                    HStack {
                        Spacer()
                        
                        // ↓↓↓ Show selected value when user taps on chart
                        if let selected = selectedMeasurement {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(selected.value, specifier: "%.1f") \(measurementType.unit)")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(lineColor)
                                Text(selected.timestamp, format: .dateTime.month().day().hour().minute())
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
            
            // MARK: Chart Display
            Chart(sortedMeasurements) { measurement in
                // Show line if enabled
                if showLine {
                    LineMark(
                        x: .value("Time", measurement.timestamp),
                        y: .value(measurementType.unit, measurement.value)
                    )
                    .foregroundStyle(lineColor)
                    .lineStyle(StrokeStyle(lineWidth: lineWidth))
                    .interpolationMethod(.catmullRom)
                }
                
                // Show data points as colored dots
                if showDataPoints {
                    PointMark(
                        x: .value("Time", measurement.timestamp),
                        y: .value(measurementType.unit, measurement.value)
                    )
                    .foregroundStyle(pointColor)
                    .symbolSize(pointSize * 10)
                }
                
                // Highlight selected point
                if let selectedMeasurement = selectedMeasurement,
                   selectedMeasurement.id == measurement.id {
                    PointMark(
                        x: .value("Time", measurement.timestamp),
                        y: .value(measurementType.unit, measurement.value)
                    )
                    .foregroundStyle(lineColor)
                    .symbolSize(100)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYScale(domain: yAxisRange.min...yAxisRange.max)
            .chartXSelection(value: $selectedDate)
        }
        .padding()
    }
}
