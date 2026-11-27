import SwiftUI
import IELTSCore

// MARK: - Hub

/// Smart Practice: never-repeating practice sets chosen from material the learner hasn't seen.
public struct PracticeHubView: View {
    @EnvironmentObject private var app: AppState

    public init() {}

    public var body: some View {
        if let unit = app.activePractice {
            PracticeSessionView(unit: unit, isRepeat: app.activePracticeIsRepeat)
                .id(unit.id)
        } else {
            hub
        }
    }

    private var hub: some View {
        IMPage {
            IMPageHeader(
                title: "Smart Practice",
                subtitle: "Each set is picked from material you haven't done yet, starting with the skills you get wrong most. Nothing repeats until you've seen everything. Then the set you did longest ago comes back, and your AI model can write brand-new passages."
            )

            IMAdaptiveGrid(minimum: 300) {
                kindCard(
                    kind: .reading, title: "Reading", symbol: "book.pages", tint: IMTheme.accentReading,
                    unseen: app.unseenReadingCount, total: app.readingUnits.count,
                    detail: "A focused reading session with 2–4 questions, scored with explanations and evidence. Sessions can study different skills using the same practice text."
                )
                kindCard(
                    kind: .listening, title: "Listening", symbol: "headphones", tint: IMTheme.accentListening,
                    unseen: app.unseenListeningCount, total: app.listeningUnits.count,
                    detail: "A focused listening session with 2–4 questions. Replay is available; the transcript opens after submission. Full mock recordings stay in the exam bank."
                )
            }

            generateCard

            if !app.skillMastery.isEmpty {
                IMSectionTitle("Practise one skill")
                IMAdaptiveGrid(minimum: 230) {
                    ForEach(focusSkills, id: \.self) { tag in
                        IMActionTile(
                            symbol: "scope",
                            title: SkillCatalog.title(for: tag),
                            subtitle: accuracyLine(for: tag),
                            tint: IMTheme.accuracyColor(accuracy(for: tag) ?? 1)
                        ) {
                            let kind: PracticeUnit.Kind = app.listeningUnits.contains { $0.skillTags.contains(tag) } && !app.readingUnits.contains { $0.skillTags.contains(tag) } ? .listening : .reading
                            _ = app.startNextPractice(kind, focusSkill: tag)
                        }
                    }
                }
            }
        }
    }

    private var focusSkills: [String] {
        let weak = app.weakSkillTags
        let others = app.skillMastery.map(\.skillTag).filter { !weak.contains($0) }
        var seen = Set<String>()
        return (weak + others).filter { seen.insert($0).inserted }.prefix(9).map { $0 }
    }

    private func accuracy(for tag: String) -> Double? {
        let rows = app.skillMastery.filter { $0.skillTag == tag }
        guard !rows.isEmpty else { return nil }
        return rows.map(\.weightedAccuracy).reduce(0, +) / Double(rows.count)
    }

    private func accuracyLine(for tag: String) -> String {
        guard let a = accuracy(for: tag) else { return "Not practised yet" }
        return "\(Int((a * 100).rounded()))% right recently"
    }

    private func kindCard(kind: PracticeUnit.Kind, title: String, symbol: String, tint: Color, unseen: Int, total: Int, detail: String) -> some View {
        IMCard(padding: IMTheme.sp300) {
            HStack(spacing: IMTheme.sp100) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 40, height: 40)
                    .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(tint.opacity(0.13)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).imText(.heading6)
                    Text("\(unseen) new of \(total)").imText(.caption1).foregroundStyle(.secondary)
                }
            }
            Text(detail)
                .imText(.body6)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            IMProgressBar(value: total == 0 ? 0 : Double(total - unseen) / Double(total), tint: tint, height: 5)
            Button {
                _ = app.startNextPractice(kind)
            } label: {
                Label(unseen > 0 ? "Start a new set" : "Repeat the oldest set", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(total == 0)
        }
    }

    private var generateCard: some View {
        IMCard(padding: IMTheme.sp300) {
            HStack(alignment: .top, spacing: IMTheme.sp200) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(IMTheme.brandGradient))
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Brand-new Reading passage").imText(.title1)
                        IMBadge(text: "AI-generated", tint: IMTheme.brandTeal)
                    }
                    Text("Your AI model writes an original passage with 13 questions. Code then checks every answer against the passage and rejects anything that doesn't hold up. Uses \(app.primaryOllamaModel.isEmpty ? "no model yet: connect Ollama in AI Model Manager" : app.primaryOllamaModel).")
                        .imText(.body6)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let msg = app.generationMessage {
                        HStack(alignment: .top, spacing: 6) {
                            if app.isGeneratingPractice { ProgressView().controlSize(.small) }
                            Text(msg).imText(.caption2).foregroundStyle(app.isGeneratingPractice ? Color.secondary : IMTheme.statusWarning)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 2)
                    }
                    if !app.generatedPassages.isEmpty {
                        Text("\(app.generatedPassages.count) generated passage\(app.generatedPassages.count == 1 ? "" : "s") saved on this Mac.")
                            .imText(.caption5)
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer(minLength: 0)
                Button(app.isGeneratingPractice ? "Writing…" : "Generate") {
                    Task { await app.generateFreshReading(focusSkill: app.weakSkillTags.first) }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(app.isGeneratingPractice)
            }
        }
    }
}

// MARK: - Session

/// One practice set: passage or recording on one side, questions on the other.
/// Two columns on wide windows, one scrolling column on narrow ones.
struct PracticeSessionView: View {
    @EnvironmentObject private var app: AppState

    let unit: PracticeUnit
    let isRepeat: Bool

    @LocalState private var responses: [String: String] = [:]
    @LocalState private var submitted = false
    @LocalState private var startedAt = Date()
    @LocalState private var showArabic = false
    @LocalState private var showTranscript = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            GeometryReader { geo in
                if geo.size.width >= 900 {
                    HStack(spacing: 0) {
                        ScrollView { sourcePane.padding(IMTheme.sp300) }
                            .frame(width: geo.size.width * 0.52)
                        Divider()
                        ScrollView { questionPane.padding(IMTheme.sp300) }
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: IMTheme.sp300) {
                            sourcePane
                            Divider()
                            questionPane
                        }
                        .padding(IMTheme.sp200)
                    }
                }
            }
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(spacing: IMTheme.sp100) {
            Button {
                app.closePractice()
            } label: {
                Label("Practice", systemImage: "chevron.left")
            }
            .buttonStyle(.borderless)

            VStack(alignment: .leading, spacing: 1) {
                Text(unit.title).imText(.title2).lineLimit(1)
                HStack(spacing: 6) {
                    Text(unit.sourceTitle).imText(.caption5).foregroundStyle(.secondary).lineLimit(1)
                    if unit.origin == .aiGeneratedValidated { IMBadge(text: "AI-generated", tint: IMTheme.brandTeal) }
                    if isRepeat { IMBadge(text: "Seen before", tint: IMTheme.statusWarning) }
                }
            }
            Spacer(minLength: IMTheme.sp75)

            if app.profile.languageMode != .englishImmersion {
                Toggle("عربي", isOn: $showArabic)
                    .toggleStyle(.button)
                    .help("Show Arabic explanations after you submit")
            }

            if submitted {
                Button {
                    _ = app.startNextPractice(unit.kind)
                } label: {
                    Label("Next set", systemImage: "arrow.right")
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: .command)
            } else {
                Text("\(answeredCount)/\(unit.questions.count)")
                    .imText(.caption1)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Button("Submit", action: submit)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(.horizontal, IMTheme.sp200)
        .padding(.vertical, IMTheme.sp100)
        .background(.bar)
    }

    private var answeredCount: Int {
        unit.questions.filter { !(responses[$0.id] ?? "").trimmingCharacters(in: .whitespaces).isEmpty }.count
    }

    // MARK: Source pane

    @ViewBuilder
    private var sourcePane: some View {
        if let passage = unit.passage {
            VStack(alignment: .leading, spacing: IMTheme.sp200) {
                Text(passage.discipline.uppercased())
                    .font(.system(size: 10, weight: .bold)).tracking(0.8)
                    .foregroundStyle(IMTheme.accentReading)
                Text(passage.title).imText(.heading5)
                ForEach(Array(passage.paragraphs.enumerated()), id: \.offset) { idx, para in
                    HStack(alignment: .firstTextBaseline, spacing: IMTheme.sp100) {
                        Text(String(Character(UnicodeScalar(UInt8(65 + idx)))))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .frame(width: 16)
                        Text(highlighted(para))
                            .font(.system(size: 15))
                            .lineSpacing(5)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: 720, alignment: .leading)
        } else if let part = unit.part {
            listeningPane(part)
        }
    }

    /// Highlights the evidence for wrong answers once the set is submitted.
    private func highlighted(_ text: String) -> AttributedString {
        var attr = AttributedString(text)
        guard submitted else { return attr }
        let wrong = unit.questions.filter { !IELTSScoringEngine.isCorrect(response: responses[$0.id] ?? "", for: $0) }
        for q in wrong where !q.evidenceQuote.isEmpty {
            if let r = attr.range(of: q.evidenceQuote, options: .caseInsensitive) {
                attr[r].backgroundColor = IMTheme.brandGold.opacity(0.35)
            }
        }
        return attr
    }

    private func listeningPane(_ part: ListeningPart) -> some View {
        VStack(alignment: .leading, spacing: IMTheme.sp200) {
            Text("PART \(part.partNumber) · \(part.primaryAccent.displayName.uppercased())")
                .font(.system(size: 10, weight: .bold)).tracking(0.8)
                .foregroundStyle(IMTheme.accentListening)
            Text(part.title).imText(.heading5)
            Text(part.contextDescription)
                .imText(.body6)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: IMTheme.sp100) {
                ListeningPlayButton(audio: app.audioService, dialogue: part.dialogue)
                Text("Practice mode: replay as often as you like. Full mocks play once.")
                    .imText(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if submitted {
                DisclosureGroup(isExpanded: $showTranscript) {
                    VStack(alignment: .leading, spacing: IMTheme.sp100) {
                        ForEach(part.dialogue) { turn in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(turn.speaker).imText(.caption3).foregroundStyle(.secondary)
                                Text(highlighted(turn.text))
                                    .imText(.body3)
                                    .textSelection(.enabled)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, IMTheme.sp75)
                } label: {
                    Text("Transcript (evidence for wrong answers highlighted)").imText(.title3)
                }
            } else {
                IMCard {
                    Label("The transcript opens after you submit.", systemImage: "lock")
                        .imText(.body6)
                        .foregroundStyle(.secondary)
                }
            }

            if !part.keyVocabulary.isEmpty && submitted {
                IMSectionTitle("Key vocabulary")
                Text(part.keyVocabulary.joined(separator: " · "))
                    .imText(.body6)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Question pane

    private var questionPane: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp200) {
            if submitted { resultSummary }
            ForEach(unit.questions) { q in
                QuestionCard(
                    question: q,
                    response: Binding(get: { responses[q.id] ?? "" }, set: { responses[q.id] = $0 }),
                    submitted: submitted,
                    showArabic: showArabic,
                    onLearn: { app.openLesson(for: q.skillTag) }
                )
            }
            if !submitted {
                Button(action: submit) {
                    Text("Submit answers").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .frame(maxWidth: 640, alignment: .leading)
    }

    private var resultSummary: some View {
        let correct = unit.questions.filter { IELTSScoringEngine.isCorrect(response: responses[$0.id] ?? "", for: $0) }.count
        let total = unit.questions.count
        let bySkill: [SkillRow] = Dictionary(grouping: unit.questions, by: { $0.skillTag })
            .map { entry in
                SkillRow(
                    tag: entry.key,
                    right: entry.value.filter { IELTSScoringEngine.isCorrect(response: responses[$0.id] ?? "", for: $0) }.count,
                    total: entry.value.count
                )
            }
            .sorted { Double($0.right) / Double($0.total) < Double($1.right) / Double($1.total) }
        let minutes = max(1, Int(Date().timeIntervalSince(startedAt) / 60))

        return IMCard(padding: IMTheme.sp200) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(correct)/\(total)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("correct · \(minutes) min").imText(.body6).foregroundStyle(.secondary)
                Spacer()
            }
            Text("A single set doesn't give a reliable band, so none is shown. Bands come from full 40-question tests.")
                .imText(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(bySkill) { row in
                HStack {
                    IMSkillBar(
                        title: SkillCatalog.title(for: row.tag),
                        value: Double(row.right) / Double(row.total),
                        tint: IMTheme.accuracyColor(Double(row.right) / Double(row.total)),
                        trailingText: "\(row.right)/\(row.total)"
                    )
                    if row.right < row.total, StrategyLessons.lesson(for: row.tag) != nil {
                        Button("Lesson") { app.openLesson(for: row.tag) }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                    }
                }
            }
        }
    }

    // MARK: Submit

    private func submit() {
        guard !submitted else { return }
        app.audioService.stopSpeaking()
        submitted = true
        showTranscript = true
        let module = unit.kind == .reading ? "Reading" : "Listening"
        app.recordObjectiveResults(questions: unit.questions, responses: responses, module: module)
        app.markUnitSeen(unit.id)
    }
}

// MARK: - Question card

struct QuestionCard: View {
    let question: ExamQuestion
    @Binding var response: String
    let submitted: Bool
    let showArabic: Bool
    let onLearn: () -> Void

    private var isCorrect: Bool { IELTSScoringEngine.isCorrect(response: response, for: question) }

    var body: some View {
        IMCard(padding: IMTheme.sp200) {
            HStack(alignment: .firstTextBaseline, spacing: IMTheme.sp75) {
                Text("\(question.number)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(statusColor.opacity(0.15)))
                    .foregroundStyle(statusColor)
                Text(question.prompt)
                    .imText(.body2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            HStack(spacing: 6) {
                IMBadge(text: question.format.rawValue)
                if let max = question.maxWordCount { IMBadge(text: max == 1 ? "One word" : "Max \(max) words") }
            }

            answerInput

            if submitted { feedback }
        }
    }

    private var statusColor: Color {
        guard submitted else { return IMTheme.accentPrimary }
        return isCorrect ? IMTheme.statusSuccess : IMTheme.statusDanger
    }

    @ViewBuilder
    private var answerInput: some View {
        if question.options.isEmpty {
            TextField("Type your answer", text: $response)
                .textFieldStyle(.roundedBorder)
                .disabled(submitted)
        } else if question.options.count > 5 {
            Picker("Answer", selection: $response) {
                Text("Choose…").tag("")
                ForEach(question.options, id: \.self) { Text($0).tag($0) }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .disabled(submitted)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(question.options, id: \.self) { opt in
                    Button {
                        if !submitted { response = opt }
                    } label: {
                        HStack(spacing: IMTheme.sp75) {
                            Image(systemName: response == opt ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(response == opt ? IMTheme.accentPrimary : .secondary)
                            Text(opt).imText(.body6).multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .fill(response == opt ? IMTheme.accentPrimary.opacity(0.08) : Color.clear)
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var feedback: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp75) {
            HStack(spacing: 6) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(statusColor)
                if isCorrect {
                    Text("Correct").imText(.body4).foregroundStyle(statusColor)
                } else {
                    Text("Answer: \(question.acceptedAnswers.first ?? "")").imText(.body4).foregroundStyle(statusColor)
                }
            }
            Text(question.explanation)
                .imText(.body6)
                .fixedSize(horizontal: false, vertical: true)
            if !question.evidenceQuote.isEmpty {
                Text("“\(question.evidenceQuote)”")
                    .imText(.caption2)
                    .italic()
                    .foregroundStyle(.secondary)
            }
            if let note = question.distractorNote, !isCorrect {
                Label(note, systemImage: "exclamationmark.triangle")
                    .imText(.caption2)
                    .foregroundStyle(IMTheme.statusWarning)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if showArabic {
                if let ar = question.arabicExplanation {
                    IMArabicBlock(text: ar)
                } else if let lesson = StrategyLessons.lesson(for: question.skillTag) {
                    IMArabicBlock(title: lesson.arabicTitle, text: lesson.arabicSummary)
                }
            }
            if !isCorrect {
                Button(action: onLearn) {
                    Label("Learn: \(SkillCatalog.title(for: question.skillTag))", systemImage: "graduationcap")
                }
                .buttonStyle(.link)
            }
        }
        .padding(.top, 2)
    }
}

private struct SkillRow: Identifiable {
    let tag: String
    let right: Int
    let total: Int
    var id: String { tag }
}

/// Play/stop control that observes the shared audio engine so its label tracks playback.
struct ListeningPlayButton: View {
    @ObservedObject var audio: AudioEngineService
    let dialogue: [DialogueTurn]

    var body: some View {
        Button {
            if audio.isSpeakingTTS {
                audio.stopSpeaking()
            } else {
                audio.speakDialogue(dialogue)
            }
        } label: {
            Label(audio.isSpeakingTTS ? "Stop" : "Play recording",
                  systemImage: audio.isSpeakingTTS ? "stop.fill" : "play.fill")
                .frame(minWidth: 140)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(IMTheme.accentListening)
    }
}
