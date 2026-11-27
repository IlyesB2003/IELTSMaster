import Foundation
import SwiftUI
import IELTSCore

/// Adaptive practice, weakness tracking and teaching actions.
extension AppState {
    static let skillEventsCollection = "skill_events"
    static let exposureCollection = "exposure_state"
    static let generatedReadingCollection = "generated_reading"

    // MARK: - Derived skill picture

    public var skillMastery: [SkillMastery] { SkillAnalyzer.mastery(from: skillEvents) }
    public var weakestSkills: [SkillMastery] { SkillAnalyzer.weaknesses(from: skillEvents) }
    public var weakSkillTags: [String] { weakestSkills.map(\.skillTag) }

    public var readingUnits: [PracticeUnit] {
        SharedContentCatalog.bundled.reading.map {
            PracticeUnit.reading($0, source: "Focused reading practice", origin: .originalPractice)
        } + generatedPassages.map {
            PracticeUnit.reading($0, source: "Fresh AI practice", origin: .aiGeneratedValidated)
        }
    }
    public var listeningUnits: [PracticeUnit] {
        SharedContentCatalog.bundled.listening.map {
            PracticeUnit.listening($0, source: "Focused listening practice", origin: .originalPractice)
        }
    }
    public var unseenReadingCount: Int { PracticeSetBuilder.unseenCount(readingUnits, exposure: exposure) }
    public var unseenListeningCount: Int { PracticeSetBuilder.unseenCount(listeningUnits, exposure: exposure) }

    public var recommendedMock: (exam: MockExam, isRetake: Bool)? {
        PracticeSetBuilder.nextMockExam(from: mockExams, exposure: exposure)
    }

    // MARK: - Recording results

    /// Records every graded objective answer as skill evidence and logs wrong answers in the Mistake Notebook.
    /// Call once per submission from any module (practice sets, Reading, Listening, full mocks).
    public func recordObjectiveResults(questions: [ExamQuestion], responses: [String: String], module: String, logMistakes: Bool = true) {
        let events = SkillAnalyzer.events(questions: questions, responses: responses, module: module)
        skillEvents.append(contentsOf: events)
        for e in events { try? db.upsert(e, id: e.id, collection: AppState.skillEventsCollection) }

        guard logMistakes else { return }
        for q in questions where !IELTSScoringEngine.isCorrect(response: responses[q.id] ?? "", for: q) {
            logMistake(MistakeEntry(
                sourceModule: module,
                originalPrompt: q.prompt,
                learnerAnswer: (responses[q.id] ?? "").isEmpty ? "(blank)" : (responses[q.id] ?? ""),
                correctAnswer: q.acceptedAnswers.first ?? "",
                explanation: q.explanation,
                arabicExplanation: q.arabicExplanation,
                errorCategory: "\(module) — \(SkillCatalog.title(for: q.skillTag))",
                relatedGrammarRule: q.skillTag
            ))
        }
    }

    public func markUnitSeen(_ unitID: String) {
        exposure.markUnitSeen(unitID)
        saveExposure()
    }

    public func markExamAttempted(_ examID: String) {
        exposure.markExamAttempted(examID)
        saveExposure()
    }

    private func saveExposure() {
        try? db.upsert(exposure, id: "state", collection: AppState.exposureCollection)
    }

    // MARK: - Starting practice

    /// Opens the next practice set the learner hasn't seen, targeting weak skills.
    /// Returns false when there is nothing to practise.
    @discardableResult
    public func startNextPractice(_ kind: PracticeUnit.Kind, focusSkill: String? = nil) -> Bool {
        let units = kind == .reading ? readingUnits : listeningUnits
        guard let pick = PracticeSetBuilder.next(
            from: units, exposure: exposure, weakSkills: weakSkillTags,
            focusSkill: focusSkill, excluding: activePractice?.id
        ) else { return false }
        activePractice = pick.unit
        activePracticeIsRepeat = pick.isRepeat
        selectedSection = .practice
        return true
    }

    public func closePractice() {
        audioService.stopSpeaking()
        activePractice = nil
    }

    /// Generates a fresh, validated Reading passage with the learner's AI model, then opens it.
    public func generateFreshReading(focusSkill: String? = nil) async {
        guard !isGeneratingPractice else { return }
        isGeneratingPractice = true
        generationMessage = "Writing a new passage and checking every answer against it. This can take a minute or two on a local model."
        defer { isGeneratingPractice = false }

        let generator = PracticeGenerator(llm: llm)
        let existing = readingUnits.flatMap(\.questions)
        do {
            let passage = try await generator.generateReadingPassage(
                config: modelRouting,
                fallbackModel: primaryOllamaModel,
                externalConsentGranted: profile.externalAIConsentGranted,
                existingQuestions: existing,
                focusSkill: focusSkill
            )
            generatedPassages.append(passage)
            try? db.upsert(passage, id: passage.id, collection: AppState.generatedReadingCollection)
            generationMessage = nil
            activePractice = PracticeUnit.reading(passage, source: "Fresh AI practice", origin: .aiGeneratedValidated)
            activePracticeIsRepeat = false
            selectedSection = .practice
        } catch {
            generationMessage = error.localizedDescription
        }
    }

    // MARK: - Target band

    public static let targetBandOptions: [Double] = stride(from: 5.5, through: 9.0, by: 0.5).map { $0 }

    /// Changes the goal, saves it, and rebuilds the study plan for the new target.
    public func setTargetBand(_ band: Double) {
        let clamped = min(max(band, 4.0), 9.0)
        guard clamped != profile.targetBand else { return }
        profile.targetBand = clamped
        regenerateStudyPlan(sessionMinutes: profile.preferredSessionMinutes)
    }

    // MARK: - Teaching

    public func openLesson(for skillTag: String) {
        coachFocusSkill = skillTag
        selectedSection = .coach
    }

    public func askTeacherToExplain(skillTag: String, module: String) {
        teachSpecificWeakness(SkillCatalog.title(for: skillTag), domain: module)
    }
}
