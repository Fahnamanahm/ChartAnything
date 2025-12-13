//
//  MergedChartView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData
import Charts

/// Special UUID to identify GKI as a "virtual" measurement type
let GKI_MEASUREMENT_ID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

/// Helper view for measurement type selection button
struct MeasurementSelectionButton: View {
    let type: MeasurementType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                Text(type.name)
                Spacer()
            }
            .padding()
        }
    }
}

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
    @Query private var savedCustomizations: [ChartCustomizationModel]
    
    @State private var selectedTypes: [UUID] = []
    @State private var measurementConfigs: [UUID: MergedMeasurementConfig] = [:]
    @State private var expandedTypes: Set<UUID> = []
    @State private var selectedDateFilter: DateRangeFilter = .allTime
    @State private var customStartDate: Date = Date()
    @State private var customEndDate: Date = Date()
    @State private var showingDateRangePicker = false
    
    // MARK: - Computed Properties
    
    /// Check if both Glucose and Ketones measurement types exist with data
    var hasGlucoseAndKetones: Bool {
        let hasGlucose = measurementTypes.contains { $0.name == "Glucose" && !$0.measurements.isEmpty }
        let hasKetones = measurementTypes.contains { $0.name == "Ketones" && !$0.measurements.isEmpty }
        return hasGlucose && hasKetones
    }
    
    
    /// Filter measurements by selected date range
        func filteredMeasurements(for measurements: [Measurement]) -> [Measurement] {
            let startDate = selectedDateFilter.startDate(customStart: customStartDate)
            let endDate = selectedDateFilter.endDate(customEnd: customEndDate)
            
            if startDate == nil {
                return measurements
            }
           
            return measurements.filter { measurement in
                guard let start = startDate else { return true }
                return measurement.timestamp >= start && measurement.timestamp <= endDate
            }
        }
        
        /// Computed chart data for selected measurement types
        var chartData: (measurements1: [Measurement], measurements2: [Measurement], type1: MeasurementType, type2: MeasurementType)? {
            guard selectedTypes.count == 2 else { return nil }
            
            let isType1GKI = selectedTypes[0] == GKI_MEASUREMENT_ID
            let isType2GKI = selectedTypes[1] == GKI_MEASUREMENT_ID
            
            let type1: MeasurementType?
            let type2: MeasurementType?
            let m1: [Measurement]
            let m2: [Measurement]
            
            if isType1GKI {
                type1 = createGKIMeasurementType()
                m1 = generateGKIMeasurements()
            } else {
                type1 = measurementTypes.first { $0.id == selectedTypes[0] }
                let allM1 = measurements.filter { $0.measurementType?.id == selectedTypes[0] }
                m1 = filteredMeasurements(for: allM1)
            }
            
            if isType2GKI {
                type2 = createGKIMeasurementType()
                m2 = generateGKIMeasurements()
            } else {
                type2 = measurementTypes.first { $0.id == selectedTypes[1] }
                let allM2 = measurements.filter { $0.measurementType?.id == selectedTypes[1] }
                m2 = filteredMeasurements(for: allM2)
            }
            
            guard let finalType1 = type1, let finalType2 = type2 else { return nil }
            
            return (m1, m2, finalType1, finalType2)
        }
            
            /// Toggle selection of a measurement type
            func toggleTypeSelection(_ typeID: UUID, isMeasurementType: Bool) {
                if selectedTypes.contains(typeID) {
                    selectedTypes.removeAll { $0 == typeID }
                } else {
                    selectedTypes.append(typeID)
                    
                    if isMeasurementType {
                        // Load saved customization or use defaults
                        if let saved = savedCustomizations.first(where: { $0.measurementTypeID == typeID }) {
                            measurementConfigs[typeID] = MergedMeasurementConfig(
                                showLine: saved.showLine,
                                lineColor: Color(hex: saved.lineColorHex) ?? .blue,
                                lineWidth: saved.lineWidth,
                                showPoints: saved.showDataPoints,
                                pointColor: Color(hex: saved.pointColorHex) ?? .blue,
                                pointSize: saved.pointSize
                            )
                        } else {
                            // Fall back to measurement type color
                            if let type = measurementTypes.first(where: { $0.id == typeID }) {
                                let color = Color(hex: type.colorHex) ?? .blue
                                measurementConfigs[typeID] = MergedMeasurementConfig(
                                    lineColor: color,
                                    pointColor: color
                                )
                            }
                        }
                    } else {
                        // GKI - use purple
                        measurementConfigs[typeID] = MergedMeasurementConfig(
                            lineColor: .purple,
                            pointColor: .purple
                        )
                    }
                }
            }
            
            /// Generate GKI measurements from glucose and ketones
    func generateGKIMeasurements() -> [Measurement] {
            guard let glucoseType = measurementTypes.first(where: { $0.name == "Glucose" }),
                  let ketonesType = measurementTypes.first(where: { $0.name == "Ketones" }) else {
                return []
            }
            
            let glucoseMeasurements = measurements.filter { $0.measurementType?.id == glucoseType.id }
            let ketoneMeasurements = measurements.filter { $0.measurementType?.id == ketonesType.id }
            
            var gkiMeasurements: [Measurement] = []
            let calendar = Calendar.current
            
            for glucose in glucoseMeasurements {
                let glucoseDay = calendar.startOfDay(for: glucose.timestamp)
                
                if let ketone = ketoneMeasurements.first(where: {
                    calendar.startOfDay(for: $0.timestamp) == glucoseDay
                }) {
                    let gki = DataManager.calculateGKI(glucose: glucose.value, ketones: ketone.value)
                    
                    // Filter out GKI values > 9.0
                    if gki <= 9.0 {
                        // Create a fake measurement for GKI
                        let gkiMeasurement = Measurement(
                            value: gki,
                            timestamp: glucose.timestamp,
                            notes: nil
                        )
                        gkiMeasurements.append(gkiMeasurement)
                    }
                }
            }
            
            return filteredMeasurements(for: gkiMeasurements)
        }
    /// Create a fake measurement type for GKI display
    func createGKIMeasurementType() -> MeasurementType {
        return MeasurementType(
            name: "GKI",
            unit: "ratio",
            colorHex: "9B59B6",
            emoji: "📊"
        )
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
                                                    MeasurementSelectionButton(
                                                        type: type,
                                                        isSelected: selectedTypes.contains(type.id),
                                                        action: {
                                                            toggleTypeSelection(type.id, isMeasurementType: true)
                                                        }
                                                    )
                                                }
                                                
                                                // Add GKI as a selectable option if glucose and ketones exist
                                                if hasGlucoseAndKetones {
                                                    Button {
                                                        toggleTypeSelection(GKI_MEASUREMENT_ID, isMeasurementType: false)
                                                    } label: {
                                                        HStack {
                                                            let isSelected = selectedTypes.contains(GKI_MEASUREMENT_ID)
                                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                            Text("GKI (Glucose-Ketone Index)")
                                                            Spacer()
                                                        }
                                                        .padding()
                                                    }
                                                }
                                            }
                    
                    if let data = chartData {
                                            DualAxisChart(
                                                measurements1: data.measurements1,
                                                measurements2: data.measurements2,
                                                type1: data.type1,
                                                type2: data.type2,
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
                                    .id(UUID())
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
            .id("\(selectedDateFilter.rawValue)-\(customStartDate)-\(customEndDate)")
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
                    
                    // Use smart padding for GKI
                    if isType1GKI {
                        return (min: 0, max: 9.0)  // Fixed range for GKI
                    }
                    
                    let range = maxValue - minValue
                    let padding = max(range * 0.2, 2.0)
                    return (min: max(0, minValue - padding), max: maxValue + padding)
                }
        
        var range2: (min: Double, max: Double) {
                    guard !measurements2.isEmpty else { return (0, 100) }
                    let values = measurements2.map { $0.value }
                    let minValue = values.min() ?? 0
                    let maxValue = values.max() ?? 100
                    
                    // Use smart padding for GKI
                    if isType2GKI {
                        return (min: 0, max: 9.0)  // Fixed range for GKI
                    }
                    
                    let range = maxValue - minValue
                    let padding = max(range * 0.2, 2.0)
                    return (min: max(0, minValue - padding), max: maxValue + padding)
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
                
                // Get GKI zone color based on value
                func gkiColor(for value: Double) -> Color {
                    switch value {
                    case 0.5...1.0:
                        return .green
                    case 1.01...3.0:
                        return .yellow
                    case 3.01...6.0:
                        return .orange
                    case 6.01...9.0:
                        return .red
                    default:
                        return .purple
                    }
                }
                
                // Check if a measurement type is GKI
                var isType1GKI: Bool {
                    type1.name == "GKI"
                }
                
                var isType2GKI: Bool {
                    type2.name == "GKI"
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
                                                    .foregroundStyle(isType1GKI ? gkiColor(for: m.value) : config1.pointColor)
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
                                                    .foregroundStyle(isType2GKI ? gkiColor(for: m.value) : config2.pointColor)
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
                                    
                                    // ❌ PROBLEM: Using normalized values [0, 25, 50, 75, 100] creates 5 labels
                                    // The "0" label gets positioned at the very bottom of the chart frame,
                                    // which overlaps with the X-axis labels below it.
                    // ❌ PROBLEM: Using normalized values [0, 25, 50, 75, 100] creates 5 labels
                                        // The "0" label gets positioned at the very bottom of the chart frame,
                                        // which overlaps with the X-axis labels below it.
                                        // AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                                        
                                        // ✅ SOLUTION: Remove the "0" value so we only have 4 labels [25, 50, 75, 100]
                                        // This keeps the lowest label above the X-axis area
                                        // ✅ Use GKI-specific values (1, 3, 6, 9) if type1 is GKI, otherwise use generic values
                                        AxisMarks(
                                            position: .leading,
                                            values: isType1GKI ? [11.11, 33.33, 66.67, 100] : [25, 50, 75, 100]
                                        ) { value in
                                            AxisValueLabel {
                                                if let normalizedValue = value.as(Double.self) {
                                                    let actualValue = denormalize(normalizedValue, min: range1.min, max: range1.max)
                                                    
                                                    // For GKI, show 1, 3, 6, 9 instead of calculated values
                                                    if isType1GKI {
                                                        let gkiValue = actualValue <= 1.5 ? 1 : (actualValue <= 4.5 ? 3 : (actualValue <= 7.5 ? 6 : 9))
                                                        Text("\(gkiValue)")
                                                            .foregroundStyle(config1.lineColor)
                                                            .font(.caption2)
                                                    } else {
                                                        Text(String(format: "%.0f", actualValue))
                                                            .foregroundStyle(config1.lineColor)
                                                            .font(.caption2)
                                                    }
                                                }
                                            }
                                            AxisGridLine()
                                        }
                                    }
                                    .overlay(alignment: .trailing) {
                                    // Right Y-axis labels (actual values for measurement 2)
                                    VStack(spacing: 0) {
                                        // ❌ PROBLEM: The "0" value creates a label at the very bottom that overlaps X-axis
                                        // ForEach([100, 75, 50, 25, 0], id: \.self) { normalizedValue in

                                        // ✅ SOLUTION: Remove "0" so lowest label is at 25, staying above X-axis
                                        // ✅ Use GKI-specific normalized values if type2 is GKI, otherwise generic
                                        ForEach(isType2GKI ? [100, 66.67, 33.33, 11.11] : [100, 75, 50, 25], id: \.self) { normalizedValue in
                                                                                    let actualValue = denormalize(Double(normalizedValue), min: range2.min, max: range2.max)
                                                                                    
                                                                                    // For GKI, show 9, 6, 3, 1 instead of calculated values
                                                                                    if isType2GKI {
                                                                                        let gkiValue = actualValue >= 7.5 ? 9 : (actualValue >= 4.5 ? 6 : (actualValue >= 2.0 ? 3 : 1))
                                                                                        Text("\(gkiValue)")
                                                                                            .font(.caption2)
                                                                                            .foregroundStyle(config2.lineColor)
                                                                                    } else {
                                                                                        Text(String(format: "%.0f", actualValue))
                                                                                            .font(.caption2)
                                                                                            .foregroundStyle(config2.lineColor)
                                                                                    }
                                                                                    
                                                                                    if normalizedValue != (isType2GKI ? 11.11 : 25) {
                                                                                        Spacer()
                                                                                    }
                                                                                }
                                                                            }
                                                                            .frame(height: 240)
                                                                            .padding(.top, 8)
                                                                            .padding(.trailing, 8)
                                                                        }
                                .padding(.trailing, 16)
                                
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
}
