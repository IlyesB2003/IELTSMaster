import SwiftUI
import IELTSCore

public struct ReadingView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedExamIndex: Int = 0
    @LocalState private var selectedPassageIndex: Int = 0
    @LocalState private var sessionMode: SessionMode = .learning
    @LocalState private var responses: [String: String] = [:]
    @LocalState private var highlightedParagraphs: Set<String> = []
    @LocalState private var submitted: Bool = false
    @LocalState private var lastResult: (raw: Int, total: Int, band: Double?, wpm: Double)?
    @StateObject private var timer = ExamTimerEngine(durationSeconds: 60 * 60, allowsPause: true)

    public init() {}

    private var currentExam: MockExam {
        app.mockExams[min(selectedExamIndex, max(0, app.mockExams.count - 1))]
    }

    private var currentPassage: ReadingPassage {
        currentExam.readingPassages[min(selectedPassageIndex, max(0, currentExam.readingPassages.count - 1))]
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top Controls
            VStack(alignment: .leading, spacing: IMTheme.sp100) {
                HStack {
                    IMPageHeader(
                        title: "Academic reading",
                        subtitle: "Three academic passages, 40 questions across all official types, 60-minute timer, paragraph highlighting, and evidence-based review.",
                        badgeText: "Timer \(timer.formattedRemaining)"
                    )
                }
                IMFlow(spacing: IMTheme.sp100) {
                    Picker("Exam", selection: $selectedExamIndex) {
                        ForEach(app.mockExams.indices, id: \.self) { idx in
                            Text(app.mockExams[idx].title).tag(idx)
                        }
                    }
                    .frame(maxWidth: 320)

                    Picker("Passage", selection: $selectedPassageIndex) {
                        ForEach(currentExam.readingPassages.indices, id: \.self) { idx in
                            Text("Passage \(idx + 1)").tag(idx)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 260)

                    Picker("Mode", selection: $sessionMode) {
                        Text("Learning").tag(SessionMode.learning)
                        Text("Examination").tag(SessionMode.examination)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 210)

                    Spacer()

                    if timer.state == .idle {
                        Button("Start 60m timer") {
                            timer.reset(durationSeconds: 60 * 60)
                            timer.start()
                        }
                        .buttonStyle(.bordered)
                    }

                    if submitted {
                        Button("Reset") {
                            responses = [:]
                            submitted = false
                            lastResult = nil
                            timer.reset(durationSeconds: 60 * 60)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Submit Reading (40 Q)") {
                            submitReading()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding(IMTheme.sp200)

            Divider()

            if let res = lastResult {
                IMFlow {
                    IMBadge(text: "Raw \(res.raw) / \(res.total)", tint: IMTheme.accentPrimary)
                    if let band = res.band {
                        IMBadge(text: "Est. Band \(String(format: "%.1f", band))", tint: IMTheme.statusSuccess)
                    } else {
                        IMBadge(text: "Band shown for full 40-question tests only")
                    }
                    IMBadge(text: "Reading Speed ~\(Int(res.wpm)) WPM")
                    Spacer()
                    Text("Estimate only — not an official IELTS result. Incorrect answers logged to Mistake Notebook.")
                        .imText(.caption5)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, IMTheme.sp200)
                .padding(.vertical, IMTheme.sp75)
                Divider()
            }

            // Split-Pane Computer-Delivered IELTS Layout
            HSplitView {
                // Left Pane: Academic Passage with Click-to-Highlight
                ScrollView {
                    VStack(alignment: .leading, spacing: IMTheme.sp200) {
                        HStack {
                            Text(currentPassage.title).imText(.heading6)
                            Spacer()
                            IMBadge(text: currentPassage.discipline)
                            IMBadge(text: "\(currentPassage.estimatedWordCount) words")
                        }
                        Text("Tip: Click any paragraph to toggle study highlighting.")
                            .imText(.caption5)
                            .foregroundStyle(.secondary)

                        ForEach(currentPassage.paragraphs.indices, id: \.self) { idx in
                            let key = "\(currentPassage.id)-p-\(idx)"
                            let label = String(UnicodeScalar(65 + idx)!)
                            let isHighlighted = highlightedParagraphs.contains(key)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Paragraph \(label)").imText(.caption3).foregroundStyle(.secondary)
                                Text(currentPassage.paragraphs[idx])
                                    .imText(.body3)
                                    .textSelection(.enabled)
                            }
                            .padding(IMTheme.sp100)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isHighlighted ? Color.yellow.opacity(0.18) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: IMTheme.radiusInner, style: .continuous))
                            .onTapGesture {
                                if isHighlighted { highlightedParagraphs.remove(key) }
                                else { highlightedParagraphs.insert(key) }
                            }
                        }
                    }
                    .padding(IMTheme.sp300)
                }
                .frame(minWidth: 300)

                // Right Pane: Questions & Evidence Review
                ScrollView {
                    VStack(alignment: .leading, spacing: IMTheme.sp200) {
                        ForEach(currentPassage.questions) { q in
                            IMCard {
                                HStack {
                                    Text("Q\(q.number)").imText(.title4)
                                    IMBadge(text: q.format.rawValue)
                                    Spacer()
                                    if submitted {
                                        let ok = IELTSScoringEngine.isCorrect(response: responses[q.id] ?? "", for: q)
                                        IMBadge(text: ok ? "Correct" : "Incorrect", tint: ok ? IMTheme.statusSuccess : IMTheme.statusDanger)
                                    }
                                }
                                Text(q.prompt).imText(.body5)

                                if !q.options.isEmpty {
                                    ForEach(q.options, id: \.self) { opt in
                                        Button {
                                            if !submitted { responses[q.id] = opt }
                                        } label: {
                                            HStack {
                                                Image(systemName: responses[q.id] == opt ? "largecircle.fill.circle" : "circle")
                                                Text(opt).imText(.body6)
                                                Spacer()
                                            }
                                            .padding(4)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } else {
                                    TextField("Enter answer...", text: Binding(
                                        get: { responses[q.id] ?? "" },
                                        set: { responses[q.id] = $0 }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .disabled(submitted)
                                }

                                if submitted {
                                    Divider()
                                    Text("Answer: \(q.acceptedAnswers.first ?? "")").imText(.body4)
                                    Text(q.explanation).imText(.caption2).foregroundStyle(.secondary)
                                    Text("Passage evidence: \"\(q.evidenceQuote)\"").imText(.caption4).foregroundStyle(IMTheme.accentPrimary)
                                    if let d = q.distractorNote {
                                        Text("Distractor: \(d)").imText(.caption4).foregroundStyle(IMTheme.statusWarning)
                                    }
                                }
                            }
                        }
                    }
                    .padding(IMTheme.sp300)
                }
                .frame(minWidth: 300)
            }
        }
    }

    private func submitReading() {
        timer.stop()
        let allQ = currentExam.readingPassages.flatMap(\.questions)
        let totalWords = currentExam.readingPassages.reduce(0) { $0 + $1.estimatedWordCount }
        let elapsed = max(60, timer.elapsedSeconds)
        let wpm = IELTSScoringEngine.calculateReadingWPM(wordCount: totalWords, elapsedSeconds: elapsed)
        let graded = IELTSScoringEngine.gradeObjectiveModule(questions: allQ, responses: responses, isListening: false)

        lastResult = (graded.rawScore, graded.totalQuestions, graded.bandScore, wpm)
        submitted = true
        // Feed the skill profile (mistakes are logged below) and remember these sets as seen.
        app.recordObjectiveResults(questions: allQ, responses: responses, module: "Reading", logMistakes: false)
        for unitID in currentExam.readingPassages.map(\.id) { app.markUnitSeen(unitID) }

        for wrong in graded.incorrectQuestions.prefix(12) {
            app.logMistake(MistakeEntry(
                sourceModule: "Reading",
                originalPrompt: wrong.prompt,
                learnerAnswer: responses[wrong.id] ?? "(blank)",
                correctAnswer: wrong.acceptedAnswers.first ?? "",
                explanation: wrong.explanation,
                errorCategory: "Reading — \(wrong.format.rawValue)",
                relatedGrammarRule: wrong.skillTag
            ))
        }

        // Only a complete 40-question test produces a band; partial sets are not recorded as band attempts.
        guard let band = graded.bandScore else { return }
        app.recordExamAttempt(ExamAttemptRecord(
            examID: currentExam.id,
            examTitle: currentExam.title,
            module: ExamModule.reading.rawValue,
            sessionMode: sessionMode,
            durationSeconds: elapsed,
            readingRaw: graded.rawScore,
            readingBand: band,
            overallBand: band,
            readingWPM: wpm,
            notes: "Original Academic Reading practice."
        ))
    }
}
