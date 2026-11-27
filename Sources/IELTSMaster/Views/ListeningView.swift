import SwiftUI
import IELTSCore

public struct ListeningView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedExamIndex: Int = 0
    @LocalState private var selectedPartIndex: Int = 0
    @LocalState private var sessionMode: SessionMode = .learning
    @LocalState private var responses: [String: String] = [:]
    @LocalState private var playedPartIDs: Set<String> = []
    @LocalState private var submitted: Bool = false
    @LocalState private var showTranscript: Bool = false
    @LocalState private var showArabicNotes: Bool = false
    @LocalState private var lastResult: (raw: Int, total: Int, band: Double?, wrongCount: Int)?
    @StateObject private var timer = ExamTimerEngine(durationSeconds: 32 * 60, allowsPause: true)

    public init() {}

    private var currentExam: MockExam {
        app.mockExams[min(selectedExamIndex, max(0, app.mockExams.count - 1))]
    }

    private var currentPart: ListeningPart {
        currentExam.listeningParts[min(selectedPartIndex, max(0, currentExam.listeningParts.count - 1))]
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Listening module",
                    subtitle: "Four official parts, 40 questions, multi-accent audio synthesis (British, Australian, Irish, American, Canadian), replay restrictions in Examination Mode, and post-test transcripts.",
                    badgeText: "Timer \(timer.formattedRemaining)"
                )

                // Control Bar
                IMCard {
                    IMFlow(spacing: IMTheme.sp100) {
                        Picker("Mock exam", selection: $selectedExamIndex) {
                            ForEach(app.mockExams.indices, id: \.self) { idx in
                                Text(app.mockExams[idx].title).tag(idx)
                            }
                        }
                        .frame(maxWidth: 320)

                        Picker("Mode", selection: $sessionMode) {
                            Text("Learning Mode").tag(SessionMode.learning)
                            Text("Examination Mode").tag(SessionMode.examination)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 260)

                        Spacer()

                        if timer.state == .idle {
                            Button("Start timer") {
                                timer.reset(durationSeconds: 32 * 60)
                                timer.start()
                            }
                            .buttonStyle(.bordered)
                        } else if timer.state == .running && sessionMode.allowsAudioReplay {
                            Button("Pause") { timer.pause() }.buttonStyle(.bordered)
                        }

                        if sessionMode.allowsArabicAssistance && app.profile.languageMode != .englishImmersion {
                            Toggle("Arabic notes", isOn: $showArabicNotes)
                        }
                    }

                    // Part Selector
                    Picker("Listening Part", selection: $selectedPartIndex) {
                        ForEach(currentExam.listeningParts.indices, id: \.self) { idx in
                            Text("Part \(idx + 1) (\(currentExam.listeningParts[idx].primaryAccent.displayName))").tag(idx)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Audio Player Card
                IMCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentPart.title).imText(.title2)
                            Text("\(currentPart.contextDescription) • Accent: \(currentPart.primaryAccent.displayName)")
                                .imText(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()

                        let alreadyPlayedInExam = sessionMode == .examination && playedPartIDs.contains(currentPart.id)
                        Button(app.audioService.isSpeakingTTS ? "Stop audio" : "Play recording") {
                            if app.audioService.isSpeakingTTS {
                                app.audioService.stopSpeaking()
                            } else {
                                playedPartIDs.insert(currentPart.id)
                                app.audioService.speakDialogue(currentPart.dialogue)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(alreadyPlayedInExam && !app.audioService.isSpeakingTTS)

                        if submitted || sessionMode == .learning {
                            Button(showTranscript ? "Hide transcript" : "Show transcript") {
                                showTranscript.toggle()
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    if sessionMode == .examination {
                        Text("Examination Mode active: each audio part plays once only. Transcripts, AI hints, and Arabic assistance are locked until submission.")
                            .imText(.caption5)
                            .foregroundStyle(.secondary)
                    }

                    if showTranscript && (submitted || sessionMode == .learning) {
                        Divider()
                        VStack(alignment: .leading, spacing: IMTheme.sp75) {
                            Text("Audio transcript").imText(.title4)
                            Text(currentPart.fullTranscript)
                                .imText(.body6)
                                .textSelection(.enabled)
                            if !currentPart.keyVocabulary.isEmpty {
                                HStack(spacing: IMTheme.sp75) {
                                    Text("Key vocabulary:").imText(.caption3).foregroundStyle(.secondary)
                                    ForEach(currentPart.keyVocabulary, id: \.self) { word in
                                        IMBadge(text: word)
                                    }
                                }
                            }
                        }
                    }
                }

                // Questions for Current Part
                ForEach(currentPart.questions) { q in
                    IMCard {
                        HStack {
                            Text("Question \(q.number)").imText(.title4)
                            IMBadge(text: q.format.rawValue)
                            if let maxW = q.maxWordCount {
                                IMBadge(text: "Max \(maxW) word\(maxW == 1 ? "" : "s")")
                            }
                            Spacer()
                            if submitted {
                                let ok = IELTSScoringEngine.isCorrect(response: responses[q.id] ?? "", for: q)
                                IMBadge(text: ok ? "Correct" : "Incorrect", tint: ok ? IMTheme.statusSuccess : IMTheme.statusDanger)
                            }
                        }

                        Text(q.prompt).imText(.body2)

                        if !q.options.isEmpty {
                            VStack(alignment: .leading, spacing: IMTheme.sp50) {
                                ForEach(q.options, id: \.self) { opt in
                                    Button {
                                        if !submitted { responses[q.id] = opt }
                                    } label: {
                                        HStack {
                                            Image(systemName: responses[q.id] == opt ? "largecircle.fill.circle" : "circle")
                                            Text(opt).imText(.body6)
                                            Spacer()
                                        }
                                        .padding(6)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else {
                            TextField("Type your answer...", text: Binding(
                                get: { responses[q.id] ?? "" },
                                set: { responses[q.id] = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .disabled(submitted)
                        }

                        if submitted {
                            Divider()
                            Text("Accepted answer: \(q.acceptedAnswers.first ?? "")").imText(.body4)
                            Text(q.explanation).imText(.body6).foregroundStyle(.secondary)
                            if let distractor = q.distractorNote {
                                Text("Distractor alert: \(distractor)").imText(.caption4).foregroundStyle(IMTheme.statusWarning)
                            }
                            if showArabicNotes, let ar = q.arabicExplanation, sessionMode.allowsArabicAssistance, app.profile.languageMode != .englishImmersion {
                                IMArabicBlock(text: ar)
                            }
                        }
                    }
                }

                // Submit / Results Bar
                IMCard {
                    HStack {
                        if let res = lastResult {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(res.band.map { "Listening Score: \(res.raw) / \(res.total) • Estimated Band \(String(format: "%.1f", $0))" } ?? "Listening Score: \(res.raw) / \(res.total) (band shown for full 40-question tests only)")
                                    .imText(.title2)
                                Text("Incorrect answers have been logged to your Mistake Notebook. This is an estimate, not an official IELTS score.")
                                    .imText(.caption5)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Reset test") {
                                responses = [:]
                                playedPartIDs = []
                                submitted = false
                                lastResult = nil
                                showTranscript = false
                            }
                            .buttonStyle(.bordered)
                        } else {
                            Text("Answered \(responses.values.filter { !$0.isEmpty }.count) of 40 questions across all 4 parts.")
                                .imText(.body6)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Submit Listening test") {
                                submitListening()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
    }

    private func submitListening() {
        app.audioService.stopSpeaking()
        timer.stop()
        let allQ = currentExam.listeningParts.flatMap(\.questions)
        let graded = IELTSScoringEngine.gradeObjectiveModule(questions: allQ, responses: responses, isListening: true)
        lastResult = (graded.rawScore, graded.totalQuestions, graded.bandScore, graded.incorrectQuestions.count)
        submitted = true
        // Feed the skill profile (mistakes are logged below) and remember these sets as seen.
        app.recordObjectiveResults(questions: allQ, responses: responses, module: "Listening", logMistakes: false)
        for unitID in currentExam.listeningParts.map(\.id) { app.markUnitSeen(unitID) }
        showTranscript = true

        for wrong in graded.incorrectQuestions.prefix(12) {
            app.logMistake(MistakeEntry(
                sourceModule: "Listening",
                originalPrompt: wrong.prompt,
                learnerAnswer: responses[wrong.id] ?? "(blank)",
                correctAnswer: wrong.acceptedAnswers.first ?? "",
                explanation: wrong.explanation,
                arabicExplanation: wrong.arabicExplanation,
                errorCategory: "Listening — \(wrong.format.rawValue)",
                relatedGrammarRule: wrong.skillTag
            ))
        }

        guard let band = graded.bandScore else { return }
        app.recordExamAttempt(ExamAttemptRecord(
            examID: currentExam.id,
            examTitle: currentExam.title,
            module: ExamModule.listening.rawValue,
            sessionMode: sessionMode,
            durationSeconds: max(1, timer.elapsedSeconds),
            listeningRaw: graded.rawScore,
            listeningBand: band,
            overallBand: band,
            notes: "Original IELTS-style Listening practice."
        ))
    }
}
