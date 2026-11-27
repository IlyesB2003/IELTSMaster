import Foundation

// MARK: - Skill events

/// One graded answer, tagged with the IELTS sub-skill it tests (e.g. "tfng", "matching_headings").
/// Every objective answer the learner submits becomes a SkillEvent, so weaknesses come from
/// what the learner actually did, never from a guess.
public struct SkillEvent: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let skillTag: String
    public let module: String      // "Reading", "Listening", "Grammar", …
    public let itemID: String      // question ID
    public let correct: Bool
    public let date: Date

    public init(id: String = UUID().uuidString, skillTag: String, module: String, itemID: String, correct: Bool, date: Date = Date()) {
        self.id = id
        self.skillTag = skillTag
        self.module = module
        self.itemID = itemID
        self.correct = correct
        self.date = date
    }
}

/// Recency-weighted performance on one sub-skill.
public struct SkillMastery: Identifiable, Hashable, Sendable {
    public var id: String { "\(module)|\(skillTag)" }
    public let skillTag: String
    public let module: String
    public let attempts: Int
    public let correct: Int
    /// 0…1. Recent answers count more (half-life `SkillAnalyzer.halfLifeDays`).
    public let weightedAccuracy: Double
    public let confidence: AssessmentConfidence
    public let lastPractised: Date

    public var title: String { SkillCatalog.title(for: skillTag) }
    public var isWeak: Bool { attempts >= SkillAnalyzer.minimumAttemptsForWeakness && weightedAccuracy < SkillAnalyzer.weaknessThreshold }
}

public enum SkillAnalyzer {
    public static let halfLifeDays: Double = 21
    public static let weaknessThreshold: Double = 0.75
    public static let minimumAttemptsForWeakness = 3

    /// Aggregates events per (module, skill). Deterministic: same events and `now` give the same result.
    public static func mastery(from events: [SkillEvent], now: Date = Date()) -> [SkillMastery] {
        let groups = Dictionary(grouping: events) { "\($0.module)|\($0.skillTag)" }
        return groups.values.compactMap { group -> SkillMastery? in
            guard let first = group.first else { return nil }
            var weightSum = 0.0
            var weightedCorrect = 0.0
            for e in group {
                let ageDays = max(0, now.timeIntervalSince(e.date) / 86_400)
                let w = pow(0.5, ageDays / halfLifeDays)
                weightSum += w
                if e.correct { weightedCorrect += w }
            }
            let n = group.count
            let confidence: AssessmentConfidence = n < 5 ? .low : (n < 15 ? .moderate : .high)
            return SkillMastery(
                skillTag: first.skillTag,
                module: first.module,
                attempts: n,
                correct: group.filter(\.correct).count,
                weightedAccuracy: weightSum > 0 ? weightedCorrect / weightSum : 0,
                confidence: confidence,
                lastPractised: group.map(\.date).max() ?? now
            )
        }
        .sorted { ($0.module, $0.title) < ($1.module, $1.title) }
    }

    /// Weakest sub-skills first. Only skills with enough evidence are reported.
    public static func weaknesses(from events: [SkillEvent], now: Date = Date(), limit: Int = 5) -> [SkillMastery] {
        Array(
            mastery(from: events, now: now)
                .filter(\.isWeak)
                .sorted { $0.weightedAccuracy < $1.weightedAccuracy }
                .prefix(limit)
        )
    }

    /// Converts a graded question set into events.
    public static func events(questions: [ExamQuestion], responses: [String: String], module: String, date: Date = Date()) -> [SkillEvent] {
        questions.map { q in
            SkillEvent(
                skillTag: q.skillTag,
                module: module,
                itemID: q.id,
                correct: IELTSScoringEngine.isCorrect(response: responses[q.id] ?? "", for: q),
                date: date
            )
        }
    }
}

// MARK: - Skill catalogue

/// Human-readable names and teaching links for the skill tags used in the question bank.
public enum SkillCatalog {
    private static let titles: [String: String] = [
        "tfng": "True / False / Not Given",
        "ynng": "Yes / No / Not Given (writer's views)",
        "matching_headings": "Matching headings",
        "matching_features": "Matching features (people, groups)",
        "matching_information": "Locating information in paragraphs",
        "scanning": "Scanning for specific information",
        "sentence_endings": "Matching sentence endings",
        "sentence_completion": "Sentence completion",
        "summary_completion": "Summary completion",
        "note_completion": "Note completion",
        "flowchart": "Flowchart completion",
        "short_answer": "Short-answer questions",
        "multiple_choice": "Multiple choice",
        "writer_purpose": "Writer's purpose",
        "inference": "Inference",
        "main_idea": "Main idea",
        "paraphrasing": "Recognising paraphrase",
        "detail": "Catching specific details",
        "distractor_correction": "Ignoring distractors and corrections",
        "spelling": "Spelling names and words you hear",
        "numbers": "Numbers and prices",
        "dates": "Dates and times",
        "matching": "Listening matching",
        "matching_opinions": "Matching opinions in discussions",
        "comprehension": "General comprehension"
    ]

    private static let arabicTitles: [String: String] = [
        "tfng": "صحيح / خطأ / غير مذكور",
        "ynng": "نعم / لا / غير مذكور (آراء الكاتب)",
        "matching_headings": "مطابقة العناوين",
        "matching_features": "مطابقة الخصائص بالأشخاص",
        "matching_information": "تحديد مكان المعلومة في الفقرات",
        "scanning": "البحث السريع عن معلومة محددة",
        "sentence_endings": "مطابقة نهايات الجمل",
        "sentence_completion": "إكمال الجمل",
        "summary_completion": "إكمال الملخص",
        "note_completion": "إكمال الملاحظات",
        "flowchart": "إكمال المخطط الانسيابي",
        "short_answer": "الأسئلة ذات الإجابات القصيرة",
        "multiple_choice": "الاختيار من متعدد",
        "writer_purpose": "هدف الكاتب",
        "inference": "الاستنتاج",
        "main_idea": "الفكرة الرئيسية",
        "paraphrasing": "التعرّف على إعادة الصياغة",
        "detail": "التقاط التفاصيل الدقيقة",
        "distractor_correction": "تجاهل المشتتات والتصحيحات",
        "spelling": "تهجئة الأسماء والكلمات المسموعة",
        "numbers": "الأرقام والأسعار",
        "dates": "التواريخ والأوقات",
        "matching": "المطابقة في الاستماع",
        "matching_opinions": "مطابقة الآراء في النقاشات",
        "comprehension": "الفهم العام"
    ]

    public static func title(for tag: String) -> String {
        if let t = titles[tag] { return t }
        return tag.replacingOccurrences(of: "_", with: " ").capitalized
    }

    public static func arabicTitle(for tag: String) -> String? { arabicTitles[tag] }
}
