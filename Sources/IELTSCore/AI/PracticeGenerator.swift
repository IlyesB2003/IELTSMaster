import Foundation

/// Generates fresh Academic Reading practice with the learner's own AI model (local Ollama by default),
/// so practice keeps going after the hand-written bank has been used.
///
/// Every draft is checked by deterministic code before it is accepted: passage length, question
/// count, answer formats, every answer's evidence copied verbatim from the passage, completion
/// answers taken from the passage, no duplicate or near-duplicate questions. Drafts that fail are
/// rejected, never shown. Accepted passages are labelled "AI-generated" in the interface.
public struct PracticeGenerator {

    public struct Draft: Codable, Sendable {
        public struct Item: Codable, Sendable {
            public let type: String          // "tfng" | "mcq" | "gap"
            public let prompt: String
            public let options: [String]?
            public let answer: String
            public let evidence: String
            public let explanation: String

            public init(type: String, prompt: String, options: [String]?, answer: String, evidence: String, explanation: String) {
                self.type = type
                self.prompt = prompt
                self.options = options
                self.answer = answer
                self.evidence = evidence
                self.explanation = explanation
            }
        }
        public let title: String
        public let discipline: String
        public let paragraphs: [String]
        public let questions: [Item]

        public init(title: String, discipline: String, paragraphs: [String], questions: [Item]) {
            self.title = title
            self.discipline = discipline
            self.paragraphs = paragraphs
            self.questions = questions
        }
    }

    public enum GenerationError: LocalizedError {
        case noModel
        case rejected([String])
        case modelFailed(String)

        public var errorDescription: String? {
            switch self {
            case .noModel:
                return "No AI model is connected. Start Ollama and choose a model in AI Model Manager to generate fresh practice."
            case .rejected(let reasons):
                return "The model's drafts did not pass quality checks, so nothing was added. " + reasons.prefix(3).joined(separator: " ")
            case .modelFailed(let message):
                return "The model could not produce a passage: \(message)"
            }
        }
    }

    private let llm: LocalLLMService

    public init(llm: LocalLLMService) {
        self.llm = llm
    }

    public static let topics = [
        "the history of a farming technique", "animal behaviour research", "soil microbiology",
        "an engineering invention", "urban water supply", "the psychology of memory",
        "a lost ancient city", "renewable energy storage", "the economics of fishing",
        "coral reef restoration", "the development of writing systems", "sleep and learning",
        "plant domestication", "sound and architecture", "the science of taste",
        "glaciers and climate records", "public health campaigns", "the origins of money"
    ]

    /// Generates and validates one passage. Tries up to `attempts` drafts.
    public func generateReadingPassage(
        config: ModelRoutingConfiguration,
        fallbackModel: String,
        externalConsentGranted: Bool,
        existingQuestions: [ExamQuestion],
        focusSkill: String?,
        attempts: Int = 2
    ) async throws -> ReadingPassage {
        let model = config.model(for: .questionGenerator, fallback: fallbackModel)
        guard !model.isEmpty || (config.activeProvider.isExternal && externalConsentGranted) else {
            throw GenerationError.noModel
        }

        var lastReasons: [String] = []
        var modelError: String?
        for _ in 0..<max(1, attempts) {
            let topic = Self.topics.randomElement() ?? "a scientific discovery"
            let draft: Draft
            do {
                draft = try await llm.requestStructuredJSON(
                    Draft.self,
                    config: config,
                    role: .questionGenerator,
                    fallbackModel: fallbackModel,
                    systemPrompt: Self.systemPrompt,
                    userPrompt: Self.userPrompt(topic: topic, focusSkill: focusSkill),
                    externalConsentGranted: externalConsentGranted,
                    maxRetries: 1
                )
            } catch {
                modelError = error.localizedDescription
                continue
            }
            let reasons = Self.validate(draft, existingQuestions: existingQuestions)
            if reasons.isEmpty {
                return Self.makePassage(from: draft)
            }
            lastReasons = reasons
        }
        if lastReasons.isEmpty {
            throw GenerationError.modelFailed(modelError ?? "unknown error")
        }
        throw GenerationError.rejected(lastReasons)
    }

    // MARK: Prompts

    static let systemPrompt = """
    You write original IELTS Academic Reading practice material. Output JSON only.
    Never copy published IELTS or Cambridge texts. Write a new, factual, neutral academic passage.
    Rules:
    - 6 or 7 paragraphs, 700 to 850 words in total, formal academic register.
    - Exactly 13 questions about the passage, in passage order.
    - Questions 1-5: type "tfng"; answer is exactly "TRUE", "FALSE" or "NOT GIVEN"; include at least one of each.
    - Questions 6-9: type "mcq"; exactly 4 options written "A. ...", "B. ...", "C. ...", "D. ..."; answer is the single letter.
    - Questions 10-13: type "gap"; the prompt is a sentence containing "______"; the answer is ONE or TWO words copied exactly from the passage.
    - For every question, "evidence" is a phrase of 3 to 12 words copied EXACTLY from the passage that supports the answer (for NOT GIVEN, copy the phrase closest to the topic).
    - "explanation" says in one sentence why the answer is right.
    JSON shape: {"title": "...", "discipline": "...", "paragraphs": ["..."], "questions": [{"type": "tfng", "prompt": "...", "options": [], "answer": "...", "evidence": "...", "explanation": "..."}]}
    """

    static func userPrompt(topic: String, focusSkill: String?) -> String {
        var s = "Write a new passage about \(topic)."
        if let focusSkill {
            s += " The learner is working on \(SkillCatalog.title(for: focusSkill)); make those questions especially careful and fair."
        }
        return s
    }

    // MARK: Validation (deterministic)

    public static func validate(_ draft: Draft, existingQuestions: [ExamQuestion]) -> [String] {
        var issues: [String] = []
        let text = draft.paragraphs.joined(separator: " ")
        let lower = text.lowercased()
        let words = IELTSScoringEngine.countWords(in: text)

        if draft.paragraphs.count < 5 { issues.append("The passage has fewer than 5 paragraphs.") }
        if words < 550 { issues.append("The passage is too short (\(words) words).") }
        if words > 1_100 { issues.append("The passage is too long (\(words) words).") }
        if draft.title.trimmingCharacters(in: .whitespaces).isEmpty { issues.append("The passage has no title.") }
        if draft.questions.count != 13 { issues.append("Question count is \(draft.questions.count), expected 13.") }

        var tfngAnswers = Set<String>()
        var prompts = Set<String>()
        for (i, q) in draft.questions.enumerated() {
            let n = i + 1
            let evidence = q.evidence.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if evidence.count < 8 || !lower.contains(evidence) {
                issues.append("Question \(n): evidence is not copied from the passage.")
            }
            let key = q.prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            if key.isEmpty || prompts.contains(key) { issues.append("Question \(n): empty or duplicate prompt.") }
            prompts.insert(key)

            switch q.type.lowercased() {
            case "tfng":
                let a = q.answer.uppercased().trimmingCharacters(in: .whitespaces)
                if !["TRUE", "FALSE", "NOT GIVEN"].contains(a) { issues.append("Question \(n): T/F/NG answer '\(q.answer)' is invalid.") }
                tfngAnswers.insert(a)
            case "mcq":
                let opts = q.options ?? []
                let letters = ["A", "B", "C", "D"]
                if opts.count != 4 || zip(opts, letters).contains(where: { !$0.hasPrefix("\($1). ") }) {
                    issues.append("Question \(n): multiple choice needs four options labelled A–D.")
                }
                if !letters.contains(q.answer.uppercased().trimmingCharacters(in: .whitespaces)) {
                    issues.append("Question \(n): multiple-choice answer must be a single letter A–D.")
                }
            case "gap":
                let ans = q.answer.trimmingCharacters(in: .whitespacesAndNewlines)
                if !q.prompt.contains("___") { issues.append("Question \(n): gap prompt has no blank.") }
                if ans.isEmpty || IELTSScoringEngine.countWords(in: ans) > 2 { issues.append("Question \(n): gap answer must be one or two words.") }
                if !lower.contains(ans.lowercased()) { issues.append("Question \(n): gap answer is not taken from the passage.") }
            default:
                issues.append("Question \(n): unknown type '\(q.type)'.")
            }
        }
        if draft.questions.count == 13 && tfngAnswers.count < 3 {
            issues.append("T/F/NG questions must use TRUE, FALSE and NOT GIVEN at least once each.")
        }

        // Must not repeat questions the learner already has.
        let dupes = draft.questions.filter { q in
            existingQuestions.contains { ContentValidator.similarity($0.prompt, q.prompt) >= ContentValidator.nearDuplicateThreshold }
        }
        if !dupes.isEmpty { issues.append("\(dupes.count) question(s) repeat existing practice questions.") }
        return issues
    }

    // MARK: Conversion

    static func makePassage(from draft: Draft) -> ReadingPassage {
        let pid = "gen-\(UUID().uuidString.prefix(8).lowercased())"
        let questions: [ExamQuestion] = draft.questions.enumerated().map { i, q in
            let n = i + 1
            let id = "\(pid)-R\(n)"
            switch q.type.lowercased() {
            case "tfng":
                return ExamQuestion(id: id, number: n, format: .trueFalseNotGiven, prompt: q.prompt,
                                    options: ["TRUE", "FALSE", "NOT GIVEN"], acceptedAnswers: [q.answer.uppercased()],
                                    explanation: q.explanation, evidenceQuote: q.evidence, skillTag: "tfng")
            case "mcq":
                let opts = q.options ?? []
                let letter = q.answer.uppercased().trimmingCharacters(in: .whitespaces)
                var accepted = [letter]
                if let full = opts.first(where: { $0.hasPrefix("\(letter). ") }) {
                    accepted.append(full)
                    accepted.append(String(full.dropFirst(3)))
                }
                return ExamQuestion(id: id, number: n, format: .multipleChoice, prompt: q.prompt, options: opts,
                                    acceptedAnswers: accepted, explanation: q.explanation, evidenceQuote: q.evidence,
                                    skillTag: "multiple_choice")
            default:
                return ExamQuestion(id: id, number: n, format: .sentenceCompletion, prompt: q.prompt, options: [],
                                    acceptedAnswers: [q.answer.trimmingCharacters(in: .whitespacesAndNewlines)], maxWordCount: 2,
                                    explanation: q.explanation, evidenceQuote: q.evidence, skillTag: "sentence_completion")
            }
        }
        return ReadingPassage(id: pid, passageNumber: 1, title: draft.title, discipline: draft.discipline,
                              paragraphs: draft.paragraphs, questions: questions)
    }
}
