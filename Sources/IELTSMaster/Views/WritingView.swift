import SwiftUI
import Charts
import IELTSCore

public struct WritingView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedExamIndex: Int = 0
    @LocalState private var selectedTask: Int = 2 // 1 or 2
    @LocalState private var sessionMode: SessionMode = .learning
    @LocalState private var task1Text: String = ""
    @LocalState private var task2Text: String = ""
    @LocalState private var includeArabicFeedback: Bool = false
    @LocalState private var isEvaluating: Bool = false
    @LocalState private var evaluationResult: WritingEvaluationResult?
    @LocalState private var showModelSamples: Bool = false
    @StateObject private var timer = ExamTimerEngine(durationSeconds: 60 * 60, allowsPause: true)

    public init() {}

    private var currentTask1: WritingTask1Prompt {
        let tasks = SharedContentCatalog.bundled.writing1
        return tasks[min(selectedExamIndex, tasks.count - 1)]
    }

    private var currentTask2: WritingTask2Prompt {
        let tasks = SharedContentCatalog.bundled.writing2
        return tasks[min(selectedExamIndex, tasks.count - 1)]
    }

    private var promptTitles: [String] {
        selectedTask == 1 ? SharedContentCatalog.bundled.writing1.map(\.title)
                          : SharedContentCatalog.bundled.writing2.map(\.title)
    }

    private var activeText: Binding<String> {
        selectedTask == 1 ? $task1Text : $task2Text
    }

    private var activeWordCount: Int {
        IELTSScoringEngine.countWords(in: selectedTask == 1 ? task1Text : task2Text)
    }

    private var minTargetWords: Int {
        selectedTask == 1 ? 150 : 250
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Academic writing",
                    subtitle: "Timed practice workspace for Task 1 (visual data, 150+ words) and Task 2 (academic essay, 250+ words, 2x weighting), rubric-based evaluation, and Band 4–9 educational examples.",
                    badgeText: "Timer \(timer.formattedRemaining)"
                )

                // Top Controls
                IMCard {
                    IMFlow(spacing: IMTheme.sp100) {
                        Picker("Practice prompt", selection: $selectedExamIndex) {
                            ForEach(promptTitles.indices, id: \.self) { idx in
                                Text(promptTitles[idx]).tag(idx)
                            }
                        }
                        .disabled(isEvaluating)
                        .frame(maxWidth: 300)

                        Picker("Task", selection: $selectedTask) {
                            Text("Task 1 (150w)").tag(1)
                            Text("Task 2 (250w, 2x)").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .disabled(isEvaluating)
                        .onChange(of: selectedTask) { _, _ in
                            selectedExamIndex = 0
                            evaluationResult = nil
                        }
                        .frame(width: 250)

                        Picker("Mode", selection: $sessionMode) {
                            Text("Learning").tag(SessionMode.learning)
                            Text("Examination").tag(SessionMode.examination)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)

                        Spacer()

                        if timer.state == .idle {
                            Button("Start 60m") {
                                timer.reset(durationSeconds: 60 * 60)
                                timer.start()
                            }
                            .buttonStyle(.bordered)
                        }

                        Button(showModelSamples ? "Hide Band 4–9 samples" : "Band 4–9 samples") {
                            showModelSamples.toggle()
                        }
                        .buttonStyle(.bordered)
                        .disabled(sessionMode == .examination)
                    }
                }

                // Task Prompt & Visual Data Card
                IMCard {
                    if selectedTask == 1 {
                        HStack {
                            Text(currentTask1.title).imText(.title2)
                            Spacer()
                            IMBadge(text: currentTask1.visualType.rawValue)
                        }
                        Text(currentTask1.instructions).imText(.body6)

                        if !currentTask1.processSteps.isEmpty {
                            VStack(alignment: .leading, spacing: IMTheme.sp75) {
                                Text("Process stages").imText(.title4)
                                ForEach(currentTask1.processSteps, id: \.self) { step in
                                    Text(step).imText(.body6)
                                }
                            }
                            .padding(.top, IMTheme.sp50)
                        } else if !currentTask1.dataPoints.isEmpty {
                            Chart(currentTask1.dataPoints) { point in
                                if currentTask1.visualType == .lineChart {
                                    LineMark(x: .value("Year", point.category), y: .value("Value", point.value))
                                        .foregroundStyle(by: .value("Series", point.series))
                                    PointMark(x: .value("Year", point.category), y: .value("Value", point.value))
                                        .foregroundStyle(by: .value("Series", point.series))
                                } else {
                                    BarMark(x: .value("Year", point.category), y: .value("Value", point.value))
                                        .foregroundStyle(by: .value("Series", point.series))
                                        .position(by: .value("Series", point.series))
                                }
                            }
                            .frame(height: 220)
                            .padding(.top, IMTheme.sp75)
                        }
                    } else {
                        HStack {
                            Text(currentTask2.title).imText(.title2)
                            Spacer()
                            IMBadge(text: currentTask2.essayType.rawValue)
                        }
                        Text(currentTask2.promptText).imText(.body3)
                    }
                }

                // Writing Editor Card
                IMCard {
                    HStack {
                        Text("Your response").imText(.title3)
                        Spacer()
                        IMBadge(
                            text: "\(activeWordCount) / \(minTargetWords)+ words",
                            tint: activeWordCount >= minTargetWords ? IMTheme.statusSuccess : IMTheme.statusWarning
                        )
                    }

                    TextEditor(text: activeText)
                        .font(.system(size: 15))
                        .frame(minHeight: 280)
                        .padding(IMTheme.sp75)
                        .overlay(RoundedRectangle(cornerRadius: IMTheme.radiusInner).stroke(Color.primary.opacity(0.12), lineWidth: 1))

                    HStack {
                        if sessionMode.allowsArabicAssistance && app.profile.languageMode != .englishImmersion {
                            Toggle("Include Arabic summary", isOn: $includeArabicFeedback)
                        }
                        Spacer()
                        Button("Save draft") {
                            saveDraft()
                        }
                        .buttonStyle(.bordered)

                        Button(isEvaluating ? "Evaluating..." : "Evaluate with IELTS rubric") {
                            Task { await runEvaluation() }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(activeWordCount < 20 || isEvaluating || sessionMode == .examination)
                    }

                    if sessionMode == .examination {
                        Text("Examination Mode: AI evaluation and model samples are disabled while writing. Switch to Learning Mode or finish the exam to view rubric feedback.")
                            .imText(.caption5)
                            .foregroundStyle(.secondary)
                    }
                }

                // Rubric Evaluation Output
                if let result = evaluationResult {
                    IMCard {
                        HStack {
                            Text("Rubric assessment (Task \(result.taskNumber))").imText(.title2)
                            Spacer()
                            IMBadge(text: "Est. Band \(String(format: "%.1f", result.overallTaskBand))", tint: IMTheme.accentPrimary)
                            IMBadge(text: "Confidence: \(result.confidence.rawValue)")
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: IMTheme.sp100) {
                            criterionTile(result.taskNumber == 1 ? "Task Achievement" : "Task Response", result.taskAchievementBand)
                            criterionTile("Coherence & Cohesion", result.coherenceCohesionBand)
                            criterionTile("Lexical Resource", result.lexicalResourceBand)
                            criterionTile("Grammar Range & Acc.", result.grammaticalRangeBand)
                        }

                        Text(result.summaryFeedback).imText(.body6)
                        Text("Paragraph organization: \(result.paragraphAnalysis)").imText(.caption2).foregroundStyle(.secondary)
                        Text("Argument & task analysis: \(result.argumentAnalysis)").imText(.caption2).foregroundStyle(.secondary)

                        if !result.repeatedWords.isEmpty {
                            Text("Repeated words detected: \(result.repeatedWords.joined(separator: ", "))")
                                .imText(.caption4)
                                .foregroundStyle(IMTheme.statusWarning)
                        }

                        if !result.sentenceCorrections.isEmpty {
                            Divider()
                            Text("Detected grammar corrections").imText(.title4)
                            ForEach(result.sentenceCorrections) { corr in
                                VStack(alignment: .leading, spacing: 3) {
                                    IMBadge(text: corr.errorType, tint: IMTheme.statusWarning)
                                    Text("Original: \(corr.originalSentence)").imText(.caption2).foregroundStyle(.secondary)
                                    Text("Improved: \(corr.correctedSentence)").imText(.body5)
                                    Text(corr.explanation).imText(.caption5).foregroundStyle(.secondary)
                                }
                            }
                        }

                        if !result.targetedExercises.isEmpty {
                            Divider()
                            Text("Personalized follow-up exercises").imText(.title4)
                            ForEach(result.targetedExercises, id: \.self) { ex in
                                Text("• \(ex)").imText(.body6)
                            }
                        }

                        if let ar = result.arabicSummary, !ar.isEmpty {
                            IMArabicBlock(text: ar)
                        }

                        Text(result.disclaimer).imText(.caption5).foregroundStyle(.secondary)
                    }
                }

                // Band 4–9 Educational Samples
                if showModelSamples && sessionMode != .examination {
                    IMCard {
                        Text("Illustrative Band 4.0 to Band 9.0 educational examples").imText(.title2)
                        Text("Original educational examples created to illustrate public IELTS band descriptors. Not official IELTS scripts.")
                            .imText(.caption5)
                            .foregroundStyle(.secondary)
                        ForEach(WritingModelSamples.samples) { sample in
                            DisclosureGroup("Task \(sample.taskNumber) • Illustrative Band \(String(format: "%.1f", sample.estimatedBand))") {
                                VStack(alignment: .leading, spacing: IMTheme.sp75) {
                                    Text(sample.promptSummary).imText(.caption3).foregroundStyle(.secondary)
                                    Text(sample.essayText).imText(.body6).textSelection(.enabled)
                                    Text(sample.examinerNotes).imText(.caption2).foregroundStyle(IMTheme.accentPrimary)
                                    if app.profile.languageMode != .englishImmersion {
                                        IMArabicBlock(text: sample.arabicSummary)
                                    }
                                }
                                .padding(.top, IMTheme.sp75)
                            }
                            Divider()
                        }
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
        .onAppear {
            includeArabicFeedback = app.profile.shouldShowArabicByDefault
        }
    }

    private func criterionTile(_ title: String, _ score: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).imText(.caption5).foregroundStyle(.secondary)
            Text(String(format: "%.1f", score)).imText(.heading6).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(IMTheme.sp100)
        .background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: IMTheme.radiusInner, style: .continuous))
    }

    private func saveDraft() {
        let text = selectedTask == 1 ? task1Text : task2Text
        let promptID = selectedTask == 1 ? currentTask1.id : currentTask2.id
        let promptTitle = selectedTask == 1 ? currentTask1.title : currentTask2.title
        app.saveEssaySubmission(EssaySubmission(
            taskNumber: selectedTask,
            promptID: promptID,
            promptTitle: promptTitle,
            text: text,
            wordCount: IELTSScoringEngine.countWords(in: text),
            estimatedBand: evaluationResult?.overallTaskBand
        ))
        app.statusBanner = "Writing Task \(selectedTask) draft saved locally."
    }

    private func runEvaluation() async {
        isEvaluating = true
        defer { isEvaluating = false }
        let text = selectedTask == 1 ? task1Text : task2Text
        let promptText = selectedTask == 1 ? currentTask1.instructions : currentTask2.promptText
        let result = await app.assessmentService.evaluateWriting(
            taskNumber: selectedTask,
            promptText: promptText,
            essayText: text,
            profile: app.profile,
            config: app.modelRouting,
            fallbackModel: app.primaryOllamaModel,
            includeArabic: includeArabicFeedback && app.profile.languageMode != .englishImmersion
        )
        evaluationResult = result
        saveDraft()

        for corr in result.sentenceCorrections {
            app.logMistake(MistakeEntry(
                sourceModule: "Writing",
                originalPrompt: corr.originalSentence,
                learnerAnswer: corr.originalSentence,
                correctAnswer: corr.correctedSentence,
                explanation: corr.explanation,
                arabicExplanation: corr.arabicExplanation,
                errorCategory: corr.errorType,
                relatedGrammarRule: corr.errorType
            ))
        }

        app.recordExamAttempt(ExamAttemptRecord(
            examID: selectedTask == 1 ? currentTask1.id : currentTask2.id,
            examTitle: selectedTask == 1 ? currentTask1.title : currentTask2.title,
            module: ExamModule.writing.rawValue,
            sessionMode: sessionMode,
            durationSeconds: max(60, timer.elapsedSeconds),
            writingBand: result.overallTaskBand,
            overallBand: result.overallTaskBand,
            notes: "Task \(selectedTask) rubric evaluation."
        ))
    }
}
