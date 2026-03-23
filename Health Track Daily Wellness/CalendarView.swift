//
//  CalendarView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct CalendarView: View {
    @State private var entries: [WellnessEntry] = []
    @State private var currentMonth = Date()
    @State private var selectedDate: Date?
    @State private var showingEntryDetail = false
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var currentStreak: Int {
        calculateStreak()
    }
    
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Streak Stats
                    HStack(spacing: Spacing.md) {
                        GradientCard(colors: [.orange, .red]) {
                            VStack(spacing: Spacing.xs) {
                                HStack {
                                    BouncingIcon(systemName: "flame.fill", color: .white)
                                    Spacer()
                                }
                                Text("\(currentStreak)")
                                    .font(WellnessFont.largeTitle)
                                    .foregroundStyle(.white)
                                Text("Current Streak")
                                    .font(WellnessFont.caption)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        GradientCard(colors: [.yellow, .orange]) {
                            VStack(spacing: Spacing.xs) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                    Spacer()
                                }
                                Text("\(longestStreak)")
                                    .font(WellnessFont.largeTitle)
                                    .foregroundStyle(.white)
                                Text("Longest Streak")
                                    .font(WellnessFont.caption)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Month Navigation
                    HStack {
                        Button(action: {
                            HapticManager.selection()
                            previousMonth()
                        }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primaryBlue, .primaryPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Spacer()
                        
                        Text(monthYearString)
                            .font(WellnessFont.title)
                        
                        Spacer()
                        
                        Button(action: {
                            HapticManager.selection()
                            nextMonth()
                        }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primaryBlue, .primaryPurple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Calendar Grid
                    VStack(spacing: 12) {
                        // Weekday headers
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(weekdaySymbols, id: \.self) { symbol in
                                Text(symbol)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Calendar days
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(daysInMonth, id: \.self) { date in
                                if let date = date {
                                    CalendarDayCell(
                                        date: date,
                                        entry: getEntry(for: date),
                                        isToday: calendar.isDateInToday(date),
                                        isSelected: selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
                                    )
                                    .onTapGesture {
                                        handleDayTap(date)
                                    }
                                } else {
                                    Color.clear
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood Legend")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            LegendItem(color: .green, text: "Great (8-10)")
                            LegendItem(color: .blue, text: "Good (5-7)")
                            LegendItem(color: .orange, text: "Low (1-4)")
                        }
                        
                        HStack(spacing: 16) {
                            LegendItem(color: .gray.opacity(0.3), text: "No entry")
                            LegendItem(color: .clear, border: .blue, text: "Today")
                        }
                    }
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.vertical)
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEntryDetail) {
                if let date = selectedDate, let entry = getEntry(for: date) {
                    NavigationStack {
                        EntryDetailView(entry: entry)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        showingEntryDetail = false
                                    }
                                }
                            }
                    }
                } else if let date = selectedDate {
                    NoEntryView(date: date)
                }
            }
            .onAppear {
                loadEntries()
            }
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        // Rearrange to start with Sunday
        return symbols
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        let daysCount = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        var days: [Date?] = []
        
        // Add leading empty cells
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of the month
        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getEntry(for date: Date) -> WellnessEntry? {
        entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    private func handleDayTap(_ date: Date) {
        HapticManager.impact(style: .light)
        selectedDate = date
        showingEntryDetail = true
    }
    
    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func calculateStreak() -> Int {
        let sortedEntries = entries.sorted { $0.date > $1.date }
        guard !sortedEntries.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check if there's an entry today or yesterday (to be forgiving)
        let hasRecentEntry = sortedEntries.contains { entry in
            calendar.isDateInToday(entry.date) || calendar.isDateInYesterday(entry.date)
        }
        
        guard hasRecentEntry else { return 0 }
        
        // Count consecutive days
        while true {
            let hasEntry = sortedEntries.contains { entry in
                calendar.isDate(entry.date, inSameDayAs: currentDate)
            }
            
            if hasEntry {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        let sortedEntries = entries.sorted { $0.date < $1.date }
        guard !sortedEntries.isEmpty else { return 0 }
        
        var longestStreak = 0
        var currentStreak = 1
        
        for i in 1..<sortedEntries.count {
            let previousDate = calendar.startOfDay(for: sortedEntries[i-1].date)
            let currentDate = calendar.startOfDay(for: sortedEntries[i].date)
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDate),
               calendar.isDate(currentDate, inSameDayAs: nextDay) {
                currentStreak += 1
            } else {
                longestStreak = max(longestStreak, currentStreak)
                currentStreak = 1
            }
        }
        
        return max(longestStreak, currentStreak)
    }
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "wellnessEntries"),
           let decoded = try? JSONDecoder().decode([WellnessEntry].self, from: data) {
            entries = decoded
        }
    }
}

// Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let entry: WellnessEntry?
    let isToday: Bool
    let isSelected: Bool
    @State private var isPressed = false
    
    private let calendar = Calendar.current
    
    var backgroundColor: Color {
        guard let entry = entry else {
            return Color.tertiaryBackground
        }
        
        // Color code based on mood rating
        switch entry.moodRating {
        case 8...10:
            return .moodExcellent
        case 5...7:
            return .moodGood
        case 1...4:
            return .moodPoor
        default:
            return .gray.opacity(0.3)
        }
    }
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Text("\(calendar.component(.day, from: date))")
                .font(WellnessFont.callout)
                .fontWeight(isToday ? .bold : entry != nil ? .semibold : .regular)
            
            // Small indicator dots for symptoms or notes
            if let entry = entry {
                HStack(spacing: 2) {
                    if !entry.symptoms.isEmpty {
                        Circle()
                            .fill(.red)
                            .frame(width: 5, height: 5)
                    }
                    if !entry.notes.isEmpty {
                        Circle()
                            .fill(Color.primaryPurple)
                            .frame(width: 5, height: 5)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(backgroundColor)
        .cornerRadius(CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .stroke(
                    isToday ? 
                    LinearGradient(
                        colors: [.primaryBlue, .primaryPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : 
                    LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                    lineWidth: 2.5
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .stroke(isSelected ? Color.primaryBlue : .clear, lineWidth: 3)
        )
        .shadow(color: entry != nil ? Color.black.opacity(0.1) : .clear, radius: 2, x: 0, y: 1)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// Streak Card
struct StreakCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Legend Item
struct LegendItem: View {
    var color: Color
    var border: Color? = nil
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(border ?? .clear, lineWidth: 2)
                )
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.caption)
        }
    }
}

// No Entry View
struct NoEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                
                Text("No Entry")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("You didn't log anything on \(date.formatted(date: .long, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
