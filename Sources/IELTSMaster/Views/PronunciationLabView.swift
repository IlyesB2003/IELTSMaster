import SwiftUI
import IELTSCore

public struct PronunciationLabView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.colorScheme) private var colorScheme
    @LocalState private var selectedMode: Mode = .minimalPairs
    @LocalState private var selectedAccent: EnglishAccent = .british
    @LocalState private var dictationIndex: Int = 0
    @LocalState private var dictationInput: String = ""
    @LocalState private var dictationResult: DictationResult? = nil
    @LocalState private var lastRecordingURL: URL? = nil

    public init() {}

    enum Mode: String, CaseIterable, Identifiable {
        case minimalPairs = "Minimal pairs"
        case stress = "Word & sentence stress"
        case shadowing = "Shadowing"
        case dictation = "Dictation"
        var id: String { rawValue }
    }

    struct DictationResult {
        let correctWords: Int
        let totalWords: Int
        let missed: [String]
    }

    private let minimalPairs: [(String, String, String, String)] = [
        ("/p/ vs /b/", "pack / back • simple / symbol • rapid / rabid", "Release a clear puff of air (aspiration) on initial /p/.", "تدرّب على إخراج دفعة هواء واضحة مع صوت /p/ للتمييز بينه وبين /b/."),
        ("/f/ vs /v/", "ferry / very • leaf / leave • safe / save", "Keep your vocal cords vibrating on /v/, top teeth lightly on the lower lip.", "حافظ على اهتزاز الأحبال الصوتية عند نطق /v/ مع وضع الأسنان العليا على الشفة السفلى."),
        ("/ɪ/ vs /iː/", "ship / sheep • live / leave • fill / feel", "Short relaxed /ɪ/ versus long tense /iː/.", "فرّق بين الصوت القصير في ship والصوت الطويل في sheep."),
        ("/θ/ vs /s/ and /t/", "think / sink • three / tree • thought / taught", "Put the tongue tip lightly between the teeth for /θ/.", "ضع طرف اللسان بخفة بين الأسنان لنطق /θ/ في think."),
        ("Consonant clusters", "statistics • strengths • agricultural • products", "Don't add a vowel before initial 'st-' or 'pr-'.", "تجنّب إضافة حركة قبل الحروف الساكنة المتتالية في بداية الكلمة.")
    ]

    private let stressDrills: [(String, String)] = [
        ("ANalyse → aNALysis → anaLYTical", "Primary stress moves across academic word families."),
        ("ECOnomy → ecoNOMic → eCONomist", "Keep unstressed syllables weak, with a schwa /ə/."),
        ("PHOtograph → phoTOgraphy → photoGRAPHic", "Learn stress with the word, not separately."),
        ("The DATA clearly SHOWS a RISE in EFFiciency.", "Stress content words; reduce 'the', 'a', 'in' to weak forms.")
    ]

    private let sentences = [
        "Although installation costs remain substantial, precision irrigation has improved both crop resilience and water efficiency.",
        "The survey suggests that most participants would prefer flexible working hours to a higher salary.",
        "Researchers measured the effect of the new feed on milk yield over a twelve-week period.",
        "In my view, public transport should be free for students and people over sixty-five."
    ]

    public var body: some View {
        IMPage {
            IMPageHeader(
                title: "Pronunciation Lab",
                subtitle: "Train intelligibility: sounds, stress, rhythm and connected speech, with model audio in five accents and your own recordings to compare. A non-native accent is never treated as an error."
            )

            IMCard {
                Picker("Exercise", selection: $selectedMode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                IMFlow {
                    Text("Model voice").imText(.caption1).foregroundStyle(.secondary)
                    Picker("Accent", selection: $selectedAccent) {
                        ForEach(EnglishAccent.allCases) { Text($0.displayName).tag($0) }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
            }

            switch selectedMode {
            case .minimalPairs: minimalPairsSection
            case .stress: stressSection
            case .shadowing: shadowingSection
            case .dictation: dictationSection
            }

            recorderCard
            historyCard
        }
    }

    // MARK: Sections

    private var minimalPairsSection: some View {
        VStack(spacing: IMTheme.sp200) {
            ForEach(minimalPairs, id: \.0) { pair in
                IMCard {
                    HStack(alignment: .firstTextBaseline, spacing: IMTheme.sp100) {
                        IMBadge(text: pair.0, tint: IMTheme.accentSpeaking)
                        Text(pair.1).imText(.title2).fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: IMTheme.sp75)
                        listenButton(pair.1.replacingOccurrences(of: "•", with: ",").replacingOccurrences(of: "/", with: ","), rate: 0.42)
                    }
                    Text(pair.2).imText(.body6).foregroundStyle(.secondary)
                    if app.profile.languageMode != .englishImmersion {
                        IMArabicBlock(text: pair.3)
                    }
                }
            }
        }
    }

    private var stressSection: some View {
        VStack(spacing: IMTheme.sp200) {
            ForEach(stressDrills, id: \.0) { drill in
                IMCard {
                    HStack(alignment: .center, spacing: IMTheme.sp100) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(drill.0).imText(.title2).fixedSize(horizontal: false, vertical: true)
                            Text(drill.1).imText(.body6).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: IMTheme.sp75)
                        listenButton(drill.0.replacingOccurrences(of: "→", with: ",").lowercased(), rate: 0.44)
                    }
                }
            }
        }
    }

    private var shadowingSection: some View {
        IMCard(padding: IMTheme.sp300) {
            Text("Listen, then speak along with the model").imText(.title1)
            Text("Copy the rhythm: stressed words long and clear, small words short and linked.")
                .imText(.body6)
                .foregroundStyle(.secondary)
            ForEach(sentences, id: \.self) { sentence in
                HStack(alignment: .center, spacing: IMTheme.sp100) {
                    Text(sentence)
                        .imText(.body3)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: IMTheme.sp75)
                    listenButton(sentence, rate: 0.47)
                    Button("Slow") { app.audioService.speak(text: sentence, accent: selectedAccent, rate: 0.36) }
                        .buttonStyle(.bordered)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var dictationSection: some View {
        let target = sentences[dictationIndex % sentences.count]
        return IMCard(padding: IMTheme.sp300) {
            HStack {
                Text("Dictation \(dictationIndex % sentences.count + 1) of \(sentences.count)").imText(.title1)
                Spacer()
                Button {
                    app.audioService.speak(text: target, accent: selectedAccent, rate: 0.46)
                } label: {
                    Label("Play", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                Button("Slow") { app.audioService.speak(text: target, accent: selectedAccent, rate: 0.36) }
                    .buttonStyle(.bordered)
            }
            Text("Type exactly what you hear, then check. Spelling counts, as it does in the Listening test.")
                .imText(.body6)
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $dictationInput)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .padding(6)
                if dictationInput.isEmpty {
                    Text("Type the sentence…")
                        .font(.system(size: 14))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 80)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IMTheme.elevatedBackground(colorScheme)))

            HStack(spacing: IMTheme.sp100) {
                Button("Check") { dictationResult = grade(target: target, input: dictationInput) }
                    .buttonStyle(.borderedProminent)
                    .disabled(dictationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Next sentence") {
                    dictationIndex += 1
                    dictationInput = ""
                    dictationResult = nil
                }
                .buttonStyle(.bordered)
            }

            if let r = dictationResult {
                VStack(alignment: .leading, spacing: 6) {
                    IMSkillBar(title: "Words in the right place", value: Double(r.correctWords) / Double(max(1, r.totalWords)),
                               tint: IMTheme.accuracyColor(Double(r.correctWords) / Double(max(1, r.totalWords))),
                               trailingText: "\(r.correctWords)/\(r.totalWords)")
                    if !r.missed.isEmpty {
                        Text("Missed or misspelled: \(r.missed.joined(separator: ", "))")
                            .imText(.caption2)
                            .foregroundStyle(IMTheme.statusWarning)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(target).imText(.body5).textSelection(.enabled)
                }
                .padding(.top, 4)
            }
        }
    }

    /// Order-aware word comparison (longest common subsequence), so missing or swapped words are caught.
    private func grade(target: String, input: String) -> DictationResult {
        func words(_ s: String) -> [String] {
            s.lowercased().components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-'")).inverted).filter { !$0.isEmpty }
        }
        let t = words(target), u = words(input)
        var dp = Array(repeating: Array(repeating: 0, count: u.count + 1), count: t.count + 1)
        for i in stride(from: t.count - 1, through: 0, by: -1) {
            for j in stride(from: u.count - 1, through: 0, by: -1) {
                dp[i][j] = t[i] == u[j] ? dp[i + 1][j + 1] + 1 : max(dp[i + 1][j], dp[i][j + 1])
            }
        }
        var i = 0, j = 0
        var missed: [String] = []
        while i < t.count && j < u.count {
            if t[i] == u[j] { i += 1; j += 1 }
            else if dp[i + 1][j] >= dp[i][j + 1] { missed.append(t[i]); i += 1 }
            else { j += 1 }
        }
        missed.append(contentsOf: t[i...])
        return DictationResult(correctWords: dp[0][0], totalWords: t.count, missed: missed)
    }

    private func listenButton(_ text: String, rate: Float) -> some View {
        Button {
            app.audioService.speak(text: text, accent: selectedAccent, rate: rate)
        } label: {
            Label("Listen", systemImage: "speaker.wave.2.fill")
        }
        .buttonStyle(.bordered)
    }

    // MARK: Recorder

    private var recorderCard: some View {
        IMCard(padding: IMTheme.sp300) {
            HStack {
                Text("Record and compare").imText(.title1)
                Spacer()
                Text(app.audioService.audioStatusMessage).imText(.caption2).foregroundStyle(.secondary).lineLimit(1)
            }
            let bars = app.audioService.waveformSamples.isEmpty ? Array(repeating: Float(0.08), count: 48) : app.audioService.waveformSamples
            HStack(alignment: .center, spacing: 3) {
                ForEach(Array(bars.enumerated()), id: \.offset) { _, v in
                    Capsule()
                        .fill(app.audioService.isRecording ? IMTheme.accentSpeaking : Color.secondary.opacity(0.3))
                        .frame(width: 4, height: max(4, CGFloat(v) * 44))
                }
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()

            IMFlow {
                Button {
                    toggleRecording()
                } label: {
                    Label(app.audioService.isRecording ? "Stop recording" : "Record yourself",
                          systemImage: app.audioService.isRecording ? "stop.circle.fill" : "record.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(app.audioService.isRecording ? IMTheme.statusDanger : IMTheme.accentSpeaking)

                if let url = lastRecordingURL {
                    Button(app.audioService.isPlaying ? "Stop" : "Play my recording") {
                        if app.audioService.isPlaying { app.audioService.stopPlayback() }
                        else { app.audioService.playRecording(at: url) }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private func toggleRecording() {
        if app.audioService.isRecording {
            let res = app.audioService.stopRecording()
            lastRecordingURL = res.url
            if let url = res.url {
                app.saveAudioRecording(AudioRecordingRecord(
                    context: "Pronunciation Lab — \(selectedMode.rawValue)",
                    filePath: url.path,
                    durationSeconds: res.duration,
                    transcript: "",
                    estimatedWPM: 0,
                    pauseRatio: res.pauseRatio
                ))
            }
        } else {
            _ = app.audioService.startRecording(prefix: "pronunciation")
        }
    }

    @ViewBuilder
    private var historyCard: some View {
        if !app.recordings.isEmpty {
            IMCard {
                Text("Recent recordings").imText(.title2)
                ForEach(app.recordings.prefix(6)) { rec in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rec.context).imText(.body5).lineLimit(1)
                            Text("\(rec.createdAt.formatted(date: .abbreviated, time: .shortened)) · \(String(format: "%.1f s", rec.durationSeconds))")
                                .imText(.caption5)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Play") {
                            app.audioService.playRecording(at: URL(fileURLWithPath: rec.filePath))
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}
