//
//  AddEntryView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (WellnessEntry) -> Void
    
    @State private var date = Date()
    @State private var symptoms: [Symptom] = []
    @State private var moodRating = 5
    @State private var energyLevel = 5
    @State private var sleepHours = 7.0
    @State private var sleepQuality: SleepQuality = .fair
    @State private var medications: [Medication] = []
    @State private var waterIntake = 0.0
    @State private var exercise = ""
    @State private var customFields: [CustomField] = []
    @State private var notes = ""
    
    @State private var showingAddSymptom = false
    @State private var showingAddMedication = false
    @State private var showingAddCustomField = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Date and Time
                Section("Date & Time") {
                    DatePicker("Date", selection: $date)
                }
                
                // Mood and Energy
                Section("Mood & Energy") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Mood")
                            Spacer()
                            Text("\(moodRating)/10")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(moodRating) },
                            set: { moodRating = Int($0) }
                        ), in: 1...10, step: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Energy Level")
                            Spacer()
                            Text("\(energyLevel)/10")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(energyLevel) },
                            set: { energyLevel = Int($0) }
                        ), in: 1...10, step: 1)
                    }
                }
                
                // Sleep
                Section("Sleep") {
                    HStack {
                        Text("Hours")
                        Spacer()
                        Text(String(format: "%.1f", sleepHours))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $sleepHours, in: 0...12, step: 0.5)
                    
                    Picker("Quality", selection: $sleepQuality) {
                        ForEach(SleepQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                }
                
                // Symptoms
                Section {
                    ForEach(symptoms) { symptom in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(symptom.type.rawValue)
                                    .font(.headline)
                                Text("Severity: \(symptom.severity)/10")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if !symptom.notes.isEmpty {
                                    Text(symptom.notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteSymptom)
                    
                    Button(action: { showingAddSymptom = true }) {
                        Label("Add Symptom", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Symptoms")
                }
                
                // Medications
                Section {
                    ForEach(medications) { medication in
                        VStack(alignment: .leading) {
                            Text(medication.name)
                                .font(.headline)
                            Text("\(medication.dosage) at \(medication.timeTaken.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: deleteMedication)
                    
                    Button(action: { showingAddMedication = true }) {
                        Label("Add Medication", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Medications")
                }
                
                // Water Intake
                Section("Water Intake") {
                    HStack {
                        TextField("Ounces", value: $waterIntake, format: .number)
                            .keyboardType(.decimalPad)
                        Text("oz")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Exercise
                Section("Exercise") {
                    TextField("Describe your exercise", text: $exercise, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                // Custom Fields
                Section {
                    ForEach(customFields) { field in
                        VStack(alignment: .leading) {
                            Text(field.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(field.value)
                        }
                    }
                    .onDelete(perform: deleteCustomField)
                    
                    Button(action: { showingAddCustomField = true }) {
                        Label("Add Custom Field", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Custom Fields")
                }
                
                // Notes
                Section("Notes") {
                    TextField("Add any additional notes", text: $notes, axis: .vertical)
                        .lineLimit(5...10)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
            .sheet(isPresented: $showingAddSymptom) {
                AddSymptomView { symptom in
                    symptoms.append(symptom)
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationView { medication in
                    medications.append(medication)
                }
            }
            .sheet(isPresented: $showingAddCustomField) {
                AddCustomFieldView { field in
                    customFields.append(field)
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = WellnessEntry(
            date: date,
            symptoms: symptoms,
            moodRating: moodRating,
            energyLevel: energyLevel,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            medications: medications,
            waterIntake: waterIntake,
            exercise: exercise,
            customFields: customFields,
            notes: notes
        )
        onSave(entry)
        dismiss()
    }
    
    private func deleteSymptom(at offsets: IndexSet) {
        symptoms.remove(atOffsets: offsets)
    }
    
    private func deleteMedication(at offsets: IndexSet) {
        medications.remove(atOffsets: offsets)
    }
    
    private func deleteCustomField(at offsets: IndexSet) {
        customFields.remove(atOffsets: offsets)
    }
}

// Add Symptom Sheet
struct AddSymptomView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Symptom) -> Void
    
    @State private var symptomType: SymptomType = .headache
    @State private var severity = 5
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $symptomType) {
                    ForEach(SymptomType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Severity")
                        Spacer()
                        Text("\(severity)/10")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: Binding(
                        get: { Double(severity) },
                        set: { severity = Int($0) }
                    ), in: 1...10, step: 1)
                }
                
                TextField("Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(3...5)
            }
            .navigationTitle("Add Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let symptom = Symptom(type: symptomType, severity: severity, notes: notes)
                        onSave(symptom)
                        dismiss()
                    }
                }
            }
        }
    }
}

// Add Medication Sheet
struct AddMedicationView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Medication) -> Void
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var timeTaken = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Medication Name", text: $name)
                TextField("Dosage (e.g., 500mg, 2 tablets)", text: $dosage)
                DatePicker("Time Taken", selection: $timeTaken)
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let medication = Medication(name: name, dosage: dosage, timeTaken: timeTaken)
                        onSave(medication)
                        dismiss()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                }
            }
        }
    }
}

// Add Custom Field Sheet
struct AddCustomFieldView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (CustomField) -> Void
    
    @State private var label = ""
    @State private var value = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Field Name", text: $label)
                TextField("Value", text: $value, axis: .vertical)
                    .lineLimit(2...5)
            }
            .navigationTitle("Add Custom Field")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let field = CustomField(label: label, value: value)
                        onSave(field)
                        dismiss()
                    }
                    .disabled(label.isEmpty || value.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddEntryView { _ in }
}
