import SwiftUI
import SwiftData

struct MeasurementEntryRow: View {
    let measurementType: MeasurementType
    let onSave: (Double, Date, String?) -> Void
    
    @State private var value: String = ""
    @State private var timestamp = Date()
    @State private var notes: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(measurementType.name)
                .font(.headline)
            
            HStack {
                TextField("Value", text: $value)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                
                Text(measurementType.unit)
                    .foregroundStyle(.secondary)
                
                DatePicker("", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                
                Button("Add") {
                    if let numValue = Double(value) {
                        onSave(numValue, timestamp, notes)
                        value = ""
                        notes = ""
                        timestamp = Date()
                    }
                }
                .disabled(Double(value) == nil)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
