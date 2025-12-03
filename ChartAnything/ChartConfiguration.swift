//
//  ChartConfiguration.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import Foundation
import SwiftData

/// Configuration for how a chart should be displayed
/// Stores all customization options including colors, line styles, emoji points, etc.
@Model
class ChartConfiguration {
    var id: UUID
    var name: String
    var measurementTypes: [MeasurementType]
    var startDate: Date?
    var endDate: Date?
    
    // MARK: Point Customization
    /// Whether to use emoji instead of dots for data points
    var useEmoji: Bool
    /// The emoji character to use (if useEmoji is true)
    var emojiSymbol: String?
    /// Size of the data points (or emoji)
    var pointSize: Double
    /// Color for data points (hex string)
    var pointColorHex: String
    /// Whether to show data points at all
    var showDataPoints: Bool
    
    // MARK: Line Customization
    /// Whether to show connecting lines between points
    var showLine: Bool
    /// Color for the line (hex string)
    var lineColorHex: String
    /// Width/thickness of the line
    var lineWidth: Double
    
    var createdAt: Date
    
    init(name: String,
         measurementTypes: [MeasurementType] = [],
         startDate: Date? = nil,
         endDate: Date? = nil,
         useEmoji: Bool = false,
         emojiSymbol: String? = nil,
         pointSize: Double = 8.0,
         pointColorHex: String = "#007AFF",
         showDataPoints: Bool = true,
         showLine: Bool = true,
         lineColorHex: String = "#007AFF",
         lineWidth: Double = 2.0) {
        self.id = UUID()
        self.name = name
        self.measurementTypes = measurementTypes
        self.startDate = startDate
        self.endDate = endDate
        self.useEmoji = useEmoji
        self.emojiSymbol = emojiSymbol
        self.pointSize = pointSize
        self.pointColorHex = pointColorHex
        self.showDataPoints = showDataPoints
        self.showLine = showLine
        self.lineColorHex = lineColorHex
        self.lineWidth = lineWidth
        self.createdAt = Date()
    }
}
