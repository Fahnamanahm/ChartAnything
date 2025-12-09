//
//  QuickAddMeasurementView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/8/25.
//

import SwiftUI
import SwiftData

// ┌─────────────────────────────────────────────────────────────────┐
// │ QUICK ADD MEASUREMENT VIEW                                      │
// │                                                                  │
// │ WHAT IT DOES:                                                   │
// │ - Simplified form for adding a reading to a specific chart      │
// │ - No measurement type picker (it's already locked)              │
// │ - Just enter: value, date/time, and optional notes              │
// │                                                                  │
// │ WHY WE NEED IT:                                                 │
// │ - When you tap the + button next to a chart, you want to        │
// │   quickly add a reading for THAT measurement only               │
// │ - Faster than the full "Add Measurement" form                   │
// └─────────────────────────────────────────────────────────────────┘
struct QuickAddMeasurementView: View {
    // ┌─────────────────────────────────────────────────────────────┐
    // │ PROPERTIES                                                   │
    // └─────────────────────────────────────────────────────────────┘
    
    // ↓↓↓ The measurement type this reading is for (locked, can't change)
    let measurementType: MeasurementType
    
    // ↓↓↓ SwiftData context - saves data to the database
    @Environment(\.modelContext) private var modelContext
    
    // ↓↓↓ Dismiss action - closes this sheet when done
    @Environment(\.dismiss) private var dismiss
    
    // ↓↓↓ Form fields that user fills in
    @State private var value: String = ""  // The actual reading (e.g., "285")
    @State private var selectedDate = Date()  // When the reading was taken
    @State private var notes: String = ""  // Optional notes
    
    // ┌─────────────────────────────────────────────────────────────┐
    // │ COMPUTED PROPERTIES                                          │
    // └─────────────────────────────────────────────────────────────┘
    
    // ↓↓↓ Check if the form is valid (has a number in the value field)
    private var isValidInput: Bool {
        Double(value) != nil  // Can we convert the text to a number?
    }
    
    // ┌─────────────────────────────────────────────────────────────┐
    // │ MAIN VIEW BODY                                               │
    // └─────────────────────────────────────────────────────────────┘
    var body: some View {
        NavigationStack {
            Form {
                // ┌─────────────────────────────────────────────────┐
                // │ SECTION 1: Show which measurement this is for   │
                // └─────────────────────────────────────────────────┘
                    Section("Adding to") {
                        HStack {
                            Text(measurementType.name)
                                .font(.headline)
                            Spacer()
                        Text(measurementType.unit)
                    .foregroundStyle(.secondary)
                }
            }
                // ┌─────────────────────────────────────────────────┐
                // │ SECTION 2: Value input field                    │
                // └─────────────────────────────────────────────────┘
                Section("Value") {
                    TextField("Enter value", text: $value)
                        .keyboardType(.decimalPad)  // Show number keyboard
                }
                
                // ┌─────────────────────────────────────────────────┐
                // │ SECTION 3: Date and time picker                 │
                // └─────────────────────────────────────────────────┘
                Section("Date & Time") {
                    DatePicker("When", selection: $selectedDate)
                }
                
                // ┌─────────────────────────────────────────────────┐
                // │ SECTION 4: Optional notes field                 │
                // └─────────────────────────────────────────────────┘
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ┌─────────────────────────────────────────────────┐
                // │ TOOLBAR: Cancel and Save buttons                │
                // └─────────────────────────────────────────────────┘
                
                // ↓↓↓ Cancel button - closes without saving
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                // ↓↓↓ Save button - only enabled if value is valid
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMeasurement()
                    }
                    .disabled(!isValidInput)  // Gray out if invalid
                }
            }
        }
    }
    
    // ┌─────────────────────────────────────────────────────────────┐
    // │ SAVE FUNCTION                                                │
    // │ Creates a new Measurement and saves it to the database       │
    // └─────────────────────────────────────────────────────────────┘
    private func saveMeasurement() {
        // ↓↓↓ Convert the text value to a number
        guard let numericValue = Double(value) else { return }
        
        // ↓↓↓ Create a new Measurement object
        let measurement = Measurement(
            value: numericValue,
            timestamp: selectedDate,
            notes: notes.isEmpty ? nil : notes  // Only save notes if user typed something
        )
        
        // ↓↓↓ Link this measurement to the measurement type
        measurement.measurementType = measurementType
        
        // ↓↓↓ Save to database
        modelContext.insert(measurement)
        
        // ↓↓↓ Close the sheet
        dismiss()
    }
}

// ┌─────────────────────────────────────────────────────────────────┐
// │ PREVIEW                                                          │
// │ Shows what this view looks like in Xcode's preview              │
// └─────────────────────────────────────────────────────────────────┘
#Preview {
    QuickAddMeasurementView(
        measurementType: MeasurementType(
            name: "Weight",
            unit: "lbs",
            colorHex: "00FF00",
            emoji: "⚖️"
        )
    )
}
