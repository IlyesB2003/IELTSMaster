import SwiftUI
import IELTSCore

public struct MainNavigationView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    private let groups: [(title: String?, sections: [SidebarSection])] = [
        (nil, [.dashboard, .practice, .coach, .learningPlan]),
        ("Exam", [.fullMockExams, .listening, .reading, .writing, .speaking]),
        ("Learn", [.aiTeacher, .grammar, .vocabulary, .pronunciationLab, .academicEnglish]),
        ("Review", [.mistakeNotebook, .progressAnalytics]),
        ("Library", [.resourceLibrary, .aiModelManager, .settings])
    ]

    public var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 200, ideal: 228, max: 290)
        } detail: {
            detail
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(IMTheme.canvasBackground(colorScheme))
        }
        .frame(minWidth: 820, minHeight: 560)
        .sheet(isPresented: $app.showDiagnosticSheet) {
            DiagnosticPlacementView()
                .environmentObject(app)
        }
        .task {
            await app.refreshOllamaModels()
        }
    }

    // MARK: Sidebar

    private var sidebar: some View {
        List(selection: Binding(
            get: { Optional(app.selectedSection) },
            set: { if let val = $0, !app.isExamFullScreenLocked { app.selectedSection = val } }
        )) {
            HStack(spacing: IMTheme.sp75) {
                IMBrandLogoView(size: 34)
                VStack(alignment: .leading, spacing: 0) {
                    Text("IELTS Master").imText(.title3)
                    Text("Academic").imText(.caption5).foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, IMTheme.sp50)
            .selectionDisabled()

            ForEach(groups.indices, id: \.self) { i in
                if let title = groups[i].title {
                    Section(title) {
                        ForEach(groups[i].sections) { sidebarRow($0) }
                    }
                } else {
                    Section {
                        ForEach(groups[i].sections) { sidebarRow($0) }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) { sidebarFooter }
    }

    private var sidebarFooter: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp75) {
            HStack(alignment: .firstTextBaseline) {
                Text("Band \(String(format: "%.1f", app.profile.estimatedOverallBand))")
                    .imText(.title4)
                    .monospacedDigit()
                Spacer()
                TargetBandMenu(compact: true)
            }
            IMProgressBar(value: app.profile.estimatedOverallBand / max(app.profile.targetBand, 1), tint: IMTheme.accentPrimary, height: 5)
            Text("Estimate · \(app.profile.assessmentConfidence.rawValue) confidence")
                .imText(.caption5)
                .foregroundStyle(.secondary)
        }
        .padding(IMTheme.sp100)
        .background(.bar)
    }

    @ViewBuilder
    private func sidebarRow(_ section: SidebarSection) -> some View {
        Label {
            HStack {
                Text(section.rawValue).lineLimit(1)
                Spacer(minLength: 4)
                if let badge = badge(for: section) {
                    Text(badge.text)
                        .font(.system(size: 10, weight: .semibold))
                        .monospacedDigit()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(badge.tint.opacity(0.16)))
                        .foregroundStyle(badge.tint)
                }
            }
        } icon: {
            Image(systemName: section.symbol)
                .foregroundStyle(iconColor(for: section))
        }
        .tag(section)
        .opacity(app.isExamFullScreenLocked && section != .fullMockExams ? 0.35 : 1.0)
    }

    private func badge(for section: SidebarSection) -> (text: String, tint: Color)? {
        switch section {
        case .mistakeNotebook:
            let open = app.mistakes.filter { $0.masteryStatus != .mastered }.count
            return open > 0 ? ("\(open)", IMTheme.statusWarning) : nil
        case .vocabulary:
            return app.dueVocabularyCount > 0 ? ("\(app.dueVocabularyCount)", IMTheme.accentPrimary) : nil
        case .coach:
            let weak = app.weakestSkills.count
            return weak > 0 ? ("\(weak)", IMTheme.statusDanger) : nil
        case .practice:
            let fresh = app.unseenReadingCount + app.unseenListeningCount
            return fresh > 0 ? ("\(fresh) new", IMTheme.brandTeal) : nil
        default:
            return nil
        }
    }

    private func iconColor(for section: SidebarSection) -> Color {
        switch section {
        case .listening: return IMTheme.accentListening
        case .reading: return IMTheme.accentReading
        case .writing: return IMTheme.accentWriting
        case .speaking, .pronunciationLab: return IMTheme.accentSpeaking
        case .mistakeNotebook: return IMTheme.statusWarning
        case .coach: return IMTheme.statusDanger
        case .practice: return IMTheme.brandTeal
        case .dashboard: return IMTheme.brandGold
        case .aiTeacher, .fullMockExams: return IMTheme.accentPrimary
        default: return .secondary
        }
    }

    // MARK: Detail

    @ViewBuilder
    private var detail: some View {
        switch app.selectedSection {
        case .dashboard: DashboardView()
        case .practice: PracticeHubView()
        case .coach: SkillsCoachView()
        case .learningPlan: LearningPlanView()
        case .aiTeacher: AITeacherView()
        case .fullMockExams: FullMockExamsView()
        case .listening: ListeningView()
        case .reading: ReadingView()
        case .writing: WritingView()
        case .speaking: SpeakingView()
        case .grammar: GrammarView()
        case .vocabulary: VocabularyView()
        case .pronunciationLab: PronunciationLabView()
        case .academicEnglish: AcademicEnglishView()
        case .mistakeNotebook: MistakeNotebookView()
        case .progressAnalytics: ProgressAnalyticsView()
        case .resourceLibrary: ResourceLibraryView()
        case .aiModelManager: AIModelManagerView()
        case .settings: SettingsView()
        }
    }
}

/// Lets the learner change the target band from anywhere it is shown.
struct TargetBandMenu: View {
    @EnvironmentObject private var app: AppState
    var compact = false

    var body: some View {
        Menu {
            Picker("Target band", selection: Binding(
                get: { app.profile.targetBand },
                set: { app.setTargetBand($0) }
            )) {
                ForEach(AppState.targetBandOptions, id: \.self) { band in
                    Text(label(for: band)).tag(band)
                }
            }
            .pickerStyle(.inline)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "flag.checkered")
                Text("Target \(String(format: "%.1f", app.profile.targetBand))")
            }
            .font(.system(size: compact ? 11 : 11, weight: .semibold))
            .foregroundStyle(IMTheme.brandGold)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.visible)
        .fixedSize()
        .help("Change your target band")
        .disabled(app.isExamFullScreenLocked)
    }

    private func label(for band: Double) -> String {
        let b = String(format: "%.1f", band)
        switch band {
        case ..<6.0: return "\(b) · Modest user"
        case ..<7.0: return "\(b) · Competent user"
        case ..<8.0: return "\(b) · Good user"
        case ..<9.0: return "\(b) · Very good user"
        default: return "\(b) · Expert user"
        }
    }
}
