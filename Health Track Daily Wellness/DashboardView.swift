//
//  DashboardView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var entries: [WellnessEntry] = []
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    ContentUnavailableView(
                        "No Entries Yet",
                        systemImage: "heart.text.square",
                        description: Text("Tap the + button to add your first wellness entry")
                    )
                } else {
                    ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                            EntryRowView(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
            .navigationTitle("Wellness Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView { newEntry in
                    entries.append(newEntry)
                    saveEntries()
                }
            }
            .onAppear {
                loadEntries()
            }
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        let sortedEntries = entries.sorted(by: { $0.date > $1.date })
        for index in offsets {
            if let entryIndex = entries.firstIndex(where: { $0.id == sortedEntries[index].id }) {
                entries.remove(at: entryIndex)
            }
        }
        saveEntries()
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

struct EntryRowView: View {
    let entry: WellnessEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date, style: .date)
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                Label("\(entry.moodRating)/10", systemImage: "face.smiling")
                    .font(.caption)
                Label("\(entry.energyLevel)/10", systemImage: "bolt.fill")
                    .font(.caption)
                Label(String(format: "%.1fh", entry.sleepHours), systemImage: "bed.double.fill")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            
            if !entry.symptoms.isEmpty {
                HStack {
                    ForEach(entry.symptoms.prefix(3)) { symptom in
                        Text(symptom.type.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                    if entry.symptoms.count > 3 {
                        Text("+\(entry.symptoms.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
}
