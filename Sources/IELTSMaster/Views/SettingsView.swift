import SwiftUI
import AppKit
import UniformTypeIdentifiers
import IELTSCore

public struct SettingsView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var dataActionMessage: String = ""

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Settings & data privacy",
                    subtitle: "Configure bilingual English/Arabic assistance, learner goals, local SQLite backup and restore, JSON export, audio retention, and selective data deletion.",
                    badgeText: "Local-First Storage"
                )

                // Language Settings (Strictly English & Arabic only)
                IMCard {
                    Text("Language & bilingual scaffolding").imText(.title2)
                    Text("Supported languages: English (primary interface & education) and Arabic (optional RTL explanations). Arabic assistance is automatically disabled during Examination Mode.")
                        .imText(.caption2)
                        .foregroundStyle(.secondary)

                    Picker("Arabic assistance mode", selection: $app.profile.languageMode) {
                        ForEach(LanguageAssistanceMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .onChange(of: app.profile.languageMode) { _, _ in
                        app.saveProfileChanges()
                    }
                }

                // Learner Profile
                IMCard {
                    Text("Learner profile & targets").imText(.title2)
                    HStack {
                        TextField("Display name", text: $app.profile.displayName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 300)
                        Stepper("Target IELTS Band: \(String(format: "%.1f", app.profile.targetBand))", value: Binding(get: { app.profile.targetBand }, set: { app.setTargetBand($0) }), in: 5.5...9.0, step: 0.5)
                        Spacer()
                        Button("Save profile") {
                            app.saveProfileChanges()
                            dataActionMessage = "Learner profile saved."
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    TextField("Professional goal", text: $app.profile.professionalGoal)
                        .textFieldStyle(.roundedBorder)
                    Button("Retake initial diagnostic placement") {
                        app.showDiagnosticSheet = true
                    }
                    .buttonStyle(.bordered)
                }

                // Local Backup, Restore, Export & Retention
                IMCard {
                    Text("Data management, backup & audio retention").imText(.title2)
                    Text("SQLite database path: \(app.db.databaseURL.path)")
                        .imText(.caption5)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)

                    HStack(spacing: IMTheme.sp100) {
                        Button("Create SQLite backup...") { backupDatabase() }
                            .buttonStyle(.borderedProminent)
                        Button("Restore backup...") { restoreDatabase() }
                            .buttonStyle(.bordered)
                        Button("Export all data (JSON)...") { exportJSON() }
                            .buttonStyle(.bordered)
                    }

                    Divider()

                    HStack {
                        Stepper("Audio recording retention: \(app.profile.audioRetentionDays) days", value: $app.profile.audioRetentionDays, in: 7...365, step: 7)
                            .onChange(of: app.profile.audioRetentionDays) { _, _ in
                                app.saveProfileChanges()
                            }
                        Spacer()
                        Button("Purge expired audio now") {
                            let count = (try? app.db.purgeExpiredAudioRecordings(retentionDays: app.profile.audioRetentionDays)) ?? 0
                            app.recordings = (try? app.db.loadRecordings()) ?? []
                            dataActionMessage = "Purged \(count) expired audio recording(s)."
                        }
                        .buttonStyle(.bordered)
                    }

                    Divider()

                    Text("Selective data deletion").imText(.title4)
                    HStack(spacing: IMTheme.sp100) {
                        Button("Clear AI Teacher history") {
                            try? app.db.deleteCollection("teacher_messages")
                            app.teacherMessages = []
                            dataActionMessage = "AI Teacher conversation history cleared."
                        }
                        .buttonStyle(.bordered)

                        Button("Clear Mistake Notebook") {
                            try? app.db.deleteCollection("mistakes")
                            app.mistakes = []
                            dataActionMessage = "Mistake Notebook cleared."
                        }
                        .buttonStyle(.bordered)

                        Button("Clear Exam History") {
                            try? app.db.deleteCollection("exam_attempts")
                            app.attempts = []
                            dataActionMessage = "Examination history cleared."
                        }
                        .buttonStyle(.bordered)
                    }

                    if !dataActionMessage.isEmpty {
                        Text(dataActionMessage).imText(.caption4).foregroundStyle(IMTheme.statusSuccess)
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
    }

    private func backupDatabase() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "IELTSMaster_Backup.sqlite"
        if panel.runModal() == .OK, let url = panel.url {
            do {
                try app.db.createBackup(to: url)
                dataActionMessage = "SQLite backup created at \(url.lastPathComponent)."
            } catch {
                dataActionMessage = error.localizedDescription
            }
        }
    }

    private func restoreDatabase() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            do {
                try app.db.restoreBackup(from: url)
                app.profile = (try? app.db.loadProfile()) ?? app.profile
                app.attempts = (try? app.db.loadAttempts()) ?? []
                app.mistakes = (try? app.db.loadMistakes()) ?? []
                app.essays = (try? app.db.loadEssays()) ?? []
                dataActionMessage = "Backup restored from \(url.lastPathComponent)."
            } catch {
                dataActionMessage = error.localizedDescription
            }
        }
    }

    private func exportJSON() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "IELTSMaster_Export.json"
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let data = try app.db.exportAllDataJSON()
                try data.write(to: url)
                dataActionMessage = "Exported full learning data to \(url.lastPathComponent)."
            } catch {
                dataActionMessage = error.localizedDescription
            }
        }
    }
}
