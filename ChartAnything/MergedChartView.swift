//
//  MergedChartView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData
import Charts

/// Configuration for a single measurement in a merged chart
struct MergedMeasurementConfig {
    var showLine: Bool = true
    var lineColor: Color = .blue
    var lineWidth: Double = 2.0
    var showPoints: Bool = true
    var pointColor: Color = .blue
    var pointSize: Double = 8.0
}

/// View for merging two measurement types with independent Y-axes
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
    
    /// Filter measurements by selected date range
    func filteredMeasurements(for measurements: [Measurement]) -> [Measurement] {
        let startDate = selectedDateFilter.startDate(customStart: customStartDate)
        let endDate = selectedDateFilter == .custom ? customEndDate : Date()
        
        if startDate == nil {
            return measurements
        }
        
        return measurements.filter { measurement in
            guard let start = startDate else { return true }
            return measurement.timestamp >= start && measurement.timestamp <= endDate
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Date range picker button
                    Button {
                        showingDateRangePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            Text(selectedDateFilter.rawValue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
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
                        let allM1 = measurements.filter { $0.measurementType?.id == selectedTypes[0] }
                        let allM2 = measurements.filter { $0.measurementType?.id == selectedTypes[1] }
                        let m1 = filteredMeasurements(for: allM1)
                        let m2 = filteredMeasurements(for: allM2)
                        
                        DualAxisChart(
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
            .sheet(isPresented: $showingDateRangePicker) {
                DateRangeFilterView(
                    selectedFilter: $selectedDateFilter,
                    customStartDate: $customStartDate,
                    customEndDate: $customEndDate
                )
            }
        }
    }
}

/// Dual Y-axis chart with normalized values and proper scaling
struct DualAxisChart: View {
    let measurements1: [Measurement]
    let measurements2: [Measurement]
    let type1: MeasurementType
    let type2: MeasurementType
    let config1: MergedMeasurementConfig
    let config2: MergedMeasurementConfig
    
    // Sorted measurements to prevent line spaghetti
    var sortedMeasurements1: [Measurement] {
        measurements1.sorted { $0.timestamp < $1.timestamp }
    }
    
    var sortedMeasurements2: [Measurement] {
        measurements2.sorted { $0.timestamp < $1.timestamp }
    }
    
    // Calculate Y-axis ranges with 10-unit padding
    var range1: (min: Double, max: Double) {
        guard !measurements1.isEmpty else { return (0, 100) }
        let values = measurements1.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 100
        return (min: minValue - 10, max: maxValue + 10)
    }
    
    var range2: (min: Double, max: Double) {
        guard !measurements2.isEmpty else { return (0, 100) }
        let values = measurements2.map { $0.value }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 100
        return (min: minValue - 10, max: maxValue + 10)
    }
    
    // Normalize value to 0-100 scale for charting
    func normalize(_ value: Double, min: Double, max: Double) -> Double {
        guard max > min else { return 50 }
        return ((value - min) / (max - min)) * 100
    }
    
    // Denormalize from 0-100 back to actual value for labels
    func denormalize(_ normalized: Double, min: Double, max: Double) -> Double {
        return (normalized / 100) * (max - min) + min
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Merged Chart")
                .font(.headline)
            
            // Legend with correct colors
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
            
            // Chart with normalized data and separate series
            Chart {
                // First measurement series (left axis)
                ForEach(Array(sortedMeasurements1.enumerated()), id: \.element.id) { index, m in
                    let normalizedValue = normalize(m.value, min: range1.min, max: range1.max)
                    
                    if config1.showLine {
                        LineMark(
                            x: .value("Time", m.timestamp),
                            y: .value("Value", normalizedValue),
                            series: .value("Series", "Type1")
                        )
                        .foregroundStyle(config1.lineColor)
                        .lineStyle(StrokeStyle(lineWidth: config1.lineWidth))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    if config1.showPoints {
                        PointMark(
                            x: .value("Time", m.timestamp),
                            y: .value("Value", normalizedValue)
                        )
                        .foregroundStyle(config1.pointColor)
                        .symbolSize(config1.pointSize * 10)
                    }
                }
                
                // Second measurement series (right axis)
                ForEach(Array(sortedMeasurements2.enumerated()), id: \.element.id) { index, m in
                    let normalizedValue = normalize(m.value, min: range2.min, max: range2.max)
                    
                    if config2.showLine {
                        LineMark(
                            x: .value("Time", m.timestamp),
                            y: .value("Value", normalizedValue),
                            series: .value("Series", "Type2")
                        )
                        .foregroundStyle(config2.lineColor)
                        .lineStyle(StrokeStyle(lineWidth: config2.lineWidth))
                        .interpolationMethod(.catmullRom)
                    }
                    
                    if config2.showPoints {
                        PointMark(
                            x: .value("Time", m.timestamp),
                            y: .value("Value", normalizedValue)
                        )
                        .foregroundStyle(config2.pointColor)
                        .symbolSize(config2.pointSize * 10)
                    }
                }
            }
            .frame(height: 300)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYScale(domain: 0...100)
            .chartYAxis {
                // Left Y-axis (actual values for measurement 1)
                AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                    AxisValueLabel {
                        if let normalizedValue = value.as(Double.self) {
                            let actualValue = denormalize(normalizedValue, min: range1.min, max: range1.max)
                            Text(String(format: "%.0f", actualValue))
                                .foregroundStyle(config1.lineColor)
                                .font(.caption2)
                        }
                    }
                    AxisGridLine()
                }
            }
            .overlay(alignment: .trailing) {
                // Right Y-axis labels (actual values for measurement 2)
                VStack {
                    ForEach([100, 75, 50, 25, 0], id: \.self) { normalizedValue in
                        let actualValue = denormalize(Double(normalizedValue), min: range2.min, max: range2.max)
                        
                        Spacer()
                        
                        Text(String(format: "%.0f", actualValue))
                            .font(.caption2)
                            .foregroundStyle(config2.lineColor)
                    }
                }
                .frame(height: 300)
                .padding(.trailing, -25)
            }
            
            // Axis labels with correct colors
            HStack {
                Text("\(type1.name) (\(type1.unit))")
                    .font(.caption)
                    .foregroundStyle(config1.lineColor)
                
                Spacer()
                
                Text("\(type2.name) (\(type2.unit))")
                    .font(.caption)
                    .foregroundStyle(config2.lineColor)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
