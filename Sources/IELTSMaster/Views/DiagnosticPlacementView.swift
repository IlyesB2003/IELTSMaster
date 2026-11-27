import SwiftUI
import IELTSCore

/// Modern, step-by-step non-repeating adaptive diagnostic & practice test.
/// Pulls fresh unseen questions on every attempt, analyzes per-skill weaknesses,
/// records mistakes automatically, and launches guided teaching sessions.
public struct DiagnosticPlacementView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var activeItems: [AdaptiveQuizItem] = []
    @LocalState private var currentIndex: Int = 0
    @LocalState private var selectedAnswers: [String: Int] = [:]
    @LocalState private var writingSample: String = ""
    @LocalState private var didWrapPool: Bool = false
    @LocalState private var isFinished: Bool = false
    @LocalState private var computedResult: DiagnosticAssessmentResult?
    @LocalState private var weaknessReports: [SkillWeaknessReport] = []
    @LocalState private var showArabicReview: Bool = true

    public init() {}

    private var totalSteps: Int {
        activeItems.count + 1 // Questions + optional short writing sample
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Sleek Top Header
            HStack(spacing: IMTheme.sp100) {
                IMBrandLogoView(size: 42)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: IMTheme.sp75) {
                        Text("Adaptive IELTS Placement & Weakness Test").imText(.heading5)
                        IMBadge(
                            text: didWrapPool ? "Fresh Shuffled Cycle" : "100% Unseen Questions",
                            tint: IMTheme.accentPrimary
                        )
                    }
                    Text("Every attempt draws new non-repeating questions across Grammar, Vocabulary, Reading, and Listening, then builds a targeted teaching plan.")
                        .imText(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Close") {
                    app.audioService.stopSpeaking()
                    app.showDiagnosticSheet = false
                }
                .buttonStyle(.bordered)
            }
            .padding(IMTheme.sp300)

            // Progress Bar
            if !isFinished && !activeItems.isEmpty {
                ProgressView(value: Double(currentIndex + 1), total: Double(totalSteps))
                    .tint(IMTheme.accentPrimary)
                    .padding(.horizontal, IMTheme.sp300)
                    .padding(.bottom, IMTheme.sp100)
            }

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: IMTheme.sp300) {
                    if isFinished, let res = computedResult {
                        resultsAndTeachingView(result: res)
                    } else if currentIndex < activeItems.count {
                        questionStepView(item: activeItems[currentIndex])
                    } else {
                        writingStepView
                    }
                }
                .padding(IMTheme.sp300)
            }
        }
        .frame(minWidth: 680, idealWidth: 860, minHeight: 540, idealHeight: 680)
        .onAppear {
            showArabicReview = app.profile.languageMode != .englishImmersion
            if activeItems.isEmpty {
                startFreshTestAttempt()
            }
        }
    }

    // MARK: - Step-by-Step Question View

    @ViewBuilder
    private func questionStepView(item: AdaptiveQuizItem) -> some View {
        IMCard(padding: IMTheme.sp300) {
            HStack {
                IMBadge(text: "Question \(currentIndex + 1) of \(activeItems.count)", tint: IMTheme.accentPrimary)
                IMBadge(text: item.domain, tint: IMTheme.moduleColor(item.domain))
                IMBadge(text: item.skillCategory)
                Spacer()
                Text("\(selectedAnswers.count)/\(activeItems.count) answered")
                    .imText(.caption4)
                    .foregroundStyle(.secondary)
            }

            if let script = item.audioScript {
                HStack(spacing: IMTheme.sp100) {
                    Button {
                        if app.audioService.isSpeakingTTS {
                            app.audioService.stopSpeaking()
                        } else {
                            app.audioService.speak(text: script, accent: .british, rate: 0.48)
                        }
                    } label: {
                        Label(
                            app.audioService.isSpeakingTTS ? "Stop audio clip" : "Play listening audio",
                            systemImage: app.audioService.isSpeakingTTS ? "stop.circle.fill" : "play.circle.fill"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    Text("Listen carefully for self-corrections and distractors.")
                        .imText(.caption4)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, IMTheme.sp50)
            }

            Text(item.prompt)
                .imText(.title2)
                .padding(.vertical, IMTheme.sp75)

            VStack(spacing: IMTheme.sp100) {
                ForEach(item.options.indices, id: \.self) { idx in
                    let isSelected = selectedAnswers[item.id] == idx
                    Button {
                        selectedAnswers[item.id] = idx
                    } label: {
                        HStack(spacing: IMTheme.sp100) {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundStyle(isSelected ? IMTheme.accentPrimary : .secondary)
                            Text(item.options[idx])
                                .imText(.body2)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(IMTheme.sp200)
                        .background(isSelected ? IMTheme.accentPrimary.opacity(0.12) : Color.primary.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: IMTheme.radiusInner, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: IMTheme.radiusInner, style: .continuous)
                                .stroke(isSelected ? IMTheme.accentPrimary : Color.primary.opacity(0.10), lineWidth: isSelected ? 1.5 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Button("Previous") {
                    app.audioService.stopSpeaking()
                    if currentIndex > 0 { currentIndex -= 1 }
                }
                .buttonStyle(.bordered)
                .disabled(currentIndex == 0)

                Spacer()

                Button(currentIndex + 1 < activeItems.count ? "Next question →" : "Continue to short writing check →") {
                    app.audioService.stopSpeaking()
                    currentIndex += 1
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedAnswers[item.id] == nil)
            }
            .padding(.top, IMTheme.sp200)
        }
    }

    // MARK: - Final Step: Short Academic Writing Sample

    private var writingStepView: some View {
        IMCard(padding: IMTheme.sp300) {
            HStack {
                IMBadge(text: "Final Step", tint: IMTheme.accentWriting)
                Text("Short Academic Writing Check (Optional — 60 to 120 words)").imText(.title2)
                Spacer()
            }
            Text("Prompt: Why should countries invest in sustainable agriculture and evidence-based research? Write 4–6 clear academic sentences.")
                .imText(.body6)
                .foregroundStyle(.secondary)

            TextEditor(text: $writingSample)
                .font(.system(size: 15))
                .frame(minHeight: 150)
                .padding(IMTheme.sp75)
                .overlay(RoundedRectangle(cornerRadius: IMTheme.radiusInner).stroke(Color.primary.opacity(0.12), lineWidth: 1))

            HStack {
                Button("← Back to questions") {
                    currentIndex = max(0, activeItems.count - 1)
                }
                .buttonStyle(.bordered)

                Text("\(IELTSScoringEngine.countWords(in: writingSample)) words")
                    .imText(.caption4)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Finish & Analyze My Weaknesses") {
                    finishAndAnalyze()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }

    // MARK: - Results, Weakness Map & Instant Teaching Launchpad

    @ViewBuilder
    private func resultsAndTeachingView(result: DiagnosticAssessmentResult) -> some View {
        IMCard(padding: IMTheme.sp300) {
            HStack(spacing: IMTheme.sp300) {
                IMBandRing(score: result.overallBand, target: app.profile.targetBand, size: 108)
                VStack(alignment: .leading, spacing: IMTheme.sp75) {
                    HStack {
                        Text("Diagnostic Assessment Complete").imText(.heading5)
                        IMBadge(text: "Approx. CEFR \(result.estimatedCEFR.rawValue)", tint: IMTheme.accentPrimary)
                    }
                    HStack(spacing: IMTheme.sp100) {
                        IMBadge(text: "Listening: \(String(format: "%.1f", result.listeningBand))", tint: IMTheme.accentListening)
                        IMBadge(text: "Reading: \(String(format: "%.1f", result.readingBand))", tint: IMTheme.accentReading)
                        IMBadge(text: "Writing: \(String(format: "%.1f", result.writingBand))", tint: IMTheme.accentWriting)
                        IMBadge(text: "Speaking: \(String(format: "%.1f", result.speakingBand))", tint: IMTheme.accentSpeaking)
                    }
                    Text(result.cefrDisclaimer)
                        .imText(.caption5)
                        .foregroundStyle(.secondary)

                    HStack(spacing: IMTheme.sp100) {
                        Button {
                            startFreshTestAttempt()
                        } label: {
                            Label("Take another test (brand-new questions)", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            app.showDiagnosticSheet = false
                            app.launchMistakeRevisionWithTeacher()
                        } label: {
                            Label("Teach me all my mistakes now", systemImage: "person.bubble")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                Spacer()
            }
        }

        // Per-Skill Weakness Breakdown
        IMCard {
            Text("Skill-by-skill weakness diagnosis").imText(.title2)
            ForEach(weaknessReports) { report in
                HStack(spacing: IMTheme.sp100) {
                    IMSkillBar(
                        title: "\(report.skillCategory) (\(report.domain))",
                        value: report.accuracy,
                        tint: report.accuracy < 0.6 ? IMTheme.statusDanger : (report.accuracy < 1.0 ? IMTheme.statusWarning : IMTheme.statusSuccess),
                        trailingText: "\(report.correct)/\(report.total) (\(Int(report.accuracy * 100))%)"
                    )
                    Button("Teach me this") {
                        app.showDiagnosticSheet = false
                        app.teachSpecificWeakness(report.skillCategory, domain: report.domain)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }

        // Detailed Answer & Bilingual Teaching Review
        IMCard {
            HStack {
                Text("Question-by-question teaching review").imText(.title2)
                Spacer()
                if app.profile.languageMode != .englishImmersion {
                    Toggle("Arabic explanations", isOn: $showArabicReview)
                }
            }

            ForEach(activeItems.indices, id: \.self) { idx in
                let item = activeItems[idx]
                let picked = selectedAnswers[item.id] ?? -1
                let isRight = picked == item.correctIndex

                VStack(alignment: .leading, spacing: IMTheme.sp50) {
                    HStack {
                        IMBadge(text: "Q\(idx + 1) • \(item.skillCategory)")
                        IMBadge(
                            text: isRight ? "Correct" : "Needs teaching",
                            tint: isRight ? IMTheme.statusSuccess : IMTheme.statusDanger
                        )
                    }
                    Text(item.prompt).imText(.body4)
                    if !isRight && (0..<item.options.count).contains(picked) {
                        Text("Your answer: \(item.options[picked])").imText(.caption2).foregroundStyle(IMTheme.statusDanger)
                    }
                    Text("Correct answer: \(item.options[item.correctIndex])").imText(.caption2).foregroundStyle(IMTheme.statusSuccess)
                    Text("Rule: \(item.explanation)").imText(.body6).foregroundStyle(.secondary)
                    Text("Tip: \(item.teachingTip)").imText(.caption4).foregroundStyle(IMTheme.accentPrimary)
                    if showArabicReview && app.profile.languageMode != .englishImmersion {
                        IMArabicBlock(text: item.arabicExplanation)
                    }
                }
                Divider()
            }
        }
    }

    // MARK: - Actions

    private func startFreshTestAttempt() {
        app.audioService.stopSpeaking()
        let draw = AdaptiveQuestionBank.drawFreshSet(excluding: app.seenDiagnosticQuestionIDs)
        activeItems = draw.items
        didWrapPool = draw.didWrapPool
        if draw.didWrapPool {
            app.resetSeenDiagnosticQuestions()
        }
        currentIndex = 0
        selectedAnswers = [:]
        writingSample = ""
        isFinished = false
        computedResult = nil
        weaknessReports = []
    }

    private func finishAndAnalyze() {
        app.audioService.stopSpeaking()
        app.markDiagnosticQuestionsSeen(activeItems.map(\.id))

        let gItems = activeItems.filter { $0.domain == "Grammar" }
        let vItems = activeItems.filter { $0.domain == "Vocabulary" }
        let rItems = activeItems.filter { $0.domain == "Reading" }
        let lItems = activeItems.filter { $0.domain == "Listening" }

        let gCorrect = gItems.filter { selectedAnswers[$0.id] == $0.correctIndex }.count
        let vCorrect = vItems.filter { selectedAnswers[$0.id] == $0.correctIndex }.count
        let rCorrect = rItems.filter { selectedAnswers[$0.id] == $0.correctIndex }.count
        let lCorrect = lItems.filter { selectedAnswers[$0.id] == $0.correctIndex }.count

        // Log every wrong answer directly into the intelligent Mistake Notebook
        for item in activeItems {
            let picked = selectedAnswers[item.id] ?? -1
            if picked != item.correctIndex {
                let learnerAns = (0..<item.options.count).contains(picked) ? item.options[picked] : "(blank)"
                app.logMistake(MistakeEntry(
                    sourceModule: item.domain,
                    originalPrompt: item.prompt,
                    learnerAnswer: learnerAns,
                    correctAnswer: item.options[item.correctIndex],
                    explanation: item.explanation,
                    arabicExplanation: item.arabicExplanation,
                    errorCategory: item.skillCategory,
                    relatedGrammarRule: item.skillCategory
                ))
            }
        }

        let reports = AdaptiveQuestionBank.analyzeWeaknesses(items: activeItems, selectedAnswers: selectedAnswers)
        weaknessReports = reports
        app.latestWeaknessReports = reports

        let res = app.adaptiveEngine.evaluateDiagnostic(
            grammarCorrect: gCorrect, grammarTotal: gItems.count,
            vocabCorrect: vCorrect, vocabTotal: vItems.count,
            readingCorrect: rCorrect, readingTotal: rItems.count,
            listeningCorrect: lCorrect, listeningTotal: lItems.count,
            writingWordCount: IELTSScoringEngine.countWords(in: writingSample),
            writingSampleText: writingSample,
            speakingWordCount: 40
        )
        computedResult = res

        // Automatically persist attempt and update learner baseline
        app.recordExamAttempt(ExamAttemptRecord(
            examID: "adaptive-diag-\(Int(Date().timeIntervalSince1970))",
            examTitle: "Adaptive Diagnostic Test (\(activeItems.count) fresh Qs)",
            module: "Adaptive Diagnostic",
            sessionMode: .adaptive,
            durationSeconds: 300,
            listeningBand: res.listeningBand,
            readingBand: res.readingBand,
            writingBand: res.writingBand,
            speakingBand: res.speakingBand,
            overallBand: res.overallBand,
            notes: "Weakest area: \(reports.first?.skillCategory ?? "None")"
        ))
        app.profile.hasCompletedDiagnostic = true
        app.profile.estimatedCEFR = res.estimatedCEFR
        app.saveProfileChanges()
        app.regenerateStudyPlan(sessionMinutes: app.profile.preferredSessionMinutes)

        isFinished = true
    }
}
