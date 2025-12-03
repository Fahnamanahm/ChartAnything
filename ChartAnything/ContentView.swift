//
//  ContentView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData

/// Holds customization settings for a single chart
struct ChartCustomization {
    var pointSize: Double = 8
    var pointColor: Color = .blue
    var showDataPoints: Bool = true
    var showLine: Bool = true
    var lineColor: Color = .blue
    var lineWidth: Double = 2
}

/// Wrapper to handle dictionary binding for chart customization
struct ChartCustomizationWrapper: View {
    let type: MeasurementType
    @Binding var chartCustomizations: [UUID: ChartCustomization]
    
    var body: some View {
        ChartCustomizationView(
            measurementType: type,
            pointSize: binding(\.pointSize),
            pointColor: binding(\.pointColor),
            showDataPoints: binding(\.showDataPoints),
            showLine: binding(\.showLine),
            lineColor: binding(\.lineColor),
            lineWidth: binding(\.lineWidth)
        )
    }
    
    private func binding<T>(_ keyPath: WritableKeyPath<ChartCustomization, T>) -> Binding<T> {
        Binding(
            get: {
                if let customization = chartCustomizations[type.id] {
                    return customization[keyPath: keyPath]
                } else {
                    return ChartCustomization()[keyPath: keyPath]
                }
            },
            set: { newValue in
                var customization = chartCustomizations[type.id] ?? ChartCustomization()
                customization[keyPath: keyPath] = newValue
                chartCustomizations[type.id] = customization
            }
        )
    }
}

/// Main view of the app - displays all charts and provides access to add measurements
struct ContentView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Queries
    /// Fetch all measurement types from database
    @Query private var measurementTypes: [MeasurementType]
    /// Fetch all measurements from database
    @Query private var measurements: [Measurement]
    
    // MARK: - State Properties
    /// Controls whether the "Add Measurement" sheet is shown
    @State private var showingAddMeasurement = false
    /// Controls whether the "Add Measurement Type" sheet is shown
    @State private var showingAddMeasurementType = false
    /// Track customization settings for each measurement type
    @State private var chartCustomizations: [UUID: ChartCustomization] = [:]
    /// Currently customizing this measurement type
    @State private var customizingType: MeasurementType?
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: App Title
                    Text("ChartAnything")
                        .font(.largeTitle)
                        .bold()
                    
                    // MARK: Charts Display
                    // Show a chart for each measurement type that has data
                    ForEach(measurementTypes, id: \.id) { type in
                        if !type.measurements.isEmpty {
                            let customization = chartCustomizations[type.id] ?? ChartCustomization()
                            
                            ChartView(
                                measurementType: type,
                                measurements: type.measurements,
                                pointSize: customization.pointSize,
                                pointColor: customization.pointColor,
                                showDataPoints: customization.showDataPoints,
                                showLine: customization.showLine,
                                lineColor: customization.lineColor,
                                lineWidth: customization.lineWidth
                            )
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .onTapGesture {
                                customizingType = type
                            }
                        }
                    }
                    // MARK: GKI Calculator
                    // Show GKI chart if both glucose and ketones exist
                    GKICalculatorView()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: Add Menu
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingAddMeasurement = true
                        } label: {
                            Label("Add Measurement", systemImage: "plus.circle")
                        }
                        
                        Button {
                            showingAddMeasurementType = true
                        } label: {
                            Label("New Measurement Type", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddMeasurement) {
                AddMeasurementView()
            }
            .sheet(isPresented: $showingAddMeasurementType) {
                AddMeasurementTypeView()
            }
            .sheet(item: $customizingType) { type in
                ChartCustomizationWrapper(
                    type: type,
                    chartCustomizations: $chartCustomizations
                )
            }
            .onAppear {
                // Set up initial data (glucose, ketones, weight) with sample measurements
                DataManager.setupInitialData(context: modelContext)
            }
        }
    }
}

// MARK: - Color Extension
/// Helper extension to convert hex color strings to SwiftUI Color
extension Color {
    /// Initialize a Color from a hex string (e.g., "#FF6B6B" or "FF6B6B")
    /// - Parameter hex: Hex color string with or without # prefix
    /// - Returns: Color if valid hex, nil otherwise
    init?(hex: String) {
        // Remove any non-alphanumeric characters (like #)
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 6: // RGB (no alpha) - assume full opacity
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (with alpha)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        // Convert to 0-1 range
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
