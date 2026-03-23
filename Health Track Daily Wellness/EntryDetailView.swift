//
//  EntryDetailView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct EntryDetailView: View {
    let entry: WellnessEntry
    
    var body: some View {
        List {
            // Date Section
            Section("Date & Time") {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(entry.date, style: .date)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Time")
                    Spacer()
                    Text(entry.date, style: .time)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Mood & Energy Section
            Section("Mood & Energy") {
                HStack {
                    Label("Mood", systemImage: "face.smiling")
                    Spacer()
                    RatingView(rating: entry.moodRating)
                }
                
                HStack {
                    Label("Energy Level", systemImage: "bolt.fill")
                    Spacer()
                    RatingView(rating: entry.energyLevel)
                }
            }
            
            // Sleep Section
            Section("Sleep") {
                HStack {
                    Label("Hours", systemImage: "bed.double.fill")
                    Spacer()
                    Text(String(format: "%.1f hours", entry.sleepHours))
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Label("Quality", systemImage: "moon.stars.fill")
                    Spacer()
                    Text(entry.sleepQuality.rawValue)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Symptoms Section
            if !entry.symptoms.isEmpty {
                Section("Symptoms") {
                    ForEach(entry.symptoms) { symptom in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(symptom.type.rawValue)
                                    .font(.headline)
                                Spacer()
                                Text("Severity: \(symptom.severity)/10")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !symptom.notes.isEmpty {
                                Text(symptom.notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Severity indicator bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.gray.opacity(0.2))
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(severityColor(for: symptom.severity))
                                        .frame(width: geometry.size.width * CGFloat(symptom.severity) / 10, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Medications Section
            if !entry.medications.isEmpty {
                Section("Medications") {
                    ForEach(entry.medications) { medication in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(medication.name)
                                .font(.headline)
                            HStack {
                                Text(medication.dosage)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(medication.timeTaken.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Water Intake Section
            if entry.waterIntake > 0 {
                Section("Water Intake") {
                    HStack {
                        Label("Water", systemImage: "drop.fill")
                        Spacer()
                        Text(String(format: "%.1f oz", entry.waterIntake))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Exercise Section
            if !entry.exercise.isEmpty {
                Section("Exercise") {
                    Text(entry.exercise)
                }
            }
            
            // Custom Fields Section
            if !entry.customFields.isEmpty {
                Section("Custom Fields") {
                    ForEach(entry.customFields) { field in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(field.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(field.value)
                                .font(.body)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Notes Section
            if !entry.notes.isEmpty {
                Section("Notes") {
                    Text(entry.notes)
                }
            }
        }
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func severityColor(for severity: Int) -> Color {
        switch severity {
        case 1...3:
            return .green
        case 4...6:
            return .yellow
        case 7...8:
            return .orange
        default:
            return .red
        }
    }
}

struct RatingView: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(rating)/10")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ForEach(0..<10) { index in
                Circle()
                    .fill(index < rating ? .blue : .gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: WellnessEntry(
            date: Date(),
            symptoms: [
                Symptom(type: .headache, severity: 7, notes: "Started in the morning"),
                Symptom(type: .fatigue, severity: 5)
            ],
            moodRating: 6,
            energyLevel: 4,
            sleepHours: 6.5,
            sleepQuality: .fair,
            medications: [
                Medication(name: "Ibuprofen", dosage: "200mg", timeTaken: Date())
            ],
            waterIntake: 64,
            exercise: "30 min walk",
            customFields: [
                CustomField(label: "Weather", value: "Sunny")
            ],
            notes: "Felt tired throughout the day."
        ))
    }
}
