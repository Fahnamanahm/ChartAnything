//
//  ChartCustomizationModel.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/6/25.
//

import SwiftUI
import SwiftData

/// Persistent storage for chart customization settings
@Model
final class ChartCustomizationModel {
    /// ID of the measurement type this customization applies to
    var measurementTypeID: UUID
    
    /// Point size for chart markers
    var pointSize: Double
    
    /// Point color as hex string
    var pointColorHex: String
    
    /// Whether to show data points
    var showDataPoints: Bool
    
    /// Whether to show connecting lines
    var showLine: Bool
    
    /// Line color as hex string
    var lineColorHex: String
    
    /// Line width
    var lineWidth: Double
    
    /// Initialize with default values
    init(
        measurementTypeID: UUID,
        pointSize: Double = 8,
        pointColorHex: String = "007AFF",
        showDataPoints: Bool = true,
        showLine: Bool = true,
        lineColorHex: String = "007AFF",
        lineWidth: Double = 2
    ) {
        self.measurementTypeID = measurementTypeID
        self.pointSize = pointSize
        self.pointColorHex = pointColorHex
        self.showDataPoints = showDataPoints
        self.showLine = showLine
        self.lineColorHex = lineColorHex
        self.lineWidth = lineWidth
    }
    
    /// Convert to temporary ChartCustomization struct
    func toChartCustomization() -> ChartCustomization {
        ChartCustomization(
            pointSize: pointSize,
            pointColor: Color(hex: pointColorHex) ?? .blue,
            showDataPoints: showDataPoints,
            showLine: showLine,
            lineColor: Color(hex: lineColorHex) ?? .blue,
            lineWidth: lineWidth
        )
    }
    
    /// Update from ChartCustomization struct
    func update(from customization: ChartCustomization) {
        self.pointSize = customization.pointSize
        self.pointColorHex = customization.pointColor.toHex() ?? "007AFF"
        self.showDataPoints = customization.showDataPoints
        self.showLine = customization.showLine
        self.lineColorHex = customization.lineColor.toHex() ?? "007AFF"
        self.lineWidth = customization.lineWidth
    }
}

