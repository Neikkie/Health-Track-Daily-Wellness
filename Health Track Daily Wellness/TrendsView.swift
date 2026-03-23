//
//  TrendsView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI
import Charts

struct TrendsView: View {
    @State private var entries: [WellnessEntry] = []
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: MetricType = .mood
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case all = "All Time"
        
        var days: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .all: return nil
            }
        }
    }
    
    enum MetricType: String, CaseIterable {
        case mood = "Mood"
        case energy = "Energy"
        case sleep = "Sleep"
        case water = "Water"
        
        var icon: String {
            switch self {
            case .mood: return "face.smiling"
            case .energy: return "bolt.fill"
            case .sleep: return "bed.double.fill"
            case .water: return "drop.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .mood: return .blue
            case .energy: return .yellow
            case .sleep: return .purple
            case .water: return .cyan
            }
        }
    }
    
    var filteredEntries: [WellnessEntry] {
        let sorted = entries.sorted { $0.date < $1.date }
        
        guard let days = selectedTimeRange.days else {
            return sorted
        }
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return sorted.filter { $0.date >= cutoffDate }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: selectedTimeRange) { _, _ in
                        HapticManager.selection()
                    }
                    
                    if filteredEntries.isEmpty {
                        ContentUnavailableView(
                            "No Data Yet",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("Start logging your wellness to see trends")
                        )
                        .padding(.top, 60)
                    } else {
                        // Weekly Averages
                        WeeklyAveragesView(entries: filteredEntries)
                            .padding(.horizontal)
                        
                        // Metric Selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(MetricType.allCases, id: \.self) { metric in
                                    MetricButton(
                                        metric: metric,
                                        isSelected: selectedMetric == metric,
                                        onTap: { selectedMetric = metric }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Chart
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: selectedMetric.icon)
                                    .foregroundStyle(selectedMetric.color)
                                Text("\(selectedMetric.rawValue) Over Time")
                                    .font(.headline)
                            }
                            
                            MetricChart(entries: filteredEntries, metric: selectedMetric)
                                .frame(height: 250)
                        }
                        .padding()
                        .background(.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Correlation Hints
                        CorrelationHintsView(entries: filteredEntries)
                            .padding(.horizontal)
                        
                        // Symptoms Frequency
                        if !filteredEntries.isEmpty {
                            SymptomFrequencyView(entries: filteredEntries)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Trends")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadEntries()
            }
        }
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "wellnessEntries"),
           let decoded = try? JSONDecoder().decode([WellnessEntry].self, from: data) {
            entries = decoded
        }
    }
}

// Weekly Averages View
struct WeeklyAveragesView: View {
    let entries: [WellnessEntry]
    
    var averages: (mood: Double, energy: Double, sleep: Double, water: Double) {
        guard !entries.isEmpty else { return (0, 0, 0, 0) }
        
        let mood = entries.map { Double($0.moodRating) }.reduce(0, +) / Double(entries.count)
        let energy = entries.map { Double($0.energyLevel) }.reduce(0, +) / Double(entries.count)
        let sleep = entries.map { $0.sleepHours }.reduce(0, +) / Double(entries.count)
        let water = entries.map { $0.waterIntake }.reduce(0, +) / Double(entries.count)
        
        return (mood, energy, sleep, water)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Averages")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                AverageCard(
                    title: "Mood",
                    value: String(format: "%.1f/10", averages.mood),
                    icon: "face.smiling",
                    color: .blue
                )
                
                AverageCard(
                    title: "Energy",
                    value: String(format: "%.1f/10", averages.energy),
                    icon: "bolt.fill",
                    color: .yellow
                )
                
                AverageCard(
                    title: "Sleep",
                    value: String(format: "%.1fh", averages.sleep),
                    icon: "bed.double.fill",
                    color: .purple
                )
                
                AverageCard(
                    title: "Water",
                    value: String(format: "%.0f oz", averages.water),
                    icon: "drop.fill",
                    color: .cyan
                )
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Average Card
struct AverageCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(.white.opacity(0.5))
        .cornerRadius(8)
    }
}

// Metric Button
struct MetricButton: View {
    let metric: TrendsView.MetricType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.impact(style: .light)
            onTap()
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: metric.icon)
                Text(metric.rawValue)
            }
            .font(WellnessFont.callout)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? metric.color : Color.secondaryCardBackground)
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .shadow(color: isSelected ? metric.color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}

// Metric Chart
struct MetricChart: View {
    let entries: [WellnessEntry]
    let metric: TrendsView.MetricType
    
    var chartData: [(date: Date, value: Double)] {
        entries.map { entry in
            let value: Double
            switch metric {
            case .mood:
                value = Double(entry.moodRating)
            case .energy:
                value = Double(entry.energyLevel)
            case .sleep:
                value = entry.sleepHours
            case .water:
                value = entry.waterIntake / 10 // Scale down for better visualization
            }
            return (entry.date, value)
        }
    }
    
    var body: some View {
        Chart {
            ForEach(chartData, id: \.date) { data in
                LineMark(
                    x: .value("Date", data.date),
                    y: .value("Value", data.value)
                )
                .foregroundStyle(metric.color)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", data.date),
                    y: .value("Value", data.value)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [metric.color.opacity(0.3), metric.color.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value("Date", data.date),
                    y: .value("Value", data.value)
                )
                .foregroundStyle(metric.color)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
}

// Correlation Hints View
struct CorrelationHintsView: View {
    let entries: [WellnessEntry]
    
    var correlations: [CorrelationHint] {
        var hints: [CorrelationHint] = []
        
        // Sleep vs Mood correlation
        let sleepMoodCorr = calculateCorrelation(
            x: entries.map { $0.sleepHours },
            y: entries.map { Double($0.moodRating) }
        )
        
        if sleepMoodCorr > 0.5 {
            hints.append(CorrelationHint(
                title: "Sleep & Mood",
                description: "Better sleep is linked to better mood",
                strength: sleepMoodCorr,
                icon: "bed.double.fill",
                color: .purple
            ))
        } else if sleepMoodCorr < -0.3 {
            hints.append(CorrelationHint(
                title: "Sleep & Mood",
                description: "Less sleep is linked to lower mood",
                strength: abs(sleepMoodCorr),
                icon: "bed.double.fill",
                color: .purple
            ))
        }
        
        // Water vs Energy correlation
        let waterEnergyCorr = calculateCorrelation(
            x: entries.map { $0.waterIntake },
            y: entries.map { Double($0.energyLevel) }
        )
        
        if waterEnergyCorr > 0.5 {
            hints.append(CorrelationHint(
                title: "Water & Energy",
                description: "More water intake is linked to higher energy",
                strength: waterEnergyCorr,
                icon: "drop.fill",
                color: .cyan
            ))
        }
        
        // Sleep vs Energy correlation
        let sleepEnergyCorr = calculateCorrelation(
            x: entries.map { $0.sleepHours },
            y: entries.map { Double($0.energyLevel) }
        )
        
        if sleepEnergyCorr > 0.5 {
            hints.append(CorrelationHint(
                title: "Sleep & Energy",
                description: "Better sleep is linked to higher energy levels",
                strength: sleepEnergyCorr,
                icon: "bolt.fill",
                color: .yellow
            ))
        }
        
        // Exercise impact on mood
        let exerciseDays = entries.filter { !$0.exercise.isEmpty }
        let noExerciseDays = entries.filter { $0.exercise.isEmpty }
        
        if !exerciseDays.isEmpty && !noExerciseDays.isEmpty {
            let avgMoodWithExercise = exerciseDays.map { Double($0.moodRating) }.reduce(0, +) / Double(exerciseDays.count)
            let avgMoodWithoutExercise = noExerciseDays.map { Double($0.moodRating) }.reduce(0, +) / Double(noExerciseDays.count)
            
            if avgMoodWithExercise > avgMoodWithoutExercise + 1.0 {
                hints.append(CorrelationHint(
                    title: "Exercise & Mood",
                    description: "Days with exercise tend to have better mood",
                    strength: 0.7,
                    icon: "figure.run",
                    color: .orange
                ))
            }
        }
        
        return hints
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
            
            if correlations.isEmpty {
                Text("Keep logging to discover patterns in your wellness data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(correlations) { hint in
                    CorrelationCard(hint: hint)
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func calculateCorrelation(x: [Double], y: [Double]) -> Double {
        guard x.count == y.count, x.count > 1 else { return 0 }
        
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        let sumY2 = y.map { $0 * $0 }.reduce(0, +)
        
        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
        
        guard denominator != 0 else { return 0 }
        
        return numerator / denominator
    }
}

// Correlation Hint Model
struct CorrelationHint: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let strength: Double
    let icon: String
    let color: Color
}

// Correlation Card
struct CorrelationCard: View {
    let hint: CorrelationHint
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: hint.icon)
                .font(.title2)
                .foregroundStyle(hint.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hint.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(hint.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Strength indicator
            HStack(spacing: 2) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Double(index) < (hint.strength * 3) ? hint.color : .gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding()
        .background(.white.opacity(0.5))
        .cornerRadius(8)
    }
}

// Symptom Frequency View
struct SymptomFrequencyView: View {
    let entries: [WellnessEntry]
    
    var symptomCounts: [(type: SymptomType, count: Int)] {
        var counts: [SymptomType: Int] = [:]
        
        for entry in entries {
            for symptom in entry.symptoms {
                counts[symptom.type, default: 0] += 1
            }
        }
        
        return counts.map { (type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symptom Frequency")
                .font(.headline)
            
            if symptomCounts.isEmpty {
                Text("No symptoms logged in this period")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.5))
                    .cornerRadius(8)
            } else {
                Chart {
                    ForEach(symptomCounts, id: \.type) { data in
                        BarMark(
                            x: .value("Count", data.count),
                            y: .value("Symptom", data.type.rawValue)
                        )
                        .foregroundStyle(.orange)
                    }
                }
                .frame(height: CGFloat(symptomCounts.count * 40))
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    TrendsView()
}
