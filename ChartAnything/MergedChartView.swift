//
//  MergedChartView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData
import Charts

struct MergedMeasurementConfig {
    var showLine: Bool = true
    var lineColor: Color = .blue
    var lineWidth: Double = 2.0
    var showPoints: Bool = true
    var pointColor: Color = .blue
    var pointSize: Double = 8.0
}
struct MergedChartView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var measurementTypes: [MeasurementType]
    @Query private var measurements: [Measurement]
    
    @State private var selectedTypes: [UUID] = []
    @State private var measurementConfigs: [UUID: MergedMeasurementConfig] = [:]
    @State private var expandedTypes: Set<UUID> = []
    @State private var selectedDateFilter: DateRangeFilter = .allTime
    @State private var customStartDate: Date = Date()
    @State private var customEndDate: Date = Date()
    @State private var showingDateRangePicker = false
    
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Measurements to Merge")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(measurementTypes.filter { !$0.measurements.isEmpty }, id: \.id) { type in
                                Button {
                                    if selectedTypes.contains(type.id) {
                                        selectedTypes.removeAll { $0 == type.id }
                                    } else {
                                        selectedTypes.append(type.id)
                                        let color = Color(hex: type.colorHex) ?? .blue
                                        measurementConfigs[type.id] = MergedMeasurementConfig(
                                            lineColor: color,
                                            pointColor: color
                                        )
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: selectedTypes.contains(type.id) ? "checkmark.circle.fill" : "circle")
                                        Text(type.name)
                                        Spacer()
                                    }
                                    .padding()
                                }
                            }
                        }
                        
                        if selectedTypes.count == 2 {
                                                let type1 = measurementTypes.first { $0.id == selectedTypes[0] }!
                                                let type2 = measurementTypes.first { $0.id == selectedTypes[1] }!
                                                let m1 = measurements.filter { $0.measurementType?.id == selectedTypes[0] }
                                                let m2 = measurements.filter { $0.measurementType?.id == selectedTypes[1] }
                                                
                                                SimpleDualAxisChart(
                                                    measurements1: m1,
                                                    measurements2: m2,
                                                    type1: type1,
                                                    type2: type2,
                                                    config1: measurementConfigs[selectedTypes[0]] ?? MergedMeasurementConfig(),
                                                    config2: measurementConfigs[selectedTypes[1]] ?? MergedMeasurementConfig()
                                                )
                                                .padding()
                                            } else if selectedTypes.count > 2 {
                                                Text("Select exactly 2 measurements for now")
                                                    .foregroundStyle(.secondary)
                                                    .padding()
                                            }
                    }
                }
                .navigationTitle("Merge Charts")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
}
struct SimpleDualAxisChart: View {
    let measurements1: [Measurement]
    let measurements2: [Measurement]
    let type1: MeasurementType
    let type2: MeasurementType
    let config1: MergedMeasurementConfig
    let config2: MergedMeasurementConfig
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Merged Chart")
                .font(.headline)
            
            HStack(spacing: 15) {
                HStack(spacing: 4) {
                    Circle().fill(config1.lineColor).frame(width: 8, height: 8)
                    Text(type1.name).font(.caption)
                }
                HStack(spacing: 4) {
                    Circle().fill(config2.lineColor).frame(width: 8, height: 8)
                    Text(type2.name).font(.caption)
                }
            }
            
            Chart {
                ForEach(measurements1, id: \.id) { m in
                    LineMark(
                        x: .value("Time", m.timestamp),
                        y: .value("Value", m.value)
                    )
                    .foregroundStyle(config1.lineColor)
                }
                ForEach(measurements2, id: \.id) { m in
                    LineMark(
                        x: .value("Time", m.timestamp),
                        y: .value("Value", m.value)
                    )
                    .foregroundStyle(config2.lineColor)
                }
            }
            .frame(height: 300)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
