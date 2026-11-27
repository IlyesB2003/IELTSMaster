import SwiftUI
import IELTSCore

public struct SpeakingView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedExamIndex: Int = 0
    @LocalState private var currentPart: Int = 1 // 1, 2, 3
    @LocalState private var sessionMode: SessionMode = .learning
    @LocalState private var transcriptInput: String = ""
    @LocalState private var lastRecordingURL: URL?
    @LocalState private var evaluation: SpeakingEvaluationResult?
    @StateObject private var part2PrepTimer = ExamTimerEngine(durationSeconds: 60, allowsPause: true)
    @StateObject private var part2SpeakTimer = ExamTimerEngine(durationSeconds: 120, allowsPause: true)

    public init() {}

    private var practiceSets: [SpeakingPromptSet] { SharedContentCatalog.bundled.speaking }

    private var speakingSet: SpeakingPromptSet {
        practiceSets[min(selectedExamIndex, practiceSets.count - 1)]
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Speaking examiner",
                    subtitle: "Interactive IELTS Speaking simulation covering Part 1 (familiar topics), Part 2 (1-min prep + 2-min cue card), and Part 3 (abstract discussion) with live audio recording and acoustic fluency analysis.",
                    badgeText: "Part \(currentPart) of 3"
                )

                IMCard {
                    IMFlow(spacing: IMTheme.sp100) {
                        Picker("Practice set", selection: $selectedExamIndex) {
                            ForEach(practiceSets.indices, id: \.self) { idx in
                                Text(practiceSets[idx].theme).tag(idx)
                            }
                        }
                        .frame(maxWidth: 320)

                        Picker("Part", selection: $currentPart) {
                            Text("Part 1 (4–5m)").tag(1)
                            Text("Part 2 (Cue Card)").tag(2)
                            Text("Part 3 (4–5m)").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 320)

                        Spacer()

                        Picker("Mode", selection: $sessionMode) {
                            Text("Learning").tag(SessionMode.learning)
                            Text("Exam").tag(SessionMode.examination)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 170)
                    }
                }

                // Examiner Prompt Card
                IMCard {
                    HStack {
                        Text("Examiner prompt — \(speakingSet.theme)").imText(.title2)
                        Spacer()
                        Button(app.audioService.isSpeakingTTS ? "Stop examiner voice" : "Play examiner prompt") {
                            if app.audioService.isSpeakingTTS {
                                app.audioService.stopSpeaking()
                            } else {
                                app.audioService.speak(text: activeExaminerScript(), accent: .british)
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    if currentPart == 1 {
                        ForEach(speakingSet.part1Questions, id: \.self) { q in
                            Text("• \(q)").imText(.body3)
                        }
                    } else if currentPart == 2 {
                        Text(speakingSet.part2CueCard.topic).imText(.title3)
                        Text("You should say:").imText(.caption3).foregroundStyle(.secondary)
                        ForEach(speakingSet.part2CueCard.bulletPoints, id: \.self) { bullet in
                            Text("• \(bullet)").imText(.body6)
                        }
                        HStack(spacing: IMTheme.sp100) {
                            Button("Start 1m prep (\(part2PrepTimer.formattedRemaining))") {
                                part2PrepTimer.reset(durationSeconds: 60)
                                part2PrepTimer.start()
                            }
                            .buttonStyle(.bordered)

                            Button("Start 2m talk (\(part2SpeakTimer.formattedRemaining))") {
                                part2SpeakTimer.reset(durationSeconds: 120)
                                part2SpeakTimer.start()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, IMTheme.sp50)
                    } else {
                        ForEach(speakingSet.part3Questions, id: \.self) { q in
                            Text("• \(q)").imText(.body3)
                        }
                    }
                }

                // Microphone Recorder & Waveform
                IMCard {
                    HStack {
                        Text("Microphone recording & transcription").imText(.title3)
                        Spacer()
                        Text(app.audioService.audioStatusMessage).imText(.caption5).foregroundStyle(.secondary)
                    }

                    // Live Waveform Bars
                    HStack(alignment: .center, spacing: 3) {
                        let bars = app.audioService.waveformSamples.isEmpty ? Array(repeating: Float(0.08), count: 40) : app.audioService.waveformSamples
                        ForEach(bars.indices, id: \.self) { idx in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(app.audioService.isRecording ? IMTheme.accentPrimary : Color.secondary.opacity(0.3))
                                .frame(width: 4, height: max(4, CGFloat(bars[idx]) * 42))
                        }
                    }
                    .frame(height: 48)

                    HStack(spacing: IMTheme.sp100) {
                        Button(app.audioService.isRecording ? "Stop recording" : "Start recording") {
                            toggleRecording()
                        }
                        .buttonStyle(.borderedProminent)

                        if let url = lastRecordingURL {
                            Button(app.audioService.isPlaying ? "Stop playback" : "Play my recording") {
                                if app.audioService.isPlaying { app.audioService.stopPlayback() }
                                else { app.audioService.playRecording(at: url) }
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Text("Transcript (auto-transcribed via Apple Speech when permitted, or editable for analysis):")
                        .imText(.caption4)
                        .foregroundStyle(.secondary)
                    TextEditor(text: $transcriptInput)
                        .font(.system(size: 14))
                        .frame(minHeight: 110)
                        .overlay(RoundedRectangle(cornerRadius: IMTheme.radiusInner).stroke(Color.primary.opacity(0.12), lineWidth: 1))

                    HStack {
                        Text("Examiner remains neutral during recording. Feedback appears only after you request post-exam evaluation.")
                            .imText(.caption5)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Evaluate speaking response") {
                            evaluateSpeaking()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(transcriptInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }

                // Post-Exam Speaking Report
                if let eval = evaluation {
                    IMCard {
                        HStack {
                            Text("Speaking assessment report").imText(.title2)
                            Spacer()
                            IMBadge(text: "Est. Band \(String(format: "%.1f", eval.overallSpeakingBand))", tint: IMTheme.accentPrimary)
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: IMTheme.sp100) {
                            metricBox("Fluency & Coherence", String(format: "%.1f", eval.fluencyCoherenceBand))
                            metricBox("Lexical Resource", String(format: "%.1f", eval.lexicalResourceBand))
                            metricBox("Grammar Range & Acc.", String(format: "%.1f", eval.grammaticalRangeBand))
                            metricBox("Pronunciation", eval.pronunciationBand.map { String(format: "%.1f", $0) } ?? "Audio review req.")
                        }

                        HStack(spacing: IMTheme.sp200) {
                            IMBadge(text: "Speech rate: \(Int(eval.acousticMetrics.wordsPerMinute)) WPM")
                            IMBadge(text: "Pause ratio: \(Int(eval.acousticMetrics.pauseRatio * 100))%")
                            IMBadge(text: "Fillers: \(eval.acousticMetrics.fillerWordCount)")
                            IMBadge(text: "Lexical variety: \(Int(eval.acousticMetrics.uniqueWordRatio * 100))%")
                        }

                        Text(eval.pronunciationLimitationNote)
                            .imText(.caption2)
                            .foregroundStyle(.secondary)

                        if !eval.strengths.isEmpty {
                            Text("Strengths").imText(.title4)
                            ForEach(eval.strengths, id: \.self) { s in Text("• \(s)").imText(.body6) }
                        }
                        if !eval.improvements.isEmpty {
                            Text("Priority improvements").imText(.title4)
                            ForEach(eval.improvements, id: \.self) { s in Text("• \(s)").imText(.body6) }
                        }
                        Text(eval.disclaimer).imText(.caption5).foregroundStyle(.secondary)
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
    }

    private func metricBox(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).imText(.caption5).foregroundStyle(.secondary)
            Text(value).imText(.title2).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(IMTheme.sp100)
        .background(Color.primary.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: IMTheme.radiusInner, style: .continuous))
    }

    private func activeExaminerScript() -> String {
        switch currentPart {
        case 1: return "Welcome to Part 1 of the IELTS Speaking test. " + speakingSet.part1Questions.joined(separator: " ")
        case 2: return "Now for Part 2. I am going to give you a topic and I would like you to talk about it for one to two minutes. " + speakingSet.part2CueCard.topic
        default: return "Now let us move to Part 3 and discuss broader ideas. " + speakingSet.part3Questions.joined(separator: " ")
        }
    }

    private func toggleRecording() {
        if app.audioService.isRecording {
            let result = app.audioService.stopRecording()
            lastRecordingURL = result.url
            if let url = result.url {
                Task {
                    let recognized = await app.audioService.transcribeAudioFile(at: url)
                    if !recognized.isEmpty {
                        await MainActor.run { transcriptInput = recognized }
                    }
                }
            }
        } else {
            _ = app.audioService.startRecording(prefix: "speaking_part\(currentPart)")
        }
    }

    private func evaluateSpeaking() {
        let dur = max(app.audioService.lastRecordingDuration, Double(max(15, IELTSScoringEngine.countWords(in: transcriptInput) / 2)))
        let result = app.assessmentService.evaluateSpeaking(
            transcript: transcriptInput,
            durationSeconds: dur,
            pauseRatio: app.audioService.lastPauseRatio,
            audioQualityOK: lastRecordingURL != nil
        )
        evaluation = result

        if let url = lastRecordingURL {
            app.saveAudioRecording(AudioRecordingRecord(
                context: "Speaking Part \(currentPart) — \(speakingSet.theme)",
                filePath: url.path,
                durationSeconds: dur,
                transcript: transcriptInput,
                estimatedWPM: result.acousticMetrics.wordsPerMinute,
                pauseRatio: result.acousticMetrics.pauseRatio
            ))
        }

        app.recordExamAttempt(ExamAttemptRecord(
            examID: speakingSet.id,
            examTitle: speakingSet.theme,
            module: ExamModule.speaking.rawValue,
            sessionMode: sessionMode,
            durationSeconds: Int(dur),
            speakingBand: result.overallSpeakingBand,
            overallBand: result.overallSpeakingBand,
            notes: "Speaking Part \(currentPart) acoustic & transcript evaluation."
        ))
    }
}
