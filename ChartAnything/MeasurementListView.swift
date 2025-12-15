//
//  MeasurementListView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/14/25.
//

import SwiftUI
import SwiftData

// ┌─────────────────────────────────────────────────────────────────┐
// │ MEASUREMENT LIST VIEW                                           │
// │ Shows all measurements for a type with swipe-to-delete          │
// └─────────────────────────────────────────────────────────────────┘
struct MeasurementListView: View {
    let measurementType: MeasurementType
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // ┌─────────────────────────────────────────────────────────────┐
    // │ FETCH MEASUREMENTS                                          │
    // │ Gets all measurements for this type, sorted by date         │
    // └─────────────────────────────────────────────────────────────┘
    private var sortedMeasurements: [Measurement] {
        measurementType.measurements.sorted { $0.timestamp > $1.timestamp }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedMeasurements) { measurement in
                    MeasurementRow(measurement: measurement, type: measurementType)
                }
                .onDelete(perform: deleteMeasurements)
            }
            .navigationTitle("\(measurementType.name) Readings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // ┌─────────────────────────────────────────────────────────────┐
    // │ DELETE FUNCTION                                             │
    // │ Removes selected measurements from database                 │
    // └─────────────────────────────────────────────────────────────┘
    private func deleteMeasurements(at offsets: IndexSet) {
        for index in offsets {
            let measurement = sortedMeasurements[index]
            modelContext.delete(measurement)
        }
    }
}

// ┌─────────────────────────────────────────────────────────────────┐
// │ MEASUREMENT ROW                                                 │
// │ Displays a single measurement in the list                      │
// └─────────────────────────────────────────────────────────────────┘
struct MeasurementRow: View {
    let measurement: Measurement
    let type: MeasurementType
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: measurement.timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(measurement.value, specifier: "%.1f") \(type.unit)")
                    .font(.headline)
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let notes = measurement.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
