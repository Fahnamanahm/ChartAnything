//
//  Untitled.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//
import Foundation
import SwiftData

@Model
class MeasurementType {
    var id: UUID
    var name: String
    var unit: String
    var colorHex: String
    var emoji: String?
    var isSystemType: Bool
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var measurements: [Measurement] = []
    
    init(name: String, unit: String, colorHex: String = "#007AFF", emoji: String? = nil, isSystemType: Bool = false) {
        self.id = UUID()
        self.name = name
        self.unit = unit
        self.colorHex = colorHex
        self.emoji = emoji
        self.isSystemType = isSystemType
        self.createdAt = Date()
    }
}
