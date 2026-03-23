//
//  Models.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import Foundation

// Wellness entry that captures all daily health data
struct WellnessEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var symptoms: [Symptom]
    var moodRating: Int // 1-10 scale
    var energyLevel: Int // 1-10 scale
    var sleepHours: Double
    var sleepQuality: SleepQuality
    var medications: [Medication]
    var waterIntake: Double // in ounces or ml
    var exercise: String
    var customFields: [CustomField]
    var notes: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        symptoms: [Symptom] = [],
        moodRating: Int = 5,
        energyLevel: Int = 5,
        sleepHours: Double = 7.0,
        sleepQuality: SleepQuality = .fair,
        medications: [Medication] = [],
        waterIntake: Double = 0,
        exercise: String = "",
        customFields: [CustomField] = [],
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.symptoms = symptoms
        self.moodRating = moodRating
        self.energyLevel = energyLevel
        self.sleepHours = sleepHours
        self.sleepQuality = sleepQuality
        self.medications = medications
        self.waterIntake = waterIntake
        self.exercise = exercise
        self.customFields = customFields
        self.notes = notes
    }
}

// Symptom tracking
struct Symptom: Identifiable, Codable, Hashable {
    var id = UUID()
    var type: SymptomType
    var severity: Int // 1-10 scale
    var notes: String
    
    init(id: UUID = UUID(), type: SymptomType, severity: Int = 5, notes: String = "") {
        self.id = id
        self.type = type
        self.severity = severity
        self.notes = notes
    }
}

enum SymptomType: String, Codable, CaseIterable {
    case headache = "Headache"
    case fatigue = "Fatigue"
    case pain = "Pain"
    case nausea = "Nausea"
    case dizziness = "Dizziness"
    case other = "Other"
}

enum SleepQuality: String, Codable, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case veryPoor = "Very Poor"
}

// Medication tracking
struct Medication: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var dosage: String
    var timeTaken: Date
    
    init(id: UUID = UUID(), name: String, dosage: String, timeTaken: Date = Date()) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.timeTaken = timeTaken
    }
}

// Custom field for any additional tracking
struct CustomField: Identifiable, Codable, Hashable {
    var id = UUID()
    var label: String
    var value: String
    
    init(id: UUID = UUID(), label: String, value: String) {
        self.id = id
        self.label = label
        self.value = value
    }
}
