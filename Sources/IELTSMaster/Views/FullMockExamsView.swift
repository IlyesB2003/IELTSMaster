import SwiftUI
import IELTSCore

public struct FullMockExamsView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedDifficulty: String = "All"
    @LocalState private var searchQuery: String = ""
    @LocalState private var activeExam: MockExam?
    @LocalState private var activeStage: ExamModule = .listening
    @LocalState private var listeningResponses: [String: String] = [:]
    @LocalState private var readingResponses: [String: String] = [:]
    @LocalState private var writingTask1Draft: String = ""
    @LocalState private var writingTask2Draft: String = ""
    @LocalState private var speakingNotes: String = ""
    @LocalState private var completedReport: ExamAttemptRecord?
    @LocalState private var isScoring: Bool = false
    @StateObject private var stageTimer = ExamTimerEngine(durationSeconds: 32 * 60, allowsPause: false)

    public init() {}

    private var filteredExams: [MockExam] {
        app.mockExams.filter { exam in
            let diffOK = selectedDifficulty == "All" || exam.difficulty.rawValue == selectedDifficulty
            let searchOK = searchQuery.isEmpty
                || exam.title.localizedCaseInsensitiveContains(searchQuery)
                || exam.theme.localizedCaseInsensitiveContains(searchQuery)
            return diffOK && searchOK
        }
    }

    public var body: some View {
        if let exam = activeExam {
            activeSimulatorView(exam: exam)
        } else {
            examCatalogView
        }
    }

    private var examCatalogView: some View {
        IMPage {
            IMPageHeader(
                title: "Full mock exams",
                subtitle: "Complete IELTS Academic tests in the computer-delivered format: Listening, Reading, Writing and Speaking, timed, with no AI help or translation. Take each exam as often as you like; the next one you haven't taken is always recommended first.",
                badgeText: "\(app.mockExams.count) exam\(app.mockExams.count == 1 ? "" : "s")"
            )

            if let report = completedReport { lastResultCard(report) }

            if let rec = app.recommendedMock {
                HStack(spacing: IMTheme.sp200) {
                    Image(systemName: rec.isRetake ? "arrow.clockwise" : "star.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(IMTheme.brandGradient))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rec.isRetake ? "RECOMMENDED RETAKE" : "RECOMMENDED NEXT")
                            .font(.system(size: 10, weight: .bold)).tracking(0.8)
                            .foregroundStyle(IMTheme.accentPrimary)
                        Text(rec.exam.title).imText(.title1)
                        Text(rec.isRetake
                             ? "You've taken every exam. This is the one you've taken least. Your previous answers are not shown during the test."
                             : "You haven't taken this exam yet, so the score will reflect your real ability.")
                            .imText(.body6)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: IMTheme.sp100)
                    Button("Start exam") { startFullMock(rec.exam) }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
                .padding(IMTheme.sp200)
                .imSurface()
            }

            if app.mockExams.count > 4 {
                HStack(spacing: IMTheme.sp100) {
                    TextField("Search by theme or title", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 320)
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        Text("All levels").tag("All")
                        ForEach(DifficultyTier.allCases) { tier in
                            Text(tier.rawValue).tag(tier.rawValue)
                        }
                    }
                    .frame(maxWidth: 280)
                }
            }

            IMSectionTitle("All exams")
            IMAdaptiveGrid(minimum: 300) {
                ForEach(filteredExams) { exam in examCard(exam) }
            }
        }
    }

    private func examCard(_ exam: MockExam) -> some View {
        let history = app.attempts.filter { $0.examID == exam.id && $0.module == "Full Mock" }
        let attempts = max(history.count, app.exposure.attempts(forExam: exam.id))
        let best = history.map(\.overallBand).max()
        return IMCard(padding: IMTheme.sp200) {
            HStack(spacing: 6) {
                IMBadge(text: "Exam \(exam.examNumber)")
                IMBadge(text: exam.difficulty.rawValue.components(separatedBy: " (").first ?? "", tint: IMTheme.accentPrimary)
                Spacer(minLength: 0)
                if attempts == 0 {
                    IMBadge(text: "New", tint: IMTheme.brandTeal)
                } else {
                    IMBadge(text: "Taken \(attempts)×", tint: IMTheme.statusWarning)
                }
            }
            Text(exam.theme).imText(.title1)
            Text("Listening 4 parts · Reading 3 passages · Writing: \(exam.writingTask1.visualType.rawValue.lowercased()) + \(exam.writingTask2.essayType.rawValue.lowercased()) · Speaking 3 parts")
                .imText(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let best {
                HStack(spacing: 6) {
                    Text("Best").imText(.caption1).foregroundStyle(.secondary)
                    Text(String(format: "%.1f", best)).font(.system(size: 15, weight: .bold, design: .rounded)).monospacedDigit()
                    if let last = history.first {
                        Text("· last \(last.date.formatted(.relative(presentation: .named)))").imText(.caption2).foregroundStyle(.secondary)
                    }
                }
            }
            Button {
                startFullMock(exam)
            } label: {
                Label(attempts == 0 ? "Start exam" : "Retake exam", systemImage: attempts == 0 ? "play.fill" : "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(attempts == 0 ? IMTheme.accentPrimary : Color.secondary)
            .padding(.top, IMTheme.sp50)
        }
    }

    private func lastResultCard(_ report: ExamAttemptRecord) -> some View {
        IMCard(padding: IMTheme.sp300) {
            HStack {
                Text("Your result: \(report.examTitle)").imText(.title1)
                Spacer()
                IMBadge(text: report.speakingBand == nil
                        ? "Est. L/R/W \(String(format: "%.1f", report.overallBand))"
                        : "Est. Overall \(String(format: "%.1f", report.overallBand))", tint: IMTheme.statusSuccess)
            }
            IMAdaptiveGrid(minimum: 140) {
                IMStatTile(label: "Listening", value: String(format: "%.1f", report.listeningBand ?? 0), detail: "\(report.listeningRaw ?? 0)/40")
                IMStatTile(label: "Reading", value: String(format: "%.1f", report.readingBand ?? 0), detail: "\(report.readingRaw ?? 0)/40")
                IMStatTile(label: "Writing", value: String(format: "%.1f", report.writingBand ?? 0), detail: "rubric estimate")
                IMStatTile(label: "Speaking", value: report.speakingBand.map { String(format: "%.1f", $0) } ?? "–", detail: report.speakingBand == nil ? "record in Speaking" : nil)
            }
            Text(report.speakingBand == nil
                 ? "Speaking can't be scored from typed notes, so the headline figure is the mean of Listening, Reading and Writing with official rounding. Every wrong answer is now in your Mistake Notebook and in your Skills Coach profile. All scores are estimates, not official IELTS results."
                 : "Overall band uses the official 4-module average and rounding. All scores are estimates, not official IELTS results.")
                .imText(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button("Open Skills Coach") { app.selectedSection = .coach }
                    .buttonStyle(.bordered)
                Button("Review mistakes") { app.selectedSection = .mistakeNotebook }
                    .buttonStyle(.bordered)
            }
        }
    }

    @ViewBuilder
    private func activeSimulatorView(exam: MockExam) -> some View {
        VStack(spacing: 0) {
            // Strict Exam Header Bar (No AI, No Arabic, Official Timer)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exam.title).imText(.title3)
                    Text("Strict Examination Mode — AI assistance, Arabic translation, and hints are disabled.")
                        .imText(.caption5)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                IMBadge(text: "\(activeStage.rawValue) • \(stageTimer.formattedRemaining)", tint: IMTheme.statusWarning)
                Button("Exit exam") {
                    stageTimer.stop()
                    app.audioService.stopSpeaking()
                    app.isExamFullScreenLocked = false
                    activeExam = nil
                }
                .buttonStyle(.bordered)
            }
            .padding(IMTheme.sp200)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: IMTheme.sp200) {
                    switch activeStage {
                    case .listening:
                        ForEach(exam.listeningParts) { part in
                            IMCard {
                                HStack {
                                    Text(part.title).imText(.title3)
                                    Spacer()
                                    Button("Play Part \(part.partNumber)") {
                                        app.audioService.speakDialogue(part.dialogue)
                                    }
                                    .buttonStyle(.bordered)
                                }
                                ForEach(part.questions) { q in
                                    HStack(alignment: .firstTextBaseline) {
                                        Text("Q\(q.number). \(q.prompt)").imText(.body6)
                                        Spacer()
                                        TextField("Answer", text: Binding(
                                            get: { listeningResponses[q.id] ?? "" },
                                            set: { listeningResponses[q.id] = $0 }
                                        ))
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 220)
                                    }
                                }
                            }
                        }
                        Button("Proceed to Academic Reading (60m)") {
                            app.audioService.stopSpeaking()
                            activeStage = .reading
                            stageTimer.reset(durationSeconds: 60 * 60)
                            stageTimer.start()
                        }
                        .buttonStyle(.borderedProminent)

                    case .reading:
                        ForEach(exam.readingPassages) { passage in
                            IMCard {
                                Text("Passage \(passage.passageNumber): \(passage.title)").imText(.title2)
                                Text(passage.fullText).imText(.body6)
                                Divider()
                                ForEach(passage.questions) { q in
                                    HStack(alignment: .firstTextBaseline) {
                                        Text("Q\(q.number). \(q.prompt)").imText(.body6)
                                        Spacer()
                                        TextField("Answer", text: Binding(
                                            get: { readingResponses[q.id] ?? "" },
                                            set: { readingResponses[q.id] = $0 }
                                        ))
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 220)
                                    }
                                }
                            }
                        }
                        Button("Proceed to Academic Writing (60m)") {
                            activeStage = .writing
                            stageTimer.reset(durationSeconds: 60 * 60)
                            stageTimer.start()
                        }
                        .buttonStyle(.borderedProminent)

                    case .writing:
                        IMCard {
                            Text(exam.writingTask1.title).imText(.title3)
                            Text(exam.writingTask1.instructions).imText(.body6)
                            TextEditor(text: $writingTask1Draft).frame(minHeight: 160).border(Color.secondary.opacity(0.2))
                            Text("\(IELTSScoringEngine.countWords(in: writingTask1Draft)) / 150+ words").imText(.caption4)
                        }
                        IMCard {
                            Text(exam.writingTask2.title).imText(.title3)
                            Text(exam.writingTask2.promptText).imText(.body6)
                            TextEditor(text: $writingTask2Draft).frame(minHeight: 220).border(Color.secondary.opacity(0.2))
                            Text("\(IELTSScoringEngine.countWords(in: writingTask2Draft)) / 250+ words").imText(.caption4)
                        }
                        Button("Proceed to Speaking (14m)") {
                            activeStage = .speaking
                            stageTimer.reset(durationSeconds: 14 * 60)
                            stageTimer.start()
                        }
                        .buttonStyle(.borderedProminent)

                    case .speaking:
                        IMCard {
                            Text("Speaking Part 1, 2 & 3 — \(exam.speakingSet.theme)").imText(.title2)
                            Text("Part 2 Cue Card: \(exam.speakingSet.part2CueCard.topic)").imText(.body2)
                            ForEach(exam.speakingSet.part2CueCard.bulletPoints, id: \.self) { b in
                                Text("• \(b)").imText(.body6)
                            }
                            TextEditor(text: $speakingNotes).frame(minHeight: 140).border(Color.secondary.opacity(0.2))
                        }
                        Button(isScoring ? "Scoring Writing…" : "Submit complete mock examination") {
                            Task { await finishFullMock(exam: exam) }
                        }
                        .disabled(isScoring)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(IMTheme.sp300)
            }
        }
    }

    private func pickAdaptiveExam() -> MockExam? {
        let band = app.profile.estimatedOverallBand
        let targetTier: DifficultyTier = band < 6.0 ? .foundation : (band < 7.0 ? .intermediate : (band < 8.0 ? .target : .advanced))
        return app.mockExams.first(where: { $0.difficulty == targetTier }) ?? app.mockExams.first
    }

    private func startFullMock(_ exam: MockExam) {
        activeExam = exam
        activeStage = .listening
        listeningResponses = [:]
        readingResponses = [:]
        writingTask1Draft = ""
        writingTask2Draft = ""
        speakingNotes = ""
        app.isExamFullScreenLocked = true
        stageTimer.reset(durationSeconds: 32 * 60)
        stageTimer.start()
    }

    private func finishFullMock(exam: MockExam) async {
        stageTimer.stop()
        isScoring = true
        defer { isScoring = false }

        let lGrade = IELTSScoringEngine.gradeObjectiveModule(questions: exam.listeningParts.flatMap(\.questions), responses: listeningResponses, isListening: true)
        let rGrade = IELTSScoringEngine.gradeObjectiveModule(questions: exam.readingPassages.flatMap(\.questions), responses: readingResponses, isListening: false)
        // Every exam in the bank has 40+40 questions (enforced by ContentValidator), so bands are present.
        let lBand = lGrade.bandScore ?? 0
        let rBand = rGrade.bandScore ?? 0

        // Writing: rubric evaluation (local LLM when connected, deterministic analyzer otherwise).
        // A blank task scores 0, as in the real test.
        func writingBand(task: Int, text: String, prompt: String) async -> Double {
            guard IELTSScoringEngine.countWords(in: text) > 0 else { return 0 }
            let result = await app.assessmentService.evaluateWriting(
                taskNumber: task,
                promptText: prompt,
                essayText: text,
                profile: app.profile,
                config: app.modelRouting,
                fallbackModel: app.primaryOllamaModel,
                includeArabic: false // no Arabic in examination mode
            )
            return result.overallTaskBand
        }
        let w1Band = await writingBand(task: 1, text: writingTask1Draft, prompt: exam.writingTask1.instructions)
        let w2Band = await writingBand(task: 2, text: writingTask2Draft, prompt: exam.writingTask2.promptText)
        let wOverall = IELTSScoringEngine.calculateWritingBand(task1Band: w1Band, task2Band: w2Band)

        // Speaking: typed notes are not speech, so no Speaking band is produced here.
        let spkBand: Double? = nil
        let threeModuleMean = IELTSScoringEngine.roundOfficialBand((lBand + rBand + wOverall) / 3.0)
        let overall = threeModuleMean
        app.isExamFullScreenLocked = false

        let record = ExamAttemptRecord(
            examID: exam.id,
            examTitle: exam.title,
            module: "Full Mock",
            sessionMode: .examination,
            durationSeconds: max(60, stageTimer.elapsedSeconds),
            listeningRaw: lGrade.rawScore,
            listeningBand: lBand,
            readingRaw: rGrade.rawScore,
            readingBand: rBand,
            writingBand: wOverall,
            speakingBand: spkBand,
            overallBand: overall,
            notes: "Full mock (computer-delivered format). Speaking not scored from typed notes; overall = mean of Listening, Reading, Writing."
        )
        app.recordExamAttempt(record)
        app.recordObjectiveResults(questions: exam.listeningParts.flatMap(\.questions), responses: listeningResponses, module: "Listening")
        app.recordObjectiveResults(questions: exam.readingPassages.flatMap(\.questions), responses: readingResponses, module: "Reading")
        app.markExamAttempted(exam.id)
        for unitID in exam.listeningParts.map(\.id) + exam.readingPassages.map(\.id) { app.markUnitSeen(unitID) }
        completedReport = record
        activeExam = nil
    }
}
