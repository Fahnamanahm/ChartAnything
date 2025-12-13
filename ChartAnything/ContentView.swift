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

// ┌─────────────────────────────────────────────────────────────────┐
// │ CHART HEADER COMPONENT                                          │
// │ Shows measurement name with customize and add-reading buttons   │
// └─────────────────────────────────────────────────────────────────┘
// ┌─────────────────────────────────────────────────────────────────┐
// │ CHART HEADER COMPONENT                                          │
// │ Shows measurement name with customize and add-reading buttons   │
// │ Just clean text and icon buttons                                │
// └─────────────────────────────────────────────────────────────────┘
struct ChartHeaderView: View {
    let type: MeasurementType
    let onCustomize: () -> Void
    let onAddReading: () -> Void
    
    var body: some View {
        HStack {
            // ↓↓↓ Just show the measurement name (no emoji)
            Text(type.name)
                .font(.headline)
            
            Spacer()
            
            // ↓↓↓ Customize button (blue sliders icon)
            Button(action: onCustomize) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(.blue)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            // ↓↓↓ Quick add button (green plus icon)
            Button(action: onAddReading) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
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
        /// Fetch all chart customizations from database
        @Query private var savedCustomizations: [ChartCustomizationModel]
    
    // MARK: - State Properties
        /// Controls whether the "Add Measurement" sheet is shown
        @State private var showingAddMeasurement = false
        /// Controls whether the "Add Measurement Type" sheet is shown
        @State private var showingAddMeasurementType = false
        /// Track customization settings for each measurement type
        @State private var chartCustomizations: [UUID: ChartCustomization] = [:]
        /// Currently customizing this measurement type
    @State private var customizingType: MeasurementType?
            /// Track which measurement type is selected for quick-add
            @State private var selectedMeasurementTypeForQuickAdd: MeasurementType?
            /// Controls whether the QuickAdd sheet is shown
            @State private var showingQuickAdd = false
            /// Track which tab is currently selected (0=Charts, 1=Add Data, 2=Settings)
            @State private var selectedTab = 0
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
        /// Show share sheet for export
        @State private var showingExportShare = false
        @State private var exportMessage = ""
        /// Show import result alert
        @State private var showingImportAlert = false
        @State private var importMessage = ""
        /// Show delete warning alerts
        @State private var showingDeleteWarning = false
        @State private var showingFinalDeleteWarning = false
    
    
    // MARK: - Methods
        
    /// Export all measurements to clipboard as CSV
        private func exportData() {
            // Create CSV text directly
            var csvText = "Date,Time,Measurement Type,Value,Unit,Notes\n"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            
            for measurement in measurements.sorted(by: { $0.timestamp < $1.timestamp }) {
                guard let type = measurement.measurementType else { continue }
                
                let date = dateFormatter.string(from: measurement.timestamp)
                let time = timeFormatter.string(from: measurement.timestamp)
                let typeName = type.name.replacingOccurrences(of: ",", with: ";")
                let value = String(measurement.value)
                let unit = type.unit.replacingOccurrences(of: ",", with: ";")
                let notes = (measurement.notes ?? "").replacingOccurrences(of: ",", with: ";")
                
                csvText += "\(date),\(time),\(typeName),\(value),\(unit),\(notes)\n"
            }
            
            // Copy to clipboard
            UIPasteboard.general.string = csvText
            
            exportMessage = "Export successful!\n\n\(measurements.count) measurements copied to clipboard as CSV.\n\nYou can now paste into Notes, Mail, or any text app."
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
        
        /// Delete all measurement data
        private func deleteAllData() {
            // Delete all measurements
            for measurement in measurements {
                modelContext.delete(measurement)
            }
            
            // Delete all measurement types
            for type in measurementTypes {
                modelContext.delete(type)
            }
            
            // Save context
            try? modelContext.save()
        }
        
        // MARK: - Computed Properties
    
    /// Filter measurements based on selected date range
        func filteredMeasurements(for measurements: [Measurement]) -> [Measurement] {
            let startDate = selectedDateFilter.startDate(customStart: customStartDate)
            let endDate = selectedDateFilter.endDate(customEnd: customEndDate)
            
            if startDate == nil {
                return measurements // Show all data
            }
            
            return measurements.filter { measurement in
                guard let start = startDate else { return true }
                return measurement.timestamp >= start && measurement.timestamp <= endDate
            }
        }
    
        // ┌─────────────────────────────────────────────────────────────────┐
        // │ MAIN APP BODY - TAB NAVIGATION                                  │
        // │ Three tabs: Charts, Add Data, Settings                          │
        // └─────────────────────────────────────────────────────────────────┘
            // MARK: - Body
            var body: some View {
                TabView(selection: $selectedTab) {
                    // ┌─────────────────────────────────────────────────────┐
                    // │ TAB 1: CHARTS VIEW                                  │
                    // │ Shows all your measurement charts                   │
                    // └─────────────────────────────────────────────────────┘
                    chartsView
                        .tabItem {
                            Label("Charts", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .tag(0)
                    
                    // ┌─────────────────────────────────────────────────────┐
                    // │ TAB 2: ADD DATA VIEW                                │
                    // │ Quick entry screen for adding measurements          │
                    // └─────────────────────────────────────────────────────┘
                    addDataView
                        .tabItem {
                            Label("Add Data", systemImage: "plus.circle.fill")
                        }
                        .tag(1)
                    
                    // ┌─────────────────────────────────────────────────────┐
                    // │ TAB 3: SETTINGS VIEW                                │
                    // │ App settings, export/import, etc.                   │
                    // └─────────────────────────────────────────────────────┘
                    settingsView
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(2)
                }
            }
    
        
    // ┌─────────────────────────────────────────────────────────────┐
    // │ CHARTS VIEW (Tab 1)                                          │
    // │ The main charts display - what used to be the whole app     │
    // └─────────────────────────────────────────────────────────────┘
    private var chartsView: some View {
        NavigationStack {
            chartsScrollView
                .background(chartBackground)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        toolbarMenu
                    }
                }
        }
        .sheet(isPresented: $showingAddMeasurement) {
            if let selectedType = selectedMeasurementTypeForQuickAdd {
                QuickAddMeasurementView(measurementType: selectedType)
                    .onDisappear {
                        selectedMeasurementTypeForQuickAdd = nil
                    }
            } else {
                AddMeasurementView()
            }
        }
        .sheet(isPresented: $showingAddMeasurementType) {
            AddMeasurementTypeView()
        }
        .sheet(item: $customizingType) { type in
            ChartCustomizationWrapper(
                type: type,
                chartCustomizations: $chartCustomizations
            )
            .onDisappear {
                saveCustomizations()
            }
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
        .sheet(item: $selectedMeasurementTypeForQuickAdd) { selectedType in
                    let _ = print("DEBUG: Showing QuickAdd for \(selectedType.name)")
                    QuickAddMeasurementView(measurementType: selectedType)
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
        .alert("⚠️ WARNING", isPresented: $showingDeleteWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showingFinalDeleteWarning = true
            }
        } message: {
            Text("This will permanently delete ALL your health data. Are you sure?")
        }
        .alert("🚨 NO REALLY", isPresented: $showingFinalDeleteWarning) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Everything", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This cannot be undone. All measurements will be lost forever. Delete everything?")
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
        .onAppear {
            loadCustomizations()
        }
    }
        
        // MARK: - Charts View Components
        
        private var chartsScrollView: some View {
            ScrollView {
                VStack(spacing: 20) {
                    chartsHeader
                    chartsContent
                }
                .padding()
            }
        }
        
        private var chartsHeader: some View {
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
        }
        
        private var chartsContent: some View {
            Group {
                ForEach(measurementTypes, id: \.id) { type in
                    if !type.measurements.isEmpty {
                        chartCard(for: type)
                    }
                }
                
                gkiSection
            }
        }
        
        private var gkiSection: some View {
            GKICalculatorView(
                startDate: selectedDateFilter.startDate(customStart: customStartDate),
                endDate: selectedDateFilter.endDate(customEnd: customEndDate)
            )
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        
        private var chartBackground: some View {
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
                
                // MARK: - Toolbar Menu Components
                
                /// Main toolbar menu with all actions
                private var toolbarMenu: some View {
                    Menu {
                        addMenuButtons
                        
                        Divider()
                        
                        dataMenuButtons
                        
                        Divider()
                        
                        deleteButton
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                /// Add measurement buttons
                private var addMenuButtons: some View {
                    Group {
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
                    }
                }
                
                /// Export and import buttons
                private var dataMenuButtons: some View {
                    Group {
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
                    }
                }
                
    /// Delete all data button
        private var deleteButton: some View {
            Button(role: .destructive) {
                showingDeleteWarning = true
            } label: {
                Label("Delete All Data", systemImage: "trash")
            }
        }
        
    // MARK: - Chart Helper
                
                /// Creates a chart card for a measurement type
                private func chartCard(for type: MeasurementType) -> some View {
                    let customization = chartCustomizations[type.id] ?? ChartCustomization()
                    
                    return VStack(alignment: .leading, spacing: 8) {
                        ChartHeaderView(
                            type: type,
                            onCustomize: { customizingType = type },
                            onAddReading: {
                                selectedMeasurementTypeForQuickAdd = type
                                showingQuickAdd = true
                            }
                        )
                        
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
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
            
            // ┌─────────────────────────────────────────────────────────────┐
            // │ ADD DATA VIEW (Tab 2)                                        │
            // │ Quick entry screen for adding new measurements              │
            // └─────────────────────────────────────────────────────────────┘
    private var addDataView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Date range picker at top
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
                    .padding(.top)
                    
                    // Entry fields for each measurement type
                    ForEach(measurementTypes.sorted(by: { $0.name < $1.name }), id: \.id) { type in
                        MeasurementEntryRow(
                            measurementType: type,
                            onSave: { value, timestamp, notes in
                                saveMeasurement(value: value, timestamp: timestamp, notes: notes, type: type)
                            }
                        )
                    }
                    
                    // GKI navigator button
                                        if measurementTypes.contains(where: { $0.name == "Glucose" }) &&
                                           measurementTypes.contains(where: { $0.name == "Ketones" }) {
                                            Button {
                                                selectedTab = 0
                                            } label: {
                                                HStack {
                                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                                    Text("View GKI Calculator")
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                }
                                                .padding()
                                                .background(Color.purple.opacity(0.1))
                                                .cornerRadius(8)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding()
                                }
                                .navigationTitle("Add Data")
                                .navigationBarTitleDisplayMode(.inline)
                            }
                        }

    // Helper function to save measurement and navigate to chart
        private func saveMeasurement(value: Double, timestamp: Date, notes: String?, type: MeasurementType) {
            let measurement = Measurement(
                value: value,
                timestamp: timestamp,
                notes: notes?.isEmpty == false ? notes : nil
            )
            measurement.measurementType = type
            modelContext.insert(measurement)
            
            // Navigate to Charts tab
            selectedTab = 0
        }
            
            // ┌─────────────────────────────────────────────────────────────┐
            // │ SETTINGS VIEW (Tab 3)                                        │
            // │ App settings, export/import, delete data, etc.              │
            // └─────────────────────────────────────────────────────────────┘
            private var settingsView: some View {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Settings")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        Text("Settings coming soon!")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
                                                                
// MARK: - Customization Persistence
    
    /// Load saved customizations from database
    private func loadCustomizations() {
        for saved in savedCustomizations {
            chartCustomizations[saved.measurementTypeID] = saved.toChartCustomization()
        }
    }
    
    /// Save customizations to database
    private func saveCustomizations() {
        for (typeID, customization) in chartCustomizations {
            // Find existing saved customization or create new one
            if let existing = savedCustomizations.first(where: { $0.measurementTypeID == typeID }) {
                existing.update(from: customization)
            } else {
                let newCustomization = ChartCustomizationModel(
                    measurementTypeID: typeID,
                    pointSize: customization.pointSize,
                    pointColorHex: customization.pointColor.toHex() ?? "007AFF",
                    showDataPoints: customization.showDataPoints,
                    showLine: customization.showLine,
                    lineColorHex: customization.lineColor.toHex() ?? "007AFF",
                    lineWidth: customization.lineWidth
                )
                modelContext.insert(newCustomization)
            }
        }
        
        try? modelContext.save()
    }
}

                                                            // MARK: - Activity View Controller
                                                            /// UIKit share sheet wrapper for SwiftUI
                                                            struct ActivityViewController: UIViewControllerRepresentable {
                                                                let activityItems: [Any]
                                                                let applicationActivities: [UIActivity]? = nil
                                                                
                                                                func makeUIViewController(context: Context) -> UIActivityViewController {
                                                                    let controller = UIActivityViewController(
                                                                        activityItems: activityItems,
                                                                        applicationActivities: applicationActivities
                                                                    )
                                                                    return controller
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
