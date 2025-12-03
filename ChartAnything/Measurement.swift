//
//  Measurement.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//
import Foundation
import SwiftData

@Model
class Measurement {
    var id: UUID
    var value: Double
    var timestamp: Date
    var notes: String?
    
    var measurementType: MeasurementType?
    
    init(value: Double, timestamp: Date = Date(), notes: String? = nil, measurementType: MeasurementType? = nil) {
        self.id = UUID()
        self.value = value
        self.timestamp = timestamp
        self.notes = notes
        self.measurementType = measurementType
    }
}
