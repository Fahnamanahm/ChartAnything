//
//  ChartCustomizationView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData

/// View for customizing chart appearance
/// Allows users to control lines, points, colors, and sizes
struct ChartCustomizationView: View {
    @Environment(\.dismiss) private var dismiss
    
    let measurementType: MeasurementType
    @Binding var pointSize: Double
    @Binding var pointColor: Color
    @Binding var showDataPoints: Bool
    @Binding var showLine: Bool
    @Binding var lineColor: Color
    @Binding var lineWidth: Double
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Line Settings
                Section("Line") {
                    Toggle("Show Line", isOn: $showLine)
                    
                    if showLine {
                        ColorPicker("Line Color", selection: $lineColor)
                        
                        VStack(alignment: .leading) {
                            Text("Line Width: \(String(format: "%.1f", lineWidth))")
                            Slider(value: $lineWidth, in: 1...10, step: 0.5)
                        }
                    }
                }
                
                // MARK: Point Settings
                Section("Data Points") {
                    Toggle("Show Data Points", isOn: $showDataPoints)
                    
                    if showDataPoints {
                        ColorPicker("Point Color", selection: $pointColor)
                        
                        VStack(alignment: .leading) {
                            Text("Point Size: \(String(format: "%.0f", pointSize))")
                            Slider(value: $pointSize, in: 4...20, step: 1)
                        }
                    }
                }
                
                // MARK: Preview
                Section("Preview") {
                    ChartView(
                        measurementType: measurementType,
                        measurements: measurementType.measurements,
                        pointSize: pointSize,
                        pointColor: pointColor,
                        showDataPoints: showDataPoints,
                        showLine: showLine,
                        lineColor: lineColor,
                        lineWidth: lineWidth
                    )
                    .frame(height: 250)
                }
            }
            .navigationTitle("\(measurementType.name) Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ChartCustomizationView(
        measurementType: MeasurementType(name: "Test", unit: "units"),
        pointSize: .constant(8),
        pointColor: .constant(.blue),
        showDataPoints: .constant(true),
        showLine: .constant(true),
        lineColor: .constant(.blue),
        lineWidth: .constant(2)
    )
    .modelContainer(for: [MeasurementType.self, Measurement.self], inMemory: true)
}
