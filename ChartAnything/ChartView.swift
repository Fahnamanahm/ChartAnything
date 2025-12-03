//
//  Untitled.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//
import SwiftUI
import Charts

struct ChartView: View {
    let measurementType: MeasurementType
    let measurements: [Measurement]
    let useEmoji: Bool
    let emojiSymbol: String?
    let lineColor: Color
    
    var sortedMeasurements: [Measurement] {
        measurements.sorted { $0.timestamp < $1.timestamp }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(measurementType.name)
                .font(.headline)
            
            Chart(sortedMeasurements) { measurement in
                if useEmoji, let emoji = emojiSymbol {
                    PointMark(
                        x: .value("Time", measurement.timestamp),
                        y: .value(measurementType.unit, measurement.value)
                    )
                    .annotation {
                        Text(emoji)
                            .font(.caption)
                    }
                } else {
                    LineMark(
                        x: .value("Time", measurement.timestamp),
                        y: .value(measurementType.unit, measurement.value)
                    )
                    .foregroundStyle(lineColor)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Time", measurement.timestamp),
                        y: .value(measurementType.unit, measurement.value)
                    )
                    .foregroundStyle(lineColor)
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
