//
//  DateRangeFilterView.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/2/25.
//

import SwiftUI

/// Enum representing different preset date ranges for filtering charts
enum DateRangeFilter: String, CaseIterable, Identifiable {
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last90Days = "Last 90 Days"
    case custom = "Custom Range"
    case allTime = "All Time"
    
    var id: String { rawValue }
    
    /// Calculate the start date for preset ranges
    func startDate(customStart: Date?) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .last7Days:
            return calendar.date(byAdding: .day, value: -7, to: now)
        case .last30Days:
            return calendar.date(byAdding: .day, value: -30, to: now)
        case .last90Days:
            return calendar.date(byAdding: .day, value: -90, to: now)
        case .custom:
            // Set to start of day (midnight)
            return customStart.map { calendar.startOfDay(for: $0) }
        case .allTime:
            return nil // nil means no filter
        }
    }
    
    /// Calculate the end date with time set to 11:59:59 PM
    func endDate(customEnd: Date?) -> Date {
        let calendar = Calendar.current
        
        switch self {
        case .custom:
            // Set to end of day (11:59:59 PM)
            if let customEnd = customEnd {
                return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: customEnd) ?? customEnd
            }
            return Date()
        default:
            // For preset ranges, use current time
            return Date()
        }
    }
}

/// View for selecting date range filters
struct DateRangeFilterView: View {
    @Binding var selectedFilter: DateRangeFilter
    @Binding var customStartDate: Date
    @Binding var customEndDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Preset Ranges
                Section("Quick Select") {
                    ForEach(DateRangeFilter.allCases.filter { $0 != .custom }) { filter in
                        Button {
                            selectedFilter = filter
                            if filter != .custom {
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                
                // MARK: Custom Range
                Section("Custom Date Range") {
                    Button {
                        selectedFilter = .custom
                    } label: {
                        HStack {
                            Text("Custom Range")
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedFilter == .custom {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    
                    if selectedFilter == .custom {
                                            DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                                            DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                                            
                                            Button("Apply Custom Range") {
                                                // Ensure filter is set to custom
                                                selectedFilter = .custom
                                                // Small delay to ensure state updates propagate
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    dismiss()
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                                .navigationTitle("Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DateRangeFilterView(
        selectedFilter: .constant(.allTime),
        customStartDate: .constant(Date()),
        customEndDate: .constant(Date())
    )
}
