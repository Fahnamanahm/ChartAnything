//
//  AddMeasurementView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData

/// View for adding new measurements to the database
/// Allows users to select a measurement type, enter a value, set timestamp, and add notes
struct AddMeasurementView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Queries
    /// Fetch all available measurement types from the database
    @Query private var measurementTypes: [MeasurementType]
    
    // MARK: - State Properties
    /// Currently selected measurement type (defaults to first available)
    @State private var selectedType: MeasurementType?
    /// The numeric value being entered by the user
    @State private var valueText: String = ""
    /// Timestamp for when this measurement was taken
    @State private var timestamp: Date = Date()
    /// Optional notes about this measurement
    @State private var notes: String = ""
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Measurement Type Selection
                Section("Measurement Type") {
                    Picker("Type", selection: $selectedType) {
                        // Show "Select..." if no type chosen yet
                        Text("Select...").tag(nil as MeasurementType?)
                        
                        // List all available measurement types
                        ForEach(measurementTypes, id: \.id) { type in
                            Text(type.name)
                                .tag(type as MeasurementType?)
                        }
                    }
                }
                
                // MARK: Value Input
                Section("Value") {
                    HStack {
                        // Numeric keyboard for entering measurement value
                        TextField("Enter value", text: $valueText)
                            .keyboardType(.decimalPad)
                        
                        // Show the unit for selected measurement type
                        if let type = selectedType {
                            Text(type.unit)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // MARK: Date & Time Selection
                Section("Date & Time") {
                    DatePicker("When", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                }
                
                // MARK: Optional Notes
                Section("Notes (Optional)") {
                    TextField("Add any notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Measurement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // MARK: Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMeasurement()
                    }
                    // Only enable save if we have a type and valid value
                    .disabled(selectedType == nil || valueText.isEmpty)
                }
            }
            .onAppear {
                // Auto-select first measurement type if available
                if selectedType == nil && !measurementTypes.isEmpty {
                    selectedType = measurementTypes.first
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// Saves the measurement to the database
    /// Validates input, creates new Measurement object, and dismisses the view
    private func saveMeasurement() {
        // Ensure we have a selected type and valid numeric value
        guard let type = selectedType,
              let value = Double(valueText) else {
            return
        }
        
        // Create new measurement with entered data
        let measurement = Measurement(
            value: value,
            timestamp: timestamp,
            notes: notes.isEmpty ? nil : notes,
            measurementType: type
        )
        
        // Insert into database
        modelContext.insert(measurement)
        
        // Save changes
        try? modelContext.save()
        
        // Close the sheet
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    AddMeasurementView()
        .modelContainer(for: [MeasurementType.self, Measurement.self], inMemory: true)
}
