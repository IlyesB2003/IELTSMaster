import SwiftUI
import IELTSCore

public struct MistakeNotebookView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var statusFilter: String = "Active"
    @LocalState private var searchQuery: String = ""

    public init() {}

    private var filteredMistakes: [MistakeEntry] {
        app.mistakes.filter { entry in
            let statusOK: Bool
            switch statusFilter {
            case "Active": statusOK = entry.masteryStatus != .mastered
            case "Recurring": statusOK = entry.isRecurringPattern && entry.masteryStatus != .mastered
            case "Mastered": statusOK = entry.masteryStatus == .mastered
            default: statusOK = true
            }
            let queryOK = searchQuery.isEmpty
                || entry.errorCategory.localizedCaseInsensitiveContains(searchQuery)
                || entry.originalPrompt.localizedCaseInsensitiveContains(searchQuery)
                || entry.relatedGrammarRule.localizedCaseInsensitiveContains(searchQuery)
            return statusOK && queryOK
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Intelligent mistake notebook",
                    subtitle: "Automatically collects and classifies mistakes across Listening, Reading, Writing, and Grammar, detects recurring error patterns, and generates targeted AI revision sessions.",
                    badgeText: "\(app.recurringMistakes.count) recurring pattern(s)"
                )

                IMCard {
                    IMFlow(spacing: IMTheme.sp100) {
                        Picker("Filter", selection: $statusFilter) {
                            Text("Active").tag("Active")
                            Text("Recurring Patterns").tag("Recurring")
                            Text("Mastered").tag("Mastered")
                            Text("All").tag("All")
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 380)

                        TextField("Search category or rule...", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 240)

                        Spacer()

                        Button("AI revision from mistakes") {
                            app.launchMistakeRevisionWithTeacher()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                if filteredMistakes.isEmpty {
                    IMEmptyState(
                        icon: "checkmark.circle",
                        title: "No mistakes in this view",
                        message: "Mistakes are automatically captured when you submit Listening, Reading, Grammar, or Writing rubric assessments."
                    )
                } else {
                    ForEach(filteredMistakes) { item in
                        IMCard {
                            HStack {
                                IMBadge(text: item.sourceModule)
                                IMBadge(text: item.errorCategory, tint: item.isRecurringPattern ? IMTheme.statusWarning : nil)
                                if item.isRecurringPattern {
                                    IMBadge(text: "Recurring (\(item.recurrenceCount)x)", tint: IMTheme.statusDanger)
                                }
                                Spacer()
                                Picker("Status", selection: Binding(
                                    get: { item.masteryStatus },
                                    set: { app.updateMistakeMastery(id: item.id, status: $0) }
                                )) {
                                    ForEach(MasteryStatus.allCases, id: \.self) { st in
                                        Text(st.rawValue).tag(st)
                                    }
                                }
                                .frame(width: 140)
                            }
                            Text(item.originalPrompt).imText(.body4)
                            HStack(spacing: IMTheme.sp200) {
                                Text("Your answer: \(item.learnerAnswer)").imText(.caption2).foregroundStyle(IMTheme.statusDanger)
                                Text("Correct: \(item.correctAnswer)").imText(.caption2).foregroundStyle(IMTheme.statusSuccess)
                            }
                            Text(item.explanation).imText(.body6).foregroundStyle(.secondary)
                            Text("Rule: \(item.relatedGrammarRule) • Next revision: \(item.nextRevisionDate.formatted(date: .abbreviated, time: .omitted))")
                                .imText(.caption5)
                                .foregroundStyle(.secondary)
                            if let ar = item.arabicExplanation, !ar.isEmpty, app.profile.languageMode != .englishImmersion {
                                IMArabicBlock(text: ar)
                            }
                        }
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
    }
}
