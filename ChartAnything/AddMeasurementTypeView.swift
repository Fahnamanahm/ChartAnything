//
//  AddMeasurementTypeView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI
import SwiftData

/// View for creating new custom measurement types
/// Allows users to define what they want to track (heart rate, sleep, steps, etc.)
struct AddMeasurementTypeView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Properties
    /// Name of the measurement type (e.g., "Heart Rate", "Sleep Hours")
    @State private var name: String = ""
    /// Unit of measurement (e.g., "bpm", "hours", "steps")
    @State private var unit: String = ""
    /// Color for displaying this type on charts (hex string)
    @State private var selectedColor: Color = .blue
    /// Optional emoji to represent this measurement type
    @State private var emoji: String = ""
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Name Input
                Section("Measurement Name") {
                    TextField("e.g., Heart Rate, Sleep, Steps", text: $name)
                }
                
                // MARK: Unit Input
                Section("Unit") {
                    TextField("e.g., bpm, hours, steps", text: $unit)
                }
                
                // MARK: Color Picker
                Section("Chart Color") {
                    ColorPicker("Color", selection: $selectedColor)
                }
                
                // MARK: Optional Emoji
                Section("Emoji (Optional)") {
                    TextField("e.g., ❤️, 😴, 👟", text: $emoji)
                }
            }
            .navigationTitle("New Measurement Type")
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
                        saveMeasurementType()
                    }
                    // Only enable save if name and unit are filled in
                    .disabled(name.isEmpty || unit.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// Saves the new measurement type to the database
    /// Converts Color to hex string and creates MeasurementType object
    private func saveMeasurementType() {
        // Ensure name and unit are not empty
        guard !name.isEmpty, !unit.isEmpty else {
            return
        }
        
        // Convert SwiftUI Color to hex string for storage
        let hexColor = selectedColor.toHex() ?? "#007AFF"
        
        // Create new measurement type (not a system type since user created it)
        let newType = MeasurementType(
            name: name,
            unit: unit,
            colorHex: hexColor,
            emoji: emoji.isEmpty ? nil : emoji,
            isSystemType: false
        )
        
        // Insert into database
        modelContext.insert(newType)
        
        // Save changes
        try? modelContext.save()
        
        // Close the sheet
        dismiss()
    }
}

// MARK: - Color Extension
/// Extension to convert SwiftUI Color to hex string for storage
extension Color {
    /// Converts Color to hex string representation (e.g., "#FF6B6B")
    /// - Returns: Hex string if conversion successful, nil otherwise
    func toHex() -> String? {
        // Get color components (red, green, blue, alpha)
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        // Convert to hex format
        return String(format: "#%02X%02X%02X",
                     Int(r * 255),
                     Int(g * 255),
                     Int(b * 255))
    }
}

// MARK: - Preview
#Preview {
    AddMeasurementTypeView()
        .modelContainer(for: [MeasurementType.self], inMemory: true)
}
