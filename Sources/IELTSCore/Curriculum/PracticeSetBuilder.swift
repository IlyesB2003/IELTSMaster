import Foundation

// MARK: - Exposure memory

/// Remembers what the learner has already seen, so practice never silently repeats.
public struct ExposureState: Codable, Sendable, Equatable {
    /// Practice-unit IDs (a passage or a listening part) → last time completed.
    public var seenUnits: [String: Date]
    /// Full mock exam ID → number of completed attempts.
    public var examAttempts: [String: Int]

    public init(seenUnits: [String: Date] = [:], examAttempts: [String: Int] = [:]) {
        self.seenUnits = seenUnits
        self.examAttempts = examAttempts
    }

    public mutating func markUnitSeen(_ id: String, at date: Date = Date()) {
        seenUnits[id] = date
    }

    public mutating func markExamAttempted(_ id: String) {
        examAttempts[id, default: 0] += 1
    }

    public func attempts(forExam id: String) -> Int { examAttempts[id] ?? 0 }
    public func hasSeen(unit id: String) -> Bool { seenUnits[id] != nil }
}

// MARK: - Practice units

/// A self-contained practice set: one Reading passage with its questions, or one Listening part.
public struct PracticeUnit: Identifiable, Hashable, Sendable {
    public enum Kind: String, Codable, Sendable { case reading, listening }

    public let id: String
    public let kind: Kind
    public let sourceTitle: String     // exam title, or "Fresh AI practice"
    public let origin: ContentOrigin
    public let passage: ReadingPassage?
    public let part: ListeningPart?

    public var title: String { passage?.title ?? part?.title ?? "Practice" }
    public var questions: [ExamQuestion] { passage?.questions ?? part?.questions ?? [] }
    public var skillTags: Set<String> { Set(questions.map(\.skillTag)) }

    public static func reading(_ p: ReadingPassage, source: String, origin: ContentOrigin) -> PracticeUnit {
        PracticeUnit(id: p.id, kind: .reading, sourceTitle: source, origin: origin, passage: p, part: nil)
    }

    public static func listening(_ p: ListeningPart, source: String, origin: ContentOrigin) -> PracticeUnit {
        PracticeUnit(id: p.id, kind: .listening, sourceTitle: source, origin: origin, passage: nil, part: p)
    }
}

/// Chooses what to practise next. Pure functions: the caller passes in state, nothing is stored here.
public enum PracticeSetBuilder {

    public static func readingUnits(from exams: [MockExam], generated: [ReadingPassage] = []) -> [PracticeUnit] {
        exams.flatMap { exam in
            exam.readingPassages.map { PracticeUnit.reading($0, source: exam.title, origin: exam.provenance.origin) }
        } + generated.map { PracticeUnit.reading($0, source: "Fresh AI practice", origin: .aiGeneratedValidated) }
    }

    public static func listeningUnits(from exams: [MockExam]) -> [PracticeUnit] {
        exams.flatMap { exam in
            exam.listeningParts.map { PracticeUnit.listening($0, source: exam.title, origin: exam.provenance.origin) }
        }
    }

    /// The next unit to practise.
    ///
    /// Order of preference:
    /// 1. never-seen units, ranked by how many of the learner's weak skills they exercise;
    /// 2. if everything has been seen, the unit seen longest ago (`isRepeat == true`, so the UI can say so).
    ///
    /// `focusSkill` restricts the choice to units containing that skill, when any exist.
    public static func next(
        from units: [PracticeUnit],
        exposure: ExposureState,
        weakSkills: [String],
        focusSkill: String? = nil,
        excluding currentID: String? = nil
    ) -> (unit: PracticeUnit, isRepeat: Bool)? {
        var pool = units.filter { $0.id != currentID }
        if pool.isEmpty { pool = units }
        if let focusSkill {
            let focused = pool.filter { $0.skillTags.contains(focusSkill) }
            if !focused.isEmpty { pool = focused }
        }
        let weak = Set(weakSkills)

        let unseen = pool.filter { !exposure.hasSeen(unit: $0.id) }
        if !unseen.isEmpty {
            let ranked = unseen.sorted { a, b in
                let wa = a.skillTags.intersection(weak).count
                let wb = b.skillTags.intersection(weak).count
                if wa != wb { return wa > wb }
                return a.id < b.id // stable order between equally relevant units
            }
            return ranked.first.map { ($0, false) }
        }

        let oldest = pool.min { (exposure.seenUnits[$0.id] ?? .distantPast) < (exposure.seenUnits[$1.id] ?? .distantPast) }
        return oldest.map { ($0, true) }
    }

    /// How many units of a kind the learner has not seen yet.
    public static func unseenCount(_ units: [PracticeUnit], exposure: ExposureState) -> Int {
        units.filter { !exposure.hasSeen(unit: $0.id) }.count
    }

    /// Recommended full mock: the first exam never attempted, otherwise the least-attempted one.
    public static func nextMockExam(from exams: [MockExam], exposure: ExposureState) -> (exam: MockExam, isRetake: Bool)? {
        guard !exams.isEmpty else { return nil }
        if let fresh = exams.first(where: { exposure.attempts(forExam: $0.id) == 0 }) {
            return (fresh, false)
        }
        return exams
            .min { exposure.attempts(forExam: $0.id) < exposure.attempts(forExam: $1.id) }
            .map { ($0, true) }
    }
}
