//
//  ChartView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import Charts

/// Displays a customizable chart for a measurement type
/// Supports lines, points, custom colors, and sizes
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
    
    /// Measurements sorted by timestamp (oldest to newest)
    var sortedMeasurements: [Measurement] {
        measurements.sorted { $0.timestamp < $1.timestamp }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            // MARK: Chart Title
            Text(measurementType.name)
                .font(.headline)
            
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
                    .symbolSize(pointSize * 10) // Scale up for visibility
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
        }
        .padding()
    }
}
