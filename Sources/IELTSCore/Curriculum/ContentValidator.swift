import Foundation

public struct ContentValidationReport: Codable, Sendable {
    public let examID: String
    public let passed: Bool
    public let listeningCount: Int
    public let readingCount: Int
    public let duplicatePromptCount: Int
    /// Questions in this exam whose stem is a near-duplicate (word-trigram Jaccard >= 0.6) of a stem in another exam of the bank.
    public let crossExamDuplicateCount: Int
    public let issues: [String]
    public let validatedAt: Date

    public init(
        examID: String,
        passed: Bool,
        listeningCount: Int,
        readingCount: Int,
        duplicatePromptCount: Int,
        crossExamDuplicateCount: Int = 0,
        issues: [String],
        validatedAt: Date = Date()
    ) {
        self.crossExamDuplicateCount = crossExamDuplicateCount
        self.examID = examID
        self.passed = passed
        self.listeningCount = listeningCount
        self.readingCount = readingCount
        self.duplicatePromptCount = duplicatePromptCount
        self.issues = issues
        self.validatedAt = validatedAt
    }
}

/// Automated Quality Assurance validator ensuring generated or authored
/// IELTS mock exams meet strict structural, linguistic, consistency, and copyright rules.
public struct ContentValidator: Sendable {
    public init() {}

    public func validate(exam: MockExam) -> ContentValidationReport {
        var issues: [String] = []

        // 1. Listening structure (4 parts, 40 questions)
        if exam.listeningParts.count != 4 {
            issues.append("Listening must have exactly 4 parts (found \(exam.listeningParts.count)).")
        }
        let listeningQuestions = exam.listeningParts.flatMap(\.questions)
        if listeningQuestions.count != 40 {
            issues.append("Listening must have exactly 40 questions (found \(listeningQuestions.count)).")
        }
        for part in exam.listeningParts {
            let transcriptLower = part.fullTranscript.lowercased()
            if part.dialogue.isEmpty {
                issues.append("Listening Part \(part.partNumber) has an empty transcript.")
            }
            for q in part.questions {
                if q.acceptedAnswers.isEmpty || q.acceptedAnswers.allSatisfy({ $0.trimmingCharacters(in: .whitespaces).isEmpty }) {
                    issues.append("Listening Q\(q.number) has no accepted answer.")
                }
                if !q.evidenceQuote.isEmpty {
                    let tokens = q.evidenceQuote.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
                    let keyToken = tokens.max(by: { $0.count < $1.count }) ?? ""
                    if !keyToken.isEmpty && !transcriptLower.contains(keyToken) {
                        issues.append("Listening Q\(q.number) evidence token '\(keyToken)' not verified in transcript.")
                    }
                }
            }
        }

        // 2. Reading structure (3 passages, 40 questions)
        if exam.readingPassages.count != 3 {
            issues.append("Reading must have exactly 3 passages (found \(exam.readingPassages.count)).")
        }
        let readingQuestions = exam.readingPassages.flatMap(\.questions)
        if readingQuestions.count != 40 {
            issues.append("Reading must have exactly 40 questions (found \(readingQuestions.count)).")
        }
        for passage in exam.readingPassages {
            let passageLower = passage.fullText.lowercased()
            if passage.paragraphs.count < 3 {
                issues.append("Reading Passage \(passage.passageNumber) has fewer than 3 paragraphs.")
            }
            for q in passage.questions {
                if q.acceptedAnswers.isEmpty {
                    issues.append("Reading Q\(q.number) has no accepted answer.")
                }
                if !q.evidenceQuote.isEmpty {
                    let tokens = q.evidenceQuote.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
                    let keyToken = tokens.max(by: { $0.count < $1.count }) ?? ""
                    if !keyToken.isEmpty && !passageLower.contains(keyToken) {
                        issues.append("Reading Q\(q.number) evidence token '\(keyToken)' not found in passage \(passage.passageNumber).")
                    }
                }
            }
        }

        // 2b. Realistic Academic Reading length and MCQ option count.
        // Official passages are long texts; the three together run roughly 2,150–2,750 words.
        for passage in exam.readingPassages {
            let words = passage.paragraphs.reduce(0) { $0 + IELTSScoringEngine.countWords(in: $1) }
            if words < ContentValidator.minimumWordsPerPassage {
                issues.append("Reading Passage \(passage.passageNumber) has \(words) words; minimum for a realistic Academic passage is \(ContentValidator.minimumWordsPerPassage).")
            }
            for q in passage.questions where q.format == .multipleChoice && q.options.count < 4 {
                issues.append("Reading Q\(q.number) is multiple choice with \(q.options.count) options; Academic Reading uses at least four (A–D).")
            }
        }
        let totalReadingWords = exam.readingPassages.reduce(0) { acc, p in acc + p.paragraphs.reduce(0) { $0 + IELTSScoringEngine.countWords(in: $1) } }
        if exam.readingPassages.count == 3 && totalReadingWords < ContentValidator.minimumTotalReadingWords {
            issues.append("Reading passages total \(totalReadingWords) words; minimum \(ContentValidator.minimumTotalReadingWords).")
        }

        // 3. Duplicate prompt detection within exam
        let allPrompts = (listeningQuestions + readingQuestions).map { $0.prompt.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        let duplicateCount = allPrompts.count - Set(allPrompts).count
        if duplicateCount > 0 {
            issues.append("Detected \(duplicateCount) duplicate question prompt(s) within exam \(exam.id).")
        }

        // 4. Writing minimums & Speaking structure
        if exam.writingTask1.minimumWords < 150 {
            issues.append("Writing Task 1 minimum word count must be at least 150.")
        }
        if exam.writingTask2.minimumWords < 250 {
            issues.append("Writing Task 2 minimum word count must be at least 250.")
        }
        if exam.speakingSet.part1Questions.count < 3 || exam.speakingSet.part2CueCard.bulletPoints.count < 3 || exam.speakingSet.part3Questions.count < 3 {
            issues.append("Speaking prompt set is incomplete.")
        }

        // 5. Copyright & provenance check
        if exam.provenance.origin != .officialPublicSample && exam.provenance.isOfficialIELTSMaterial {
            issues.append("Original or AI-generated practice material must never be labeled as official IELTS material.")
        }

        return ContentValidationReport(
            examID: exam.id,
            passed: issues.isEmpty,
            listeningCount: listeningQuestions.count,
            readingCount: readingQuestions.count,
            duplicatePromptCount: duplicateCount,
            issues: issues
        )
    }

    // MARK: - Bank-level (cross-exam) validation

    public static let minimumWordsPerPassage = 600
    public static let minimumTotalReadingWords = 2_000
    /// Word-trigram Jaccard similarity at or above this marks two stems as the same question.
    public static let nearDuplicateThreshold = 0.6
    /// More than this many near-duplicate stems shared with other exams fails the exam.
    public static let maxCrossExamDuplicatesPerExam = 3

    /// Validates every exam on its own, then compares exams with each other.
    /// An exam fails if its question stems or passage paragraphs substantially repeat another exam's,
    /// which is what a slot-filled template produces.
    public func validateBank(_ exams: [MockExam]) -> (passedCount: Int, totalCount: Int, reports: [ContentValidationReport]) {
        var reports = exams.map { validate(exam: $0) }
        let cross = crossExamDuplicates(exams)
        for (i, exam) in exams.enumerated() {
            let dupStems = cross.stemDuplicates[exam.id] ?? 0
            let dupParas = cross.paragraphDuplicates[exam.id] ?? 0
            var issues = reports[i].issues
            if dupStems > ContentValidator.maxCrossExamDuplicatesPerExam {
                issues.append("\(dupStems) question stem(s) are near-duplicates of questions in other exams (template reuse).")
            }
            if dupParas > 0 {
                issues.append("\(dupParas) reading paragraph(s) are near-duplicates of paragraphs in other exams.")
            }
            let r = reports[i]
            reports[i] = ContentValidationReport(
                examID: r.examID,
                passed: issues.isEmpty,
                listeningCount: r.listeningCount,
                readingCount: r.readingCount,
                duplicatePromptCount: r.duplicatePromptCount,
                crossExamDuplicateCount: dupStems,
                issues: issues,
                validatedAt: r.validatedAt
            )
        }
        let passed = reports.filter(\.passed).count
        return (passed, exams.count, reports)
    }

    /// Lower-cased alphanumeric tokens with digits removed, so changed numbers don't hide a reused stem.
    static func tokens(_ text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }
    }

    static func shingles(_ text: String) -> Set<String> {
        let t = tokens(text)
        guard t.count >= 3 else { return t.isEmpty ? [] : [t.joined(separator: " ")] }
        var out = Set<String>()
        for i in 0...(t.count - 3) { out.insert("\(t[i]) \(t[i+1]) \(t[i+2])") }
        return out
    }

    public static func similarity(_ a: String, _ b: String) -> Double {
        let sa = shingles(a), sb = shingles(b)
        guard !sa.isEmpty, !sb.isEmpty else { return 0 }
        let inter = sa.intersection(sb).count
        return Double(inter) / Double(sa.union(sb).count)
    }

    /// Counts, per exam, items that near-duplicate an item in a *different* exam.
    /// Uses an inverted shingle index so a 30-exam bank is compared in well under a second.
    func crossExamDuplicates(_ exams: [MockExam]) -> (stemDuplicates: [String: Int], paragraphDuplicates: [String: Int]) {
        struct Item { let examID: String; let shingles: Set<String> }
        func duplicates(_ items: [Item]) -> [String: Int] {
            var index: [String: [Int]] = [:]
            for (i, it) in items.enumerated() { for sh in it.shingles { index[sh, default: []].append(i) } }
            var result: [String: Int] = [:]
            for (i, it) in items.enumerated() where !it.shingles.isEmpty {
                var shared: [Int: Int] = [:]
                for sh in it.shingles { for j in index[sh] ?? [] where j != i && items[j].examID != it.examID { shared[j, default: 0] += 1 } }
                let isDup = shared.contains { j, inter in
                    let union = it.shingles.count + items[j].shingles.count - inter
                    return union > 0 && Double(inter) / Double(union) >= ContentValidator.nearDuplicateThreshold
                }
                if isDup { result[it.examID, default: 0] += 1 }
            }
            return result
        }
        var stems: [Item] = []
        var paras: [Item] = []
        for exam in exams {
            let qs = exam.listeningParts.flatMap(\.questions) + exam.readingPassages.flatMap(\.questions)
            // Very short generic stems ("Which title best fits the passage?") are allowed to recur.
            for q in qs where ContentValidator.tokens(q.prompt).count >= 6 {
                stems.append(Item(examID: exam.id, shingles: ContentValidator.shingles(q.prompt)))
            }
            for p in exam.readingPassages.flatMap(\.paragraphs) {
                paras.append(Item(examID: exam.id, shingles: ContentValidator.shingles(p)))
            }
        }
        return (duplicates(stems), duplicates(paras))
    }
}
