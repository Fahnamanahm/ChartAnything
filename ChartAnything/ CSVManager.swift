//
//  CSVManager.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/3/25.
//

import Foundation
import SwiftData

/// Manages CSV export and import of measurements
/// Provides functionality to backup and restore measurement data
class CSVManager {
    
    // MARK: - Export to CSV
    
    /// Export all measurements to CSV format
    /// Returns URL to temporary CSV file that can be shared
    static func exportToCSV(measurements: [Measurement], measurementTypes: [MeasurementType]) -> URL? {
        // Create CSV header
        var csvText = "Date,Time,Measurement Type,Value,Unit,Notes\n"
        
        // Add each measurement as a row
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        for measurement in measurements.sorted(by: { $0.timestamp < $1.timestamp }) {
            guard let type = measurement.measurementType else { continue }
            
            let date = dateFormatter.string(from: measurement.timestamp)
            let time = timeFormatter.string(from: measurement.timestamp)
            let typeName = type.name.replacingOccurrences(of: ",", with: ";") // Escape commas
            let value = String(measurement.value)
            let unit = type.unit.replacingOccurrences(of: ",", with: ";")
            let notes = (measurement.notes ?? "").replacingOccurrences(of: ",", with: ";")
            
            csvText += "\(date),\(time),\(typeName),\(value),\(unit),\(notes)\n"
        }
        
        // Save to temporary directory for sharing
                let fileName = "ChartAnything_Export_\(dateFormatter.string(from: Date())).csv"
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
                    try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
                    return tempURL
        } catch {
            print("Error writing CSV: \(error)")
            return nil
        }
    }
    
    // MARK: - Import from CSV
    
    /// Import measurements from CSV file
    /// Returns tuple of (success count, error count, error messages)
    static func importFromCSV(fileURL: URL, context: ModelContext, measurementTypes: [MeasurementType]) -> (success: Int, errors: Int, messages: [String]) {
        var successCount = 0
        var errorCount = 0
        var errorMessages: [String] = []
        
        do {
            // Read CSV file
            let csvText = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvText.components(separatedBy: .newlines)
            
            // Skip header row
            guard rows.count > 1 else {
                errorMessages.append("CSV file is empty")
                return (0, 1, errorMessages)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            // Process each row (skip header at index 0)
            for (index, row) in rows.enumerated() where index > 0 {
                // Skip empty rows
                if row.trimmingCharacters(in: .whitespaces).isEmpty {
                    continue
                }
                
                let columns = row.components(separatedBy: ",")
                
                // Validate row has enough columns
                guard columns.count >= 5 else {
                    errorCount += 1
                    errorMessages.append("Row \(index): Invalid format")
                    continue
                }
                
                // Parse columns
                let dateString = columns[0]
                let timeString = columns[1]
                let typeName = columns[2]
                let valueString = columns[3]
                // unit at columns[4] - we get this from the type
                let notes = columns.count > 5 ? columns[5] : ""
                
                // Find or create measurement type
                guard let measurementType = measurementTypes.first(where: { $0.name == typeName }) else {
                    errorCount += 1
                    errorMessages.append("Row \(index): Unknown measurement type '\(typeName)'")
                    continue
                }
                
                // Parse date and time
                let dateTimeString = "\(dateString) \(timeString)"
                guard let timestamp = dateFormatter.date(from: dateTimeString) else {
                    errorCount += 1
                    errorMessages.append("Row \(index): Invalid date/time format")
                    continue
                }
                
                // Parse value
                guard let value = Double(valueString) else {
                    errorCount += 1
                    errorMessages.append("Row \(index): Invalid value '\(valueString)'")
                    continue
                }
                
                // Create measurement
                let measurement = Measurement(
                    value: value,
                    timestamp: timestamp,
                    notes: notes.isEmpty ? nil : notes,
                    measurementType: measurementType
                )
                
                context.insert(measurement)
                successCount += 1
            }
            
            // Save context
            try context.save()
            
        } catch {
            errorMessages.append("Error reading CSV: \(error.localizedDescription)")
            errorCount += 1
        }
        
        return (successCount, errorCount, errorMessages)
    }
}
