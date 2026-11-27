import Foundation
import SwiftUI
import Combine
import IELTSCore

public enum SidebarSection: String, CaseIterable, Identifiable, Hashable {
    case dashboard = "Today"
    case practice = "Smart Practice"
    case coach = "Skills Coach"
    case learningPlan = "My Learning Plan"
    case aiTeacher = "AI Teacher"
    case fullMockExams = "Full Mock Exams"
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    case speaking = "Speaking"
    case grammar = "Grammar"
    case vocabulary = "Vocabulary"
    case pronunciationLab = "Pronunciation Lab"
    case academicEnglish = "Academic English"
    case mistakeNotebook = "Mistake Notebook"
    case progressAnalytics = "Progress & Analytics"
    case resourceLibrary = "Resource Library"
    case aiModelManager = "AI Model Manager"
    case settings = "Settings"

    public var id: String { rawValue }

    public var symbol: String {
        switch self {
        case .dashboard: return "sun.max"
        case .practice: return "sparkles.rectangle.stack"
        case .coach: return "target"
        case .learningPlan: return "calendar.badge.checkmark"
        case .aiTeacher: return "person.bubble"
        case .fullMockExams: return "doc.text.magnifyingglass"
        case .listening: return "headphones"
        case .reading: return "book.pages"
        case .writing: return "pencil.and.outline"
        case .speaking: return "waveform.and.mic"
        case .grammar: return "textformat"
        case .vocabulary: return "character.book.closed"
        case .pronunciationLab: return "waveform"
        case .academicEnglish: return "graduationcap"
        case .mistakeNotebook: return "exclamationmark.triangle"
        case .progressAnalytics: return "chart.xyaxis.line"
        case .resourceLibrary: return "books.vertical"
        case .aiModelManager: return "cpu"
        case .settings: return "gearshape"
        }
    }
}

@MainActor
public final class AppState: ObservableObject {
    // Core Services
    public let db: DatabaseManager
    public let rag: RAGService
    public let llm: LocalLLMService
    public let teacherService: AITeacherService
    public let assessmentService: AssessmentService
    public let adaptiveEngine: AdaptiveLearningEngine
    public let audioService: AudioEngineService
    public let keychain: KeychainService
    public let validator: ContentValidator

    // Navigation & UI State
    @Published public var selectedSection: SidebarSection = .dashboard
    @Published public var showDiagnosticSheet: Bool = false
    @Published public var isExamFullScreenLocked: Bool = false
    @Published public var statusBanner: String?
    @Published public var seenDiagnosticQuestionIDs: Set<String> = []
    @Published public var latestWeaknessReports: [SkillWeaknessReport] = []

    // Adaptive practice state (persisted)
    @Published public var skillEvents: [SkillEvent] = []
    @Published public var exposure: ExposureState = ExposureState()
    @Published public var generatedPassages: [ReadingPassage] = []
    @Published public var activePractice: PracticeUnit?
    @Published public var activePracticeIsRepeat: Bool = false
    @Published public var isGeneratingPractice: Bool = false
    @Published public var generationMessage: String?
    @Published public var coachFocusSkill: String?

    // Persistent Domain State
    @Published public var profile: LearnerProfile
    @Published public var mockExams: [MockExam]
    @Published public var attempts: [ExamAttemptRecord]
    @Published public var mistakes: [MistakeEntry]
    @Published public var essays: [EssaySubmission]
    @Published public var recordings: [AudioRecordingRecord]
    @Published public var vocabulary: [VocabularyItem]
    @Published public var grammarProgress: [String: GrammarProgressRecord]
    @Published public var currentPlan: StudyPlan
    @Published public var teacherMessages: [TeacherMessage]
    @Published public var modelRouting: ModelRoutingConfiguration

    // Live AI Discovery State
    @Published public var discoveredModels: [LocalModelInfo] = []
    @Published public var ollamaStatus: String = "Not checked yet."
    @Published public var isStreamingTeacher: Bool = false
    @Published public var streamingTeacherDraft: String = ""
    private var teacherTask: Task<Void, Never>?
    /// Re-publishes audio engine changes so views reading `app.audioService` refresh (record button, waveform, playback).
    private var audioChangeForwarder: AnyCancellable?

    public init() {
        let database = (try? DatabaseManager()) ?? (try! DatabaseManager(databaseURL: FileManager.default.temporaryDirectory.appendingPathComponent("ielts_fallback.sqlite")))
        self.db = database
        self.rag = RAGService(documents: OfficialKnowledgeBase.documents)
        self.keychain = KeychainService()
        self.llm = LocalLLMService(keychain: keychain)
        self.teacherService = AITeacherService(llm: llm, rag: rag)
        self.assessmentService = AssessmentService(llm: llm, rag: rag)
        self.adaptiveEngine = AdaptiveLearningEngine()
        self.audioService = AudioEngineService()
        self.validator = ContentValidator()

        var loadedProfile = (try? database.loadProfile()) ?? LearnerProfile()
        if loadedProfile.displayName == "IELTS Academic Candidate" || loadedProfile.displayName.isEmpty {
            loadedProfile.displayName = "Ilyes BELKHIRI (Admin)"
            try? database.saveProfile(loadedProfile)
        }
        let loadedAttempts = (try? database.loadAttempts()) ?? []
        let loadedMistakes = (try? database.loadMistakes()) ?? []
        let loadedEssays = (try? database.loadEssays()) ?? []
        let loadedRecordings = (try? database.loadRecordings()) ?? []
        let loadedGrammar = (try? database.loadGrammarProgress()) ?? [:]
        let loadedMessages = (try? database.loadTeacherMessages()) ?? []
        let loadedRouting = (try? database.loadModelRouting()) ?? ModelRoutingConfiguration()
        let loadedSeenIDs = (try? database.fetchOne([String].self, id: "seen_diag_ids", collection: "adaptive_state")) ?? []

        var loadedVocab = (try? database.loadVocabularyItems()) ?? []
        if loadedVocab.isEmpty {
            loadedVocab = VocabularyBank.defaultVocabularyItems()
            for item in loadedVocab {
                try? database.saveVocabularyItem(item)
            }
        }

        self.profile = loadedProfile
        self.mockExams = SharedContentCatalog.bundled.mockExams
        self.attempts = loadedAttempts
        self.mistakes = loadedMistakes
        self.essays = loadedEssays
        self.recordings = loadedRecordings
        self.vocabulary = loadedVocab
        self.grammarProgress = loadedGrammar
        self.teacherMessages = loadedMessages
        self.modelRouting = loadedRouting
        self.seenDiagnosticQuestionIDs = Set(loadedSeenIDs)

        if let existingPlan = try? database.loadLatestStudyPlan() {
            self.currentPlan = existingPlan
        } else {
            let dueCount = adaptiveEngine.dueVocabularyItems(from: loadedVocab).count
            let generated = adaptiveEngine.generateWeeklyPlan(
                profile: loadedProfile,
                mistakes: loadedMistakes,
                grammarProgress: loadedGrammar,
                dueVocabCount: dueCount,
                sessionMinutes: loadedProfile.preferredSessionMinutes
            )
            self.currentPlan = generated
            try? database.saveStudyPlan(generated)
        }

        if !loadedProfile.hasCompletedDiagnostic {
            self.showDiagnosticSheet = true
        }

        self.skillEvents = ((try? database.fetchAll(SkillEvent.self, collection: AppState.skillEventsCollection)) ?? [])
            .sorted { $0.date < $1.date }
        self.exposure = (try? database.fetchOne(ExposureState.self, id: "state", collection: AppState.exposureCollection)) ?? ExposureState()
        self.generatedPassages = (try? database.fetchAll(ReadingPassage.self, collection: AppState.generatedReadingCollection)) ?? []

        self.audioChangeForwarder = audioService.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                MainActor.assumeIsolated { self?.objectWillChange.send() }
            }
    }

    // MARK: - Derived Metrics

    public var dueVocabularyCount: Int {
        adaptiveEngine.dueVocabularyItems(from: vocabulary).count
    }

    public var masteredGrammarCount: Int {
        grammarProgress.values.filter { $0.status == .mastered }.count
    }

    public var recurringMistakes: [MistakeEntry] {
        mistakes.filter { $0.isRecurringPattern && $0.masteryStatus != .mastered }
    }

    public var primaryOllamaModel: String {
        if let assigned = modelRouting.roleAssignments[ModelTaskRole.aiTeacher.rawValue], !assigned.isEmpty {
            return assigned
        }
        return discoveredModels.first?.name ?? ""
    }

    // MARK: - Actions

    public func refreshOllamaModels() async {
        ollamaStatus = "Inspecting local Ollama service..."
        do {
            let models = try await llm.discoverOllamaModels(baseURL: modelRouting.ollamaBaseURL)
            discoveredModels = models
            if models.isEmpty {
                ollamaStatus = "Ollama is running, but no models are installed. Pull a model such as qwen2.5:7b or llama3.1:8b."
            } else {
                ollamaStatus = "Connected to Ollama (\(models.count) local model(s) detected)."
                // Auto-assign recommended models for empty roles
                var updated = modelRouting
                for role in ModelTaskRole.allCases {
                    if updated.roleAssignments[role.rawValue]?.isEmpty ?? true,
                       let best = llm.recommendModel(for: role, from: models) {
                        updated.roleAssignments[role.rawValue] = best.name
                    }
                }
                modelRouting = updated
                try? db.saveModelRouting(updated)
            }
        } catch {
            discoveredModels = []
            ollamaStatus = "Ollama offline (\(error.localizedDescription)). Core learning and exam simulation remain fully operational offline."
        }
    }

    public func saveProfileChanges() {
        profile.updatedAt = Date()
        try? db.saveProfile(profile)
    }

    public func saveModelRoutingChanges() {
        try? db.saveModelRouting(modelRouting)
    }

    public func applyDiagnosticResult(_ result: DiagnosticAssessmentResult) {
        profile.estimatedOverallBand = result.overallBand
        profile.estimatedListeningBand = result.listeningBand
        profile.estimatedReadingBand = result.readingBand
        profile.estimatedWritingBand = result.writingBand
        profile.estimatedSpeakingBand = result.speakingBand
        profile.estimatedCEFR = result.estimatedCEFR
        profile.assessmentConfidence = result.confidence
        profile.hasCompletedDiagnostic = true
        saveProfileChanges()
        regenerateStudyPlan(sessionMinutes: profile.preferredSessionMinutes)
        showDiagnosticSheet = false
        statusBanner = "Diagnostic baseline updated. Estimated band \(String(format: "%.1f", result.overallBand)) (\(result.estimatedCEFR.rawValue))."
    }

    public func regenerateStudyPlan(sessionMinutes: Int) {
        profile.preferredSessionMinutes = sessionMinutes
        saveProfileChanges()
        let plan = adaptiveEngine.generateWeeklyPlan(
            profile: profile,
            mistakes: mistakes,
            grammarProgress: grammarProgress,
            dueVocabCount: dueVocabularyCount,
            sessionMinutes: sessionMinutes
        )
        currentPlan = plan
        try? db.saveStudyPlan(plan)
    }

    public func toggleSessionCompleted(_ sessionID: String) {
        guard let idx = currentPlan.sessions.firstIndex(where: { $0.id == sessionID }) else { return }
        currentPlan.sessions[idx].isCompleted.toggle()
        try? db.saveStudyPlan(currentPlan)
    }

    public func recordExamAttempt(_ attempt: ExamAttemptRecord) {
        attempts.insert(attempt, at: 0)
        try? db.saveAttempt(attempt)

        if let l = attempt.listeningBand { profile.estimatedListeningBand = l }
        if let r = attempt.readingBand { profile.estimatedReadingBand = r }
        if let w = attempt.writingBand { profile.estimatedWritingBand = w }
        if let s = attempt.speakingBand { profile.estimatedSpeakingBand = s }

        profile.estimatedOverallBand = IELTSScoringEngine.calculateOverallBand(
            listening: profile.estimatedListeningBand,
            reading: profile.estimatedReadingBand,
            writing: profile.estimatedWritingBand,
            speaking: profile.estimatedSpeakingBand
        )
        profile.estimatedCEFR = IELTSScoringEngine.approximateCEFR(forBand: profile.estimatedOverallBand)
        profile.assessmentConfidence = attempts.count >= 3 ? .high : .moderate
        saveProfileChanges()
    }

    public func logMistake(_ entry: MistakeEntry) {
        let merged = adaptiveEngine.recordMistake(entry, existing: mistakes)
        if let idx = mistakes.firstIndex(where: { $0.id == merged.id }) {
            mistakes[idx] = merged
        } else {
            mistakes.insert(merged, at: 0)
        }
        try? db.saveMistake(merged)
    }

    public func updateMistakeMastery(id: String, status: MasteryStatus) {
        guard let idx = mistakes.firstIndex(where: { $0.id == id }) else { return }
        mistakes[idx].masteryStatus = status
        try? db.saveMistake(mistakes[idx])
    }

    public func reviewVocabularyItem(id: String, quality: Int) {
        guard let idx = vocabulary.firstIndex(where: { $0.id == id }) else { return }
        let updated = adaptiveEngine.scheduleNextReview(item: vocabulary[idx], quality: quality)
        vocabulary[idx] = updated
        try? db.saveVocabularyItem(updated)
    }

    public func recordGrammarSession(lesson: GrammarLesson, correctCount: Int, totalCount: Int, wrongPrompts: [(String, String, String, String)]) {
        for (prompt, learnerAns, correctAns, explanation) in wrongPrompts {
            logMistake(MistakeEntry(
                sourceModule: "Grammar",
                originalPrompt: prompt,
                learnerAnswer: learnerAns,
                correctAnswer: correctAns,
                explanation: explanation,
                arabicExplanation: lesson.arabicExplanation,
                errorCategory: lesson.title,
                relatedGrammarRule: lesson.title
            ))
        }
        let hasActive = mistakes.contains {
            $0.relatedGrammarRule.caseInsensitiveCompare(lesson.title) == .orderedSame && $0.masteryStatus != .mastered
        }
        let updated = adaptiveEngine.updateGrammarMastery(
            existing: grammarProgress[lesson.id],
            lessonID: lesson.id,
            correctInSession: correctCount,
            totalInSession: totalCount,
            hasActiveMistakesInTopic: hasActive
        )
        grammarProgress[lesson.id] = updated
        try? db.saveGrammarProgress(updated)
    }

    public func saveEssaySubmission(_ essay: EssaySubmission) {
        if let idx = essays.firstIndex(where: { $0.id == essay.id }) {
            essays[idx] = essay
        } else {
            essays.insert(essay, at: 0)
        }
        try? db.saveEssay(essay)
    }

    public func saveAudioRecording(_ record: AudioRecordingRecord) {
        recordings.insert(record, at: 0)
        try? db.saveRecording(record)
    }

    // MARK: - AI Teacher Conversation

    public func sendTeacherPrompt(_ text: String, requestArabic: Bool) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMsg = TeacherMessage(role: "user", content: trimmed)
        teacherMessages.append(userMsg)
        try? db.saveTeacherMessage(userMsg)

        isStreamingTeacher = true
        streamingTeacherDraft = ""
        teacherTask?.cancel()

        let historySnapshot = teacherMessages
        let profileSnapshot = profile
        let mistakesSnapshot = mistakes
        let routingSnapshot = modelRouting
        let fallback = primaryOllamaModel

        teacherTask = Task {
            let reply = await teacherService.askTeacher(
                question: trimmed,
                history: historySnapshot,
                profile: profileSnapshot,
                mistakes: mistakesSnapshot,
                config: routingSnapshot,
                fallbackModel: fallback,
                requestArabic: requestArabic
            ) { token in
                Task { @MainActor [weak self] in
                    self?.streamingTeacherDraft += token
                }
            }
            guard !Task.isCancelled else { return }
            self.teacherMessages.append(reply)
            try? self.db.saveTeacherMessage(reply)
            self.streamingTeacherDraft = ""
            self.isStreamingTeacher = false
        }
    }

    public func cancelTeacherStreaming() {
        teacherTask?.cancel()
        if !streamingTeacherDraft.isEmpty {
            let partial = TeacherMessage(role: "assistant", content: streamingTeacherDraft + "\n[Cancelled]")
            teacherMessages.append(partial)
            try? db.saveTeacherMessage(partial)
        }
        streamingTeacherDraft = ""
        isStreamingTeacher = false
    }

    public func launchMistakeRevisionWithTeacher() {
        let active = mistakes.filter { $0.masteryStatus != .mastered }.prefix(5)
        let summary = active.map { "- [\($0.errorCategory)] Mistake: '\($0.learnerAnswer)' instead of '\($0.correctAnswer)' (\($0.relatedGrammarRule))" }.joined(separator: "\n")
        selectedSection = .aiTeacher
        let prompt = summary.isEmpty
            ? "Create a Band 7.5 diagnostic grammar and academic writing mini-lesson with 3 verification questions."
            : "Create a personalized revision mini-lesson exclusively targeting these mistakes from my Mistake Notebook, explain why each occurred, and test my understanding with 3 new exercises:\n\(summary)"
        sendTeacherPrompt(prompt, requestArabic: profile.shouldShowArabicByDefault)
    }

    public func markDiagnosticQuestionsSeen(_ ids: [String]) {
        seenDiagnosticQuestionIDs.formUnion(ids)
        try? db.upsert(Array(seenDiagnosticQuestionIDs), id: "seen_diag_ids", collection: "adaptive_state")
    }

    public func resetSeenDiagnosticQuestions() {
        seenDiagnosticQuestionIDs = []
        try? db.upsert([String](), id: "seen_diag_ids", collection: "adaptive_state")
    }

    public func teachSpecificWeakness(_ skillCategory: String, domain: String) {
        selectedSection = .aiTeacher
        let prompt = """
        Teach me '\(skillCategory)' (\(domain)) step by step like a personal IELTS Academic teacher aiming for Band \(String(format: "%.1f", profile.targetBand)).
        1. Explain the rule clearly in English with concise Arabic clarification.
        2. Show 2 Band 7.5+ academic examples and 1 common trap to avoid.
        3. Give me 3 short interactive check questions to verify I have mastered it.
        """
        sendTeacherPrompt(prompt, requestArabic: profile.languageMode != .englishImmersion)
    }

    public func addValidatedExam(_ exam: MockExam) -> ContentValidationReport {
        let report = validator.validate(exam: exam)
        if report.passed {
            mockExams.append(exam)
        }
        return report
    }
}
