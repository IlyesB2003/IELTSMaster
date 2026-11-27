import SwiftUI
import AppKit
import IELTSCore

@main
struct IELTSMasterApp: App {
    @StateObject private var appState = AppState()

    init() {
        if let logo = IMBrandLogoView.cachedImage {
            NSApplication.shared.applicationIconImage = logo
        }
    }

    var body: some Scene {
        WindowGroup("IELTS Master") {
            MainNavigationView()
                .environmentObject(appState)
        }
        .defaultSize(width: 1280, height: 820)
        .windowResizability(.contentMinSize)
        .commands {
            CommandMenu("Go") {
                Button("Today") { go(.dashboard) }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Smart Practice") { go(.practice) }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Skills Coach") { go(.coach) }
                    .keyboardShortcut("3", modifiers: .command)
                Button("Full Mock Exams") { go(.fullMockExams) }
                    .keyboardShortcut("4", modifiers: .command)
                Button("AI Teacher") { go(.aiTeacher) }
                    .keyboardShortcut("5", modifiers: .command)
                Button("Writing") { go(.writing) }
                    .keyboardShortcut("6", modifiers: .command)
                Button("Speaking") { go(.speaking) }
                    .keyboardShortcut("7", modifiers: .command)
                Button("Mistake Notebook") { go(.mistakeNotebook) }
                    .keyboardShortcut("8", modifiers: .command)
                Button("Progress & Analytics") { go(.progressAnalytics) }
                    .keyboardShortcut("9", modifiers: .command)
                Divider()
                Button("New Reading Set") {
                    if !appState.isExamFullScreenLocked { _ = appState.startNextPractice(.reading) }
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
                Button("New Listening Set") {
                    if !appState.isExamFullScreenLocked { _ = appState.startNextPractice(.listening) }
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                Button("Placement Test") { appState.showDiagnosticSheet = true }
                    .keyboardShortcut("d", modifiers: [.command, .shift])
            }
        }
    }

    private func go(_ section: SidebarSection) {
        guard !appState.isExamFullScreenLocked else { return }
        appState.selectedSection = section
    }
}
