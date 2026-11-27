import SwiftUI
import IELTSCore

/// "Today": where the learner stands, the single best next step, and one-click starts.
public struct DashboardView: View {
    @EnvironmentObject private var app: AppState

    public init() {}

    public var body: some View {
        IMPage {
            header
            hero
            nextStepCard
            IMSectionTitle("Start practising")
            quickStart
            IMAdaptiveGrid(minimum: 360) {
                weakSkillsCard
                recentResultsCard
            }
            todaysPlanCard
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                .imText(.caption1)
                .foregroundStyle(.secondary)
            Text(greeting).imText(.heading4)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = app.profile.displayName == "IELTS Academic Candidate" ? "" : ", \(app.profile.displayName.components(separatedBy: " ").first ?? "")"
        switch hour {
        case 5..<12: return "Good morning\(name)"
        case 12..<18: return "Good afternoon\(name)"
        default: return "Good evening\(name)"
        }
    }

    // MARK: Hero

    private var hero: some View {
        IMCard(padding: IMTheme.sp300) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: IMTheme.sp400) {
                    ringBlock
                    Divider().frame(height: 120)
                    moduleBands.frame(minWidth: 280)
                }
                VStack(alignment: .leading, spacing: IMTheme.sp300) {
                    ringBlock
                    moduleBands
                }
            }
        }
    }

    private var ringBlock: some View {
        HStack(spacing: IMTheme.sp200) {
            IMBandRing(score: app.profile.estimatedOverallBand, target: app.profile.targetBand, size: 116)
            VStack(alignment: .leading, spacing: 6) {
                Text("Estimated overall band").imText(.caption1).foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    TargetBandMenu()
                    IMBadge(text: "CEFR ~\(app.profile.estimatedCEFR.rawValue)")
                }
                Text(gapText)
                    .imText(.body6)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 240, alignment: .leading)
                Text("\(app.profile.assessmentConfidence.rawValue) confidence · based on \(app.attempts.count) result\(app.attempts.count == 1 ? "" : "s")")
                    .imText(.caption5)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var gapText: String {
        let gap = app.profile.targetBand - app.profile.estimatedOverallBand
        if !app.profile.hasCompletedDiagnostic { return "Take the placement test so this estimate reflects your real level." }
        if gap <= 0 { return "You're at or above your target. Keep it stable with full mocks." }
        return "\(String(format: "%.1f", gap)) bands to go. Raising your weakest module is the fastest way up."
    }

    private var moduleBands: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp100) {
            bandRow("Listening", app.profile.estimatedListeningBand)
            bandRow("Reading", app.profile.estimatedReadingBand)
            bandRow("Writing", app.profile.estimatedWritingBand)
            bandRow("Speaking", app.profile.estimatedSpeakingBand)
        }
    }

    private func bandRow(_ module: String, _ band: Double) -> some View {
        HStack(spacing: IMTheme.sp100) {
            Image(systemName: IMTheme.moduleSymbol(module))
                .foregroundStyle(IMTheme.moduleColor(module))
                .frame(width: 18)
            IMSkillBar(title: module, value: band / 9, tint: IMTheme.moduleColor(module), trailingText: String(format: "%.1f", band))
        }
    }

    // MARK: Next step

    private var nextStepCard: some View {
        let step = nextStep
        return HStack(alignment: .center, spacing: IMTheme.sp200) {
            Image(systemName: step.symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(IMTheme.brandGradient))
            VStack(alignment: .leading, spacing: 3) {
                Text("NEXT BEST STEP")
                    .font(.system(size: 10, weight: .bold)).tracking(0.8)
                    .foregroundStyle(IMTheme.accentPrimary)
                Text(step.title).imText(.title1)
                Text(step.detail)
                    .imText(.body6)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: IMTheme.sp100)
            Button(step.button, action: step.action)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding(IMTheme.sp200)
        .imSurface()
    }

    private var nextStep: (symbol: String, title: String, detail: String, button: String, action: () -> Void) {
        if !app.profile.hasCompletedDiagnostic {
            return ("scope", "Find your real level", "A short placement test sets your starting bands and the skills to work on first.", "Start test", { app.showDiagnosticSheet = true })
        }
        if let weak = app.weakestSkills.first {
            let pct = Int((weak.weightedAccuracy * 100).rounded())
            return ("target", "Fix: \(weak.title)", "You're getting \(pct)% right in \(weak.module) on this skill. Learn the method, then practise it with new questions.", "Learn & practise", { app.openLesson(for: weak.skillTag) })
        }
        if app.unseenReadingCount > 0 {
            return ("book.pages", "New Reading set", "A passage you haven't seen yet. Your answers build your skill profile.", "Start", { _ = app.startNextPractice(.reading) })
        }
        if let rec = app.recommendedMock {
            return ("doc.text.magnifyingglass", rec.isRetake ? "Retake a full mock" : "Take a full mock exam", rec.exam.title, "Open", { app.selectedSection = .fullMockExams })
        }
        return ("sparkles", "Generate fresh practice", "You've seen every written passage. Your AI model can write a new one.", "Generate", { _ = Task { await app.generateFreshReading() } })
    }

    // MARK: Quick start

    private var quickStart: some View {
        IMAdaptiveGrid(minimum: 250) {
            IMActionTile(symbol: "book.pages", title: "Reading set",
                         subtitle: app.unseenReadingCount > 0 ? "\(app.unseenReadingCount) new passage\(app.unseenReadingCount == 1 ? "" : "s") · targets weak skills" : "All seen · generate a fresh one",
                         tint: IMTheme.accentReading) {
                if app.unseenReadingCount > 0 { _ = app.startNextPractice(.reading) } else { app.selectedSection = .practice }
            }
            IMActionTile(symbol: "headphones", title: "Listening part",
                         subtitle: app.unseenListeningCount > 0 ? "\(app.unseenListeningCount) new part\(app.unseenListeningCount == 1 ? "" : "s") · multiple accents" : "All seen · oldest comes back first",
                         tint: IMTheme.accentListening) {
                _ = app.startNextPractice(.listening)
            }
            IMActionTile(symbol: "doc.text.magnifyingglass", title: "Full mock exam",
                         subtitle: app.recommendedMock.map { ($0.isRetake ? "Retake: " : "Next: ") + $0.exam.title } ?? "No exams available",
                         tint: IMTheme.accentPrimary) {
                app.selectedSection = .fullMockExams
            }
            IMActionTile(symbol: "pencil.line", title: "Writing task", subtitle: "Task 1 or Task 2 with criterion-by-criterion feedback", tint: IMTheme.accentWriting) {
                app.selectedSection = .writing
            }
            IMActionTile(symbol: "waveform.and.mic", title: "Speaking test", subtitle: "Parts 1–3 with an examiner voice and recording", tint: IMTheme.accentSpeaking) {
                app.selectedSection = .speaking
            }
            IMActionTile(symbol: "arrow.uturn.backward.circle", title: "Review mistakes",
                         subtitle: "\(app.mistakes.filter { $0.masteryStatus != .mastered }.count) open · revise what you got wrong",
                         tint: IMTheme.statusWarning) {
                app.selectedSection = .mistakeNotebook
            }
        }
    }

    // MARK: Weak skills

    private var weakSkillsCard: some View {
        IMCard {
            HStack {
                Text("Skills to work on").imText(.title2)
                Spacer()
                Button("Skills Coach") { app.selectedSection = .coach }
                    .buttonStyle(.link)
            }
            if app.weakestSkills.isEmpty {
                Text(app.skillEvents.count < 10
                     ? "Answer a few practice sets and your weak skills will appear here, measured from your real answers."
                     : "No weak skills right now: every skill you've practised is above 75%. Try harder material in a full mock.")
                    .imText(.body6)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(app.weakestSkills.prefix(4)) { skill in
                    Button {
                        app.openLesson(for: skill.skillTag)
                    } label: {
                        IMSkillBar(
                            title: "\(skill.title) · \(skill.module)",
                            value: skill.weightedAccuracy,
                            tint: IMTheme.accuracyColor(skill.weightedAccuracy),
                            trailingText: "\(Int((skill.weightedAccuracy * 100).rounded()))%"
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Recent results

    private var recentResultsCard: some View {
        IMCard {
            HStack {
                Text("Recent results").imText(.title2)
                Spacer()
                Button("All progress") { app.selectedSection = .progressAnalytics }
                    .buttonStyle(.link)
            }
            if app.attempts.isEmpty {
                Text("Your scored attempts will appear here.")
                    .imText(.body6)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(app.attempts.prefix(5)) { a in
                    HStack(spacing: IMTheme.sp100) {
                        Image(systemName: IMTheme.moduleSymbol(a.module))
                            .foregroundStyle(IMTheme.moduleColor(a.module))
                            .frame(width: 18)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(a.examTitle).imText(.body5).lineLimit(1)
                            Text("\(a.module) · \(a.date.formatted(.relative(presentation: .named)))")
                                .imText(.caption5)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 4)
                        Text(String(format: "%.1f", a.overallBand))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    // MARK: Plan

    @ViewBuilder
    private var todaysPlanCard: some View {
        let upcoming = app.currentPlan.sessions.filter { !$0.isCompleted && !$0.isBreak }.prefix(4)
        if !upcoming.isEmpty {
            IMCard {
                HStack {
                    Text("From your study plan").imText(.title2)
                    Spacer()
                    Button("Full plan") { app.selectedSection = .learningPlan }
                        .buttonStyle(.link)
                }
                ForEach(Array(upcoming), id: \.id) { s in
                    HStack(spacing: IMTheme.sp100) {
                        Button {
                            app.toggleSessionCompleted(s.id)
                        } label: {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Mark \(s.title) done")
                        VStack(alignment: .leading, spacing: 1) {
                            Text(s.title).imText(.body5)
                            Text("\(s.dayLabel) · \(s.durationMinutes) min · \(s.focusReason)")
                                .imText(.caption5)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        IMBadge(text: s.module, tint: IMTheme.moduleColor(s.module))
                    }
                }
            }
        }
    }
}
