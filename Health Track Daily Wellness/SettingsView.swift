//
//  SettingsView.swift
//  Health Track Daily Wellness
//
//  Created by Shanique Beckford on 3/22/26.
//

import SwiftUI
import UserNotifications
import PDFKit
import MessageUI

struct SettingsView: View {
    @State private var entries: [WellnessEntry] = []
    @State private var customFieldTemplates: [CustomFieldTemplate] = []
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var showingAddCustomField = false
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var exportedData: Data?
    @State private var exportedURL: URL?
    @State private var showingMessageCompose = false
    @State private var showingPermissionAlert = false
    @State private var showingExportAlert = false
    @State private var exportAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                // Reminders Section
                Section {
                    Toggle("Daily Reminder", isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            } else {
                                cancelReminders()
                            }
                        }
                    
                    if reminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: reminderTime) { _, _ in
                                scheduleReminder()
                            }
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Get a daily reminder to log your wellness")
                }
                
                // Custom Fields Section
                Section {
                    ForEach(customFieldTemplates) { template in
                        HStack {
                            Text(template.name)
                            Spacer()
                            if template.isDefault {
                                Text("Default")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteCustomField)
                    
                    Button(action: { showingAddCustomField = true }) {
                        Label("Add Custom Field", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Custom Fields")
                } footer: {
                    Text("Create reusable custom fields for quick logging")
                }
                
                // Export Data Section
                Section {
                    Button(action: { exportAsCSV() }) {
                        Label("Export as CSV", systemImage: "doc.text")
                    }
                    
                    Button(action: { exportAsPDF() }) {
                        Label("Export as PDF", systemImage: "doc.richtext")
                    }
                    
                    Button(action: { exportToMessages() }) {
                        Label("Share via Messages", systemImage: "message")
                    }
                } header: {
                    Text("Export Data")
                } footer: {
                    Text("Export your wellness data to share or backup")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Total Entries")
                        Spacer()
                        Text("\(entries.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAddCustomField) {
                AddCustomFieldTemplateView { template in
                    customFieldTemplates.append(template)
                    saveCustomFieldTemplates()
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedURL {
                    ShareSheet(items: [url])
                }
            }
            .sheet(isPresented: $showingMessageCompose) {
                if let data = exportedData {
                    MessageComposeView(data: data)
                }
            }
            .alert("Notifications Permission", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    reminderEnabled = false
                }
            } message: {
                Text("Please enable notifications in Settings to receive reminders")
            }
            .alert("Export Complete", isPresented: $showingExportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportAlertMessage)
            }
            .onAppear {
                loadEntries()
                loadCustomFieldTemplates()
                loadReminderSettings()
            }
        }
    }
    
    // MARK: - Reminder Functions
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    scheduleReminder()
                } else {
                    reminderEnabled = false
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func scheduleReminder() {
        guard reminderEnabled else { return }
        
        // Cancel existing reminders
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Create new reminder
        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your Wellness"
        content.body = "Take a moment to track your mood, energy, and symptoms"
        content.sound = .default
        
        // Set time components
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                saveReminderSettings()
            }
        }
    }
    
    private func cancelReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        saveReminderSettings()
    }
    
    private func saveReminderSettings() {
        UserDefaults.standard.set(reminderEnabled, forKey: "reminderEnabled")
        UserDefaults.standard.set(reminderTime, forKey: "reminderTime")
    }
    
    private func loadReminderSettings() {
        reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")
        if let savedTime = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            reminderTime = savedTime
        }
    }
    
    // MARK: - Custom Fields Functions
    
    private func deleteCustomField(at offsets: IndexSet) {
        customFieldTemplates.remove(atOffsets: offsets)
        saveCustomFieldTemplates()
    }
    
    private func saveCustomFieldTemplates() {
        if let encoded = try? JSONEncoder().encode(customFieldTemplates) {
            UserDefaults.standard.set(encoded, forKey: "customFieldTemplates")
        }
    }
    
    private func loadCustomFieldTemplates() {
        if let data = UserDefaults.standard.data(forKey: "customFieldTemplates"),
           let decoded = try? JSONDecoder().decode([CustomFieldTemplate].self, from: data) {
            customFieldTemplates = decoded
        } else {
            // Add some default templates
            customFieldTemplates = [
                CustomFieldTemplate(name: "Weather", isDefault: true),
                CustomFieldTemplate(name: "Stress Level", isDefault: true),
                CustomFieldTemplate(name: "Social Activity", isDefault: true)
            ]
        }
    }
    
    // MARK: - Export Functions
    
    private func exportAsCSV() {
        guard !entries.isEmpty else {
            exportAlertMessage = "No data to export. Start logging your wellness journey first!"
            showingExportAlert = true
            return
        }
        
        var csvText = "Date,Time,Mood,Energy,Sleep Hours,Sleep Quality,Water (oz),Exercise,Symptoms,Medications,Notes\n"
        
        let sortedEntries = entries.sorted { $0.date < $1.date }
        
        for entry in sortedEntries {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            let date = dateFormatter.string(from: entry.date)
            
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            let time = dateFormatter.string(from: entry.date)
            
            let symptoms = entry.symptoms.map { "\($0.type.rawValue)(\($0.severity))" }.joined(separator: "; ")
            let medications = entry.medications.map { "\($0.name) - \($0.dosage)" }.joined(separator: "; ")
            let notes = entry.notes.replacingOccurrences(of: "\n", with: " ")
            
            let row = "\(date),\(time),\(entry.moodRating),\(entry.energyLevel),\(entry.sleepHours),\(entry.sleepQuality.rawValue),\(entry.waterIntake),\(entry.exercise),\"\(symptoms)\",\"\(medications)\",\"\(notes)\"\n"
            csvText.append(row)
        }
        
        // Save to temporary file
        let fileName = "DovaHealth_\(Date().timeIntervalSince1970).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
            exportedURL = tempURL
            showingShareSheet = true
        } catch {
            exportAlertMessage = "Failed to create CSV file. Please try again."
            showingExportAlert = true
        }
    }
    
    private func exportAsPDF() {
        guard !entries.isEmpty else {
            exportAlertMessage = "No data to export. Start logging your wellness journey first!"
            showingExportAlert = true
            return
        }
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14)
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            
            // Title
            let title = "Wellness Report"
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            var yPosition: CGFloat = 90
            let leftMargin: CGFloat = 50
            let lineHeight: CGFloat = 20
            
            // Summary
            let summary = "Total Entries: \(entries.count)"
            summary.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
            yPosition += lineHeight * 2
            
            // Entries
            let sortedEntries = entries.sorted { $0.date > $1.date }.prefix(20)
            
            for entry in sortedEntries {
                // Check if we need a new page
                if yPosition > 700 {
                    context.beginPage()
                    yPosition = 50
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                
                let dateStr = dateFormatter.string(from: entry.date)
                dateStr.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
                yPosition += lineHeight
                
                let details = "Mood: \(entry.moodRating)/10  Energy: \(entry.energyLevel)/10  Sleep: \(String(format: "%.1f", entry.sleepHours))h"
                details.draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: bodyAttributes)
                yPosition += lineHeight
                
                if !entry.symptoms.isEmpty {
                    let symptoms = "Symptoms: " + entry.symptoms.map { $0.type.rawValue }.joined(separator: ", ")
                    symptoms.draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: bodyAttributes)
                    yPosition += lineHeight
                }
                
                if !entry.notes.isEmpty {
                    let notes = "Notes: \(entry.notes.prefix(100))"
                    notes.draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: bodyAttributes)
                    yPosition += lineHeight
                }
                
                yPosition += lineHeight / 2
            }
        }
        
        // Save to temporary file
        let fileName = "DovaHealth_Report_\(Date().timeIntervalSince1970).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            exportedURL = tempURL
            showingShareSheet = true
        } catch {
            exportAlertMessage = "Failed to create PDF report. Please try again."
            showingExportAlert = true
        }
    }
    
    private func exportToMessages() {
        guard !entries.isEmpty else {
            exportAlertMessage = "No data to export. Start logging your wellness journey first!"
            showingExportAlert = true
            return
        }
        
        guard MFMessageComposeViewController.canSendText() else {
            exportAlertMessage = "Messages is not available on this device. Please use CSV or PDF export instead."
            showingExportAlert = true
            return
        }
        
        let summary = generateTextSummary()
        exportedData = summary.data(using: .utf8)
        showingMessageCompose = true
    }
    
    private func generateTextSummary() -> String {
        var text = "📊 Wellness Summary\n\n"
        text += "Total Entries: \(entries.count)\n\n"
        
        if !entries.isEmpty {
            let avgMood = entries.map { Double($0.moodRating) }.reduce(0, +) / Double(entries.count)
            let avgEnergy = entries.map { Double($0.energyLevel) }.reduce(0, +) / Double(entries.count)
            let avgSleep = entries.map { $0.sleepHours }.reduce(0, +) / Double(entries.count)
            
            text += "📈 Averages:\n"
            text += "Mood: \(String(format: "%.1f", avgMood))/10\n"
            text += "Energy: \(String(format: "%.1f", avgEnergy))/10\n"
            text += "Sleep: \(String(format: "%.1f", avgSleep)) hours\n\n"
            
            let recentEntries = entries.sorted { $0.date > $1.date }.prefix(5)
            text += "📝 Recent Entries:\n\n"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            for entry in recentEntries {
                text += "\(dateFormatter.string(from: entry.date))\n"
                text += "Mood: \(entry.moodRating)/10  Energy: \(entry.energyLevel)/10\n"
                if !entry.symptoms.isEmpty {
                    text += "Symptoms: \(entry.symptoms.map { $0.type.rawValue }.joined(separator: ", "))\n"
                }
                text += "\n"
            }
        }
        
        return text
    }
    
    // MARK: - Data Loading
    
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "wellnessEntries"),
           let decoded = try? JSONDecoder().decode([WellnessEntry].self, from: data) {
            entries = decoded
        }
    }
}

// Custom Field Template Model
struct CustomFieldTemplate: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isDefault: Bool = false
}

// Add Custom Field Template View
struct AddCustomFieldTemplateView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (CustomFieldTemplate) -> Void
    
    @State private var fieldName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Field Name", text: $fieldName)
            }
            .navigationTitle("New Custom Field")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let template = CustomFieldTemplate(name: fieldName)
                        onSave(template)
                        dismiss()
                    }
                    .disabled(fieldName.isEmpty)
                }
            }
        }
    }
}

// Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Message Compose View
struct MessageComposeView: UIViewControllerRepresentable {
    let data: Data
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        
        if let text = String(data: data, encoding: .utf8) {
            controller.body = text
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: MessageComposeView
        
        init(_ parent: MessageComposeView) {
            self.parent = parent
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.dismiss()
        }
    }
}

#Preview {
    SettingsView()
}
