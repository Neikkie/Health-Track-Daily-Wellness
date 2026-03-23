//
//  DailyLogView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct DailyLogView: View {
    @State private var entries: [WellnessEntry] = []
    
    // Quick entry form state
    @State private var moodRating = 5.0
    @State private var energyLevel = 5.0
    @State private var sleepHours = 7.0
    @State private var sleepQuality: SleepQuality = .fair
    @State private var waterIntake = 64.0
    @State private var exerciseDone = false
    @State private var exerciseDescription = ""
    
    // Tag-based symptoms
    @State private var selectedSymptoms: Set<SymptomType> = []
    @State private var symptomSeverities: [SymptomType: Double] = [:]
    
    // Medications
    @State private var tookMedication = false
    @State private var medications: [Medication] = []
    
    // Notes
    @State private var notes = ""
    @State private var showingNotes = false
    
    @State private var showingSaveConfirmation = false
    @State private var currentSection = 0
    
    // Computed progress
    var completionProgress: Double {
        var completed = 0.0
        let total = 6.0
        
        if moodRating != 5.0 { completed += 1 }
        if energyLevel != 5.0 { completed += 1 }
        if sleepHours != 7.0 { completed += 1 }
        if !selectedSymptoms.isEmpty { completed += 1 }
        if waterIntake > 0 { completed += 1 }
        if exerciseDone || !notes.isEmpty { completed += 1 }
        
        return completed / total
    }
    
    var mainContent: some View {
        VStack(spacing: Spacing.lg) {
            headerView
            
            moodAndEnergySection
            Divider().padding(.horizontal)
            
            sleepSection
            Divider().padding(.horizontal)
            
            symptomsSection
            Divider().padding(.horizontal)
            
            medicationsSection
            Divider().padding(.horizontal)
            
            activitySection
            Divider().padding(.horizontal)
            
            notesSection
            
            saveButton
        }
    }
    
    var moodAndEnergySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "How are you feeling?", icon: "face.smiling")
            
            VStack(spacing: Spacing.md) {
                EmojiMoodSelector(selectedMood: $moodRating)
                
                InteractiveSliderCard(
                    title: "Energy Level",
                    value: $energyLevel,
                    icon: "bolt.fill",
                    color: .energyYellow,
                    emoji: energyEmoji(for: energyLevel)
                )
            }
        }
        .padding(.horizontal)
    }
    
    var sleepSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Sleep", icon: "bed.double.fill")
            
            VStack(spacing: Spacing.md) {
                InteractiveSliderCard(
                    title: "Sleep Hours",
                    value: $sleepHours,
                    range: 0...12,
                    step: 0.5,
                    icon: "moon.stars.fill",
                    color: .sleepPurple,
                    emoji: sleepEmoji(for: sleepHours),
                    valueFormat: "%.1fh"
                )
                
                InteractiveQualityPicker(selection: $sleepQuality)
            }
        }
        .padding(.horizontal)
    }
    
    var symptomsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SectionHeader(title: "Symptoms", icon: "cross.case.fill")
                Spacer()
                if !selectedSymptoms.isEmpty {
                    Text("\(selectedSymptoms.count) selected")
                        .font(WellnessFont.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(Color.exerciseOrange.opacity(0.2))
                        .cornerRadius(12)
                }
            }
            
            ImprovedSymptomTagView(
                selectedSymptoms: $selectedSymptoms,
                symptomSeverities: $symptomSeverities
            )
        }
        .padding(.horizontal)
    }
    
    var medicationsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Medications", icon: "pills.fill")
            
            medicationToggleButton
        }
        .padding(.horizontal)
    }
    
    var medicationToggleButton: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tookMedication.toggle()
            }
        }) {
            HStack {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: tookMedication ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(tookMedication ? Color.moodExcellent : .secondary)
                    
                    Text("Took medication today")
                        .font(WellnessFont.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "pill.fill")
                    .font(.title2)
                    .foregroundStyle(tookMedication ? Color.moodExcellent : .secondary)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(tookMedication ? Color.moodExcellent.opacity(0.1) : Color.secondaryCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(tookMedication ? Color.moodExcellent : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    var activitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Activity & Hydration", icon: "figure.walk")
            
            VStack(spacing: Spacing.md) {
                waterIntakeCard
                exerciseCard
            }
        }
        .padding(.horizontal)
    }
    
    var saveButton: some View {
        Button(action: {
            HapticManager.impact(style: .medium)
            saveEntry()
        }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Today's Log")
            }
        }
        .buttonStyle(PrimaryButtonStyle(color: .primaryBlue))
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    var waterIntakeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "drop.fill")
                        .font(WellnessFont.title2)
                        .foregroundStyle(Color.waterCyan)
                    Text("Water Intake")
                        .font(WellnessFont.callout)
                        .fontWeight(.semibold)
                }
                Spacer()
                Text("\(Int(waterIntake)) oz")
                    .font(WellnessFont.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.waterCyan)
            }
            
            HStack(spacing: Spacing.xs) {
                ForEach([8, 16, 24, 32], id: \.self) { amount in
                    Button(action: {
                        HapticManager.impact(style: .light)
                        waterIntake += Double(amount)
                    }) {
                        Text("+\(amount)")
                            .font(WellnessFont.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.waterCyan)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.xs)
                            .background(Color.waterCyan.opacity(0.1))
                            .cornerRadius(CornerRadius.sm)
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    HapticManager.impact(style: .light)
                    waterIntake = 0
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(WellnessFont.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: 40)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.secondaryCardBackground)
                        .cornerRadius(CornerRadius.sm)
                }
                .buttonStyle(.plain)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.waterCyan.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.waterCyan.opacity(0.8), .waterCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: min(geometry.size.width * (waterIntake / 128), geometry.size.width), height: 12)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: waterIntake)
                }
            }
            .frame(height: 12)
        }
        .cardStyle()
    }
    
    var exerciseCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Button(action: {
                HapticManager.impact(style: .medium)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    exerciseDone.toggle()
                }
            }) {
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: exerciseDone ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundStyle(exerciseDone ? Color.exerciseOrange : .secondary)
                        
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Exercised Today")
                                .font(WellnessFont.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            if exerciseDone {
                                Text("Great job! 💪")
                                    .font(WellnessFont.caption)
                                    .foregroundStyle(Color.exerciseOrange)
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: "figure.run")
                        .font(.title)
                        .foregroundStyle(exerciseDone ? Color.exerciseOrange : .secondary)
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(exerciseDone ? Color.exerciseOrange.opacity(0.1) : Color.secondaryCardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(exerciseDone ? Color.exerciseOrange : .clear, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
            
            if exerciseDone {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("What did you do?")
                        .font(WellnessFont.caption)
                        .foregroundStyle(.secondary)
                    TextField("e.g., 30 min walk, yoga, gym", text: $exerciseDescription, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...3)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .cardStyle()
    }
    
    var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Button(action: {
                HapticManager.selection()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showingNotes.toggle()
                }
            }) {
                HStack {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "note.text")
                            .font(.title2)
                            .foregroundStyle(Color.primaryPurple)
                        Text("Additional Notes")
                            .font(WellnessFont.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    Image(systemName: showingNotes ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.primaryPurple)
                }
                .padding(Spacing.md)
                .background(Color.secondaryCardBackground)
                .cornerRadius(CornerRadius.md)
            }
            .buttonStyle(.plain)
            
            if showingNotes {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("How are you feeling? Any observations?")
                        .font(WellnessFont.caption)
                        .foregroundStyle(.secondary)
                    TextField("Write your thoughts here...", text: $notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(5...10)
                        .padding(.top, Spacing.xxs)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
    }
    
    var headerView: some View {
        VStack(spacing: Spacing.md) {
            GradientCard(colors: [Color.primaryBlue, Color.primaryPurple]) {
                VStack(spacing: Spacing.xs) {
                    HStack {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text("Daily Log")
                                .font(WellnessFont.title)
                                .foregroundStyle(.white)
                            Text(Date(), style: .date)
                                .font(WellnessFont.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        Spacer()
                        VStack(spacing: Spacing.xxs) {
                            Text("\(Int(completionProgress * 100))%")
                                .font(WellnessFont.title2)
                                .foregroundStyle(.white)
                            Text("Complete")
                                .font(WellnessFont.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.3))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white)
                                .frame(width: geometry.size.width * completionProgress, height: 6)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: completionProgress)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.vertical, Spacing.sm)
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                mainContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay(saveConfirmationOverlay)
            .onAppear {
                loadEntries()
            }
        }
    }
    
    var saveConfirmationOverlay: some View {
        Group {
            if showingSaveConfirmation {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showingSaveConfirmation = false
                                resetForm()
                            }
                        }
                    
                    VStack(spacing: Spacing.md) {
                        AnimatedCheckmark()
                        
                        Text("Entry Saved!")
                            .font(WellnessFont.title2)
                            .fontWeight(.bold)
                        
                        Text("Your wellness log has been saved successfully.")
                            .font(WellnessFont.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                showingSaveConfirmation = false
                                resetForm()
                            }
                        }) {
                            Text("Continue")
                                .font(WellnessFont.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.primaryBlue)
                                .cornerRadius(CornerRadius.md)
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                    .padding(Spacing.xl)
                    .background(Color.cardBackground)
                    .cornerRadius(CornerRadius.xl)
                    .shadow(radius: 20)
                    .padding(Spacing.xl)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    
    private func saveEntry() {
        let symptoms = selectedSymptoms.map { type in
            Symptom(type: type, severity: Int(symptomSeverities[type] ?? 5.0))
        }
        
        var meds: [Medication] = []
        if tookMedication {
            meds = [Medication(name: "Medication taken", dosage: "As prescribed", timeTaken: Date())]
        }
        
        let entry = WellnessEntry(
            date: Date(),
            symptoms: symptoms,
            moodRating: Int(moodRating),
            energyLevel: Int(energyLevel),
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            medications: meds,
            waterIntake: waterIntake,
            exercise: exerciseDone ? exerciseDescription : "",
            customFields: [],
            notes: notes
        )
        
        entries.append(entry)
        saveEntries()
        
        HapticManager.notification(type: .success)
        withAnimation(.spring()) {
            showingSaveConfirmation = true
        }
    }
    
    private func resetForm() {
        moodRating = 5.0
        energyLevel = 5.0
        sleepHours = 7.0
        sleepQuality = .fair
        waterIntake = 64.0
        exerciseDone = false
        exerciseDescription = ""
        selectedSymptoms.removeAll()
        symptomSeverities.removeAll()
        tookMedication = false
        notes = ""
        showingNotes = false
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "wellnessEntries")
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "wellnessEntries"),
           let decoded = try? JSONDecoder().decode([WellnessEntry].self, from: data) {
            entries = decoded
        }
    }
}

// Helper functions for emojis
extension DailyLogView {
    func energyEmoji(for level: Double) -> String {
        switch level {
        case 0...2: return "🪫"
        case 2...4: return "😴"
        case 4...6: return "😐"
        case 6...8: return "😊"
        default: return "⚡️"
        }
    }
    
    func sleepEmoji(for hours: Double) -> String {
        switch hours {
        case 0...4: return "😵"
        case 4...6: return "😪"
        case 6...8: return "😌"
        default: return "😴"
        }
    }
}

// Emoji Mood Selector
struct EmojiMoodSelector: View {
    @Binding var selectedMood: Double
    
    let moods: [(emoji: String, label: String, value: Double)] = [
        ("😢", "Sad", 2),
        ("😟", "Low", 4),
        ("😐", "Okay", 5),
        ("😊", "Good", 7),
        ("😄", "Great", 9)
    ]
    
    func moodBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: CornerRadius.md)
            .fill(isSelected ? Color.primaryBlue.opacity(0.1) : Color.clear)
    }
    
    func moodBorder(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: CornerRadius.md)
            .stroke(isSelected ? Color.primaryBlue : Color.clear, lineWidth: 2)
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.xs) {
                ForEach(moods, id: \.value) { mood in
                    Button(action: {
                        HapticManager.impact(style: .medium)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedMood = mood.value
                        }
                    }) {
                        VStack(spacing: Spacing.xxs) {
                            Text(mood.emoji)
                                .font(.system(size: 36))
                                .scaleEffect(selectedMood == mood.value ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                            
                            Text(mood.label)
                                .font(WellnessFont.caption)
                                .fontWeight(selectedMood == mood.value ? .semibold : .regular)
                                .foregroundStyle(selectedMood == mood.value ? Color.primaryBlue : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(moodBackground(isSelected: selectedMood == mood.value))
                        .overlay(moodBorder(isSelected: selectedMood == mood.value))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Fine-tune slider
            VStack(spacing: Spacing.xs) {
                HStack {
                    Text("Fine-tune")
                        .font(WellnessFont.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(selectedMood))/10")
                        .font(WellnessFont.headline)
                        .foregroundStyle(Color.primaryBlue)
                }
                
                Slider(value: Binding(
                    get: { selectedMood },
                    set: { newValue in
                        selectedMood = newValue
                        HapticManager.selection()
                    }
                ), in: 1...10, step: 1)
                    .tint(.primaryBlue)
            }
        }
        .cardStyle()
    }
}

// Interactive Slider Card
struct InteractiveSliderCard: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 1...10
    var step: Double = 1.0
    let icon: String
    let color: Color
    var emoji: String = ""
    var valueFormat: String = "%.0f/10"
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: icon)
                        .font(WellnessFont.title2)
                        .foregroundStyle(color)
                    Text(title)
                        .font(WellnessFont.callout)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                HStack(spacing: Spacing.xs) {
                    if !emoji.isEmpty {
                        Text(emoji)
                            .font(.title2)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Text(String(format: valueFormat, value))
                        .font(WellnessFont.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(color)
                }
            }
            
            Slider(value: Binding(
                get: { value },
                set: { newValue in
                    value = newValue
                    HapticManager.selection()
                }
            ), in: range, step: step)
                .tint(color)
        }
        .cardStyle()
    }
}

// Interactive Quality Picker
struct InteractiveQualityPicker: View {
    @Binding var selection: SleepQuality
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Sleep Quality")
                .font(WellnessFont.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            HStack(spacing: Spacing.xs) {
                ForEach(SleepQuality.allCases, id: \.self) { quality in
                    Button(action: {
                        HapticManager.impact(style: .light)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selection = quality
                        }
                    }) {
                        VStack(spacing: Spacing.xxs) {
                            Image(systemName: qualityIcon(for: quality))
                                .font(.title3)
                                .foregroundStyle(selection == quality ? .white : .sleepPurple)
                            
                            Text(qualityShortName(for: quality))
                                .font(WellnessFont.caption)
                                .fontWeight(selection == quality ? .semibold : .regular)
                                .foregroundStyle(selection == quality ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(selection == quality ? Color.sleepPurple : Color.secondaryCardBackground)
                        )
                        .scaleEffect(selection == quality ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selection)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .cardStyle()
    }
    
    func qualityIcon(for quality: SleepQuality) -> String {
        switch quality {
        case .excellent: return "star.fill"
        case .good: return "moon.stars.fill"
        case .fair: return "moon.fill"
        case .poor: return "moon.haze.fill"
        case .veryPoor: return "moon.zzz.fill"
        }
    }
    
    func qualityShortName(for quality: SleepQuality) -> String {
        switch quality {
        case .excellent: return "Great"
        case .good: return "Good"
        case .fair: return "Fair"
        case .poor: return "Poor"
        case .veryPoor: return "Bad"
        }
    }
}

// Improved Symptom Tag View
struct ImprovedSymptomTagView: View {
    @Binding var selectedSymptoms: Set<SymptomType>
    @Binding var symptomSeverities: [SymptomType: Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Symptom tags
            FlowLayout(spacing: Spacing.xs) {
                ForEach(SymptomType.allCases, id: \.self) { symptom in
                    ImprovedSymptomTag(
                        symptom: symptom,
                        isSelected: selectedSymptoms.contains(symptom),
                        onTap: {
                            if selectedSymptoms.contains(symptom) {
                                selectedSymptoms.remove(symptom)
                                symptomSeverities.removeValue(forKey: symptom)
                            } else {
                                selectedSymptoms.insert(symptom)
                                symptomSeverities[symptom] = 5.0
                            }
                        }
                    )
                }
            }
            .cardStyle()
            
            // Severity sliders for selected symptoms
            if !selectedSymptoms.isEmpty {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(selectedSymptoms).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { symptom in
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            HStack {
                                HStack(spacing: Spacing.xs) {
                                    Text(symptomEmoji(for: symptom))
                                        .font(.title3)
                                    Text(symptom.rawValue)
                                        .font(WellnessFont.callout)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                Text(severityLabel(for: symptomSeverities[symptom] ?? 5))
                                    .font(WellnessFont.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(severityColor(for: symptomSeverities[symptom] ?? 5))
                                    .cornerRadius(12)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.secondaryCardBackground)
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    severityColor(for: symptomSeverities[symptom] ?? 5).opacity(0.7),
                                                    severityColor(for: symptomSeverities[symptom] ?? 5)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * (symptomSeverities[symptom] ?? 5) / 10,
                                            height: 12
                                        )
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: symptomSeverities[symptom])
                                }
                            }
                            .frame(height: 12)
                            
                            Slider(
                                value: Binding(
                                    get: { symptomSeverities[symptom] ?? 5.0 },
                                    set: { newValue in
                                        symptomSeverities[symptom] = newValue
                                        HapticManager.selection()
                                    }
                                ),
                                in: 1...10,
                                step: 1
                            )
                            .tint(severityColor(for: symptomSeverities[symptom] ?? 5))
                        }
                        .padding(Spacing.md)
                        .background(Color.secondaryCardBackground)
                        .cornerRadius(CornerRadius.md)
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedSymptoms)
            }
        }
    }
    
    func symptomEmoji(for symptom: SymptomType) -> String {
        switch symptom {
        case .headache: return "🤕"
        case .fatigue: return "😮‍💨"
        case .pain: return "😣"
        case .nausea: return "🤢"
        case .dizziness: return "😵‍💫"
        case .other: return "🩹"
        }
    }
    
    func severityLabel(for severity: Double) -> String {
        switch Int(severity) {
        case 1...3: return "Mild"
        case 4...6: return "Moderate"
        case 7...8: return "Severe"
        default: return "Extreme"
        }
    }
    
    func severityColor(for severity: Double) -> Color {
        switch Int(severity) {
        case 1...3: return .moodGood
        case 4...6: return .moodFair
        case 7...8: return .exerciseOrange
        default: return .moodPoor
        }
    }
}

// Improved Symptom Tag
struct ImprovedSymptomTag: View {
    let symptom: SymptomType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.impact(style: .light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onTap()
            }
        }) {
            HStack(spacing: Spacing.xs) {
                Text(symptomEmoji(for: symptom))
                    .font(.body)
                
                Text(symptom.rawValue)
                    .font(WellnessFont.callout)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.exerciseOrange : Color.secondaryCardBackground)
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.exerciseOrange : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(color: isSelected ? Color.exerciseOrange.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    func symptomEmoji(for symptom: SymptomType) -> String {
        switch symptom {
        case .headache: return "🤕"
        case .fatigue: return "😮‍💨"
        case .pain: return "😣"
        case .nausea: return "🤢"
        case .dizziness: return "😵‍💫"
        case .other: return "🩹"
        }
    }
}

// Section Header Component
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(WellnessFont.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primaryBlue, .primaryPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(WellnessFont.title2)
        }
    }
}

// Flow Layout for wrapping tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

#Preview {
    DailyLogView()
}
