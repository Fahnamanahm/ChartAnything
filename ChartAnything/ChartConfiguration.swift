//
//  ChartConfiguration.swift
//  ChartAnything
//
//  Created by Fahnamanahe on 12/2/25.
//
import Foundation
import SwiftData

@Model
class ChartConfiguration {
    var id: UUID
    var name: String
    var measurementTypes: [MeasurementType]
    var startDate: Date?
    var endDate: Date?
    var useEmoji: Bool
    var emojiSymbol: String?
    var lineColorHex: String
    var showDataPoints: Bool
    var lineWidth: Double
    var createdAt: Date
    
    init(name: String, measurementTypes: [MeasurementType] = [], startDate: Date? = nil, endDate: Date? = nil, useEmoji: Bool = false, emojiSymbol: String? = nil, lineColorHex: String = "#007AFF", showDataPoints: Bool = true, lineWidth: Double = 2.0) {
        self.id = UUID()
        self.name = name
        self.measurementTypes = measurementTypes
        self.startDate = startDate
        self.endDate = endDate
        self.useEmoji = useEmoji
        self.emojiSymbol = emojiSymbol
        self.lineColorHex = lineColorHex
        self.showDataPoints = showDataPoints
        self.lineWidth = lineWidth
        self.createdAt = Date()
    }
}
