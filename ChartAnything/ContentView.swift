//
//  ContentView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
    /// Selected date range filter
    @State private var selectedDateFilter: DateRangeFilter = .allTime
    /// Custom start date for filtering
    @State private var customStartDate: Date = Date()
    /// Custom end date for filtering
    @State private var customEndDate: Date = Date()
    /// Show date range picker sheet
    @State private var showingDateRangePicker = false
    /// Show merged chart view
    @State private var showingMergedChart = false
        /// Show import file picker
        @State private var showingImportPicker = false
    /// URL for sharing exported CSV
        @State private var shareURL: URL?
    /// Show export success alert
        @State private var showingExportAlert = false
        @State private var exportMessage = ""
        /// Show import result alert
        @State private var showingImportAlert = false
        @State private var importMessage = ""
    
    // MARK: - Methods
        
    /// Export all measurements to CSV file
        private func exportData() {
            guard let url = CSVManager.exportToCSV(measurements: measurements, measurementTypes: measurementTypes) else {
                exportMessage = "Failed to create CSV file"
                showingExportAlert = true
                return
            }
            
            let fileName = url.lastPathComponent
            exportMessage = "Data exported successfully!\n\nFile saved to:\nFiles app > On My iPhone > ChartAnything > \(fileName)"
            showingExportAlert = true
        }
        
    /// Handle CSV import from file picker
        private func handleImport(result: Result<[URL], Error>) {
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                
                let importResult = CSVManager.importFromCSV(
                    fileURL: url,
                    context: modelContext,
                    measurementTypes: measurementTypes
                )
                
                if importResult.errors > 0 {
                    importMessage = "Import completed with issues:\n\n✓ \(importResult.success) measurements imported\n✗ \(importResult.errors) failed\n\nErrors:\n\(importResult.messages.joined(separator: "\n"))"
                } else {
                    importMessage = "Success! Imported \(importResult.success) measurements."
                }
                showingImportAlert = true
                
            case .failure(let error):
                importMessage = "Import failed: \(error.localizedDescription)"
                showingImportAlert = true
            }
        }
            
            /// Import CSV data from clipboard
            private func importFromClipboard() {
                // Get clipboard content
                guard let clipboardText = UIPasteboard.general.string else {
                    importMessage = "No text found in clipboard"
                    showingImportAlert = true
                    return
                }
                
                // Write to temporary file
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("clipboard_import.csv")
                
                do {
                    try clipboardText.write(to: tempURL, atomically: true, encoding: .utf8)
                    
                    // Import from temporary file
                    let importResult = CSVManager.importFromCSV(
                        fileURL: tempURL,
                        context: modelContext,
                        measurementTypes: measurementTypes
                    )
                    
                    if importResult.errors > 0 {
                        importMessage = "Import completed with issues:\n\n✓ \(importResult.success) measurements imported\n✗ \(importResult.errors) failed\n\nErrors:\n\(importResult.messages.joined(separator: "\n"))"
                    } else {
                        importMessage = "Success! Imported \(importResult.success) measurements from clipboard!"
                    }
                    showingImportAlert = true
                    
                    // Clean up temp file
                    try? FileManager.default.removeItem(at: tempURL)
                    
                } catch {
                    importMessage = "Failed to process clipboard data: \(error.localizedDescription)"
                    showingImportAlert = true
                }
            }
        
        // MARK: - Computed Properties
    
    /// Filter measurements based on selected date range
    func filteredMeasurements(for measurements: [Measurement]) -> [Measurement] {
        let startDate = selectedDateFilter.startDate(customStart: customStartDate)
        let endDate = selectedDateFilter == .custom ? customEndDate : Date()
        
        if startDate == nil {
            return measurements // Show all data
        }
        
        return measurements.filter { measurement in
            guard let start = startDate else { return true }
            return measurement.timestamp >= start && measurement.timestamp <= endDate
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: App Title
                    HStack {
                        Text("ChartAnything")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Button {
                            showingDateRangePicker = true
                        } label: {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                    }
                    
                    // MARK: Charts Display
                    // Show a chart for each measurement type that has data
                    ForEach(measurementTypes, id: \.id) { type in
                        if !type.measurements.isEmpty {
                            let customization = chartCustomizations[type.id] ?? ChartCustomization()
                            
                            ChartView(
                                measurementType: type,
                                measurements: filteredMeasurements(for: type.measurements),
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
                    GKICalculatorView(
                        startDate: selectedDateFilter.startDate(customStart: customStartDate),
                        endDate: selectedDateFilter == .custom ? customEndDate : Date()
                    )
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
                        
                        Button {
                            showingMergedChart = true
                        } label: {
                            Label("Merge Charts", systemImage: "square.stack.3d.up")
                                                    }
                                                    
                                                    Divider()
                                                    
                                                    Button {
                                                        exportData()
                                                    } label: {
                                                        Label("Export Data", systemImage: "square.and.arrow.up")
                                                    }
                                                    
                        Menu {
                                                Button {
                                                    showingImportPicker = true
                                                } label: {
                                                    Label("Import from File", systemImage: "doc")
                                                }
                                                
                                                Button {
                                                    importFromClipboard()
                                                } label: {
                                                    Label("Import from Clipboard", systemImage: "doc.on.clipboard")
                                                }
                                            } label: {
                                                Label("Import Data", systemImage: "square.and.arrow.down")
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
            .sheet(isPresented: $showingDateRangePicker) {
                DateRangeFilterView(
                    selectedFilter: $selectedDateFilter,
                    customStartDate: $customStartDate,
                    customEndDate: $customEndDate
                )
            }
            .sheet(isPresented: $showingMergedChart) {
                            MergedChartView()
                        }
            .alert("Export Data", isPresented: $showingExportAlert) {
                            Button("OK") { }
                        } message: {
                            Text(exportMessage)
                        }
                        .alert("Import Data", isPresented: $showingImportAlert) {
                            Button("OK") { }
                        } message: {
                            Text(importMessage)
                        }
                        .fileImporter(
                            isPresented: $showingImportPicker,
                            allowedContentTypes: [.item],
                            allowsMultipleSelection: false
                        ) { result in
                            handleImport(result: result)
                        }
                        .onAppear {
                                        // Initial data setup disabled - import your own data instead
                                        // DataManager.setupInitialData(context: modelContext)
                                    }
        }
    }
}

// MARK: - Share Sheet
/// UIKit share sheet wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
