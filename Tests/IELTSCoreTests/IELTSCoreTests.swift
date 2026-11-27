import XCTest
@testable import IELTSCore

final class IELTSCoreTests: XCTestCase {

    // MARK: - 1. Official IELTS Scoring & Rounding Fixtures

    func testOfficialBandRoundingRules() {
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(6.25), 6.5)
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(6.75), 7.0)
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(6.125), 6.0)
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(6.625), 6.5)
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(7.375), 7.5)
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(8.875), 9.0)
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(9.5), 9.0)
        XCTAssertEqual(IELTSScoringEngine.roundOfficialBand(-1.0), 0.0)
    }

    func testOverallAndWritingWeightedCalculations() {
        // Official example: (6.5 + 6.5 + 5.0 + 7.0) / 4 = 6.25 -> 6.5
        XCTAssertEqual(
            IELTSScoringEngine.calculateOverallBand(listening: 6.5, reading: 6.5, writing: 5.0, speaking: 7.0),
            6.5
        )
        // Official example: (6.5 + 6.5 + 5.5 + 6.0) / 4 = 6.125 -> 6.0
        XCTAssertEqual(
            IELTSScoringEngine.calculateOverallBand(listening: 6.5, reading: 6.5, writing: 5.5, speaking: 6.0),
            6.0
        )
        // Writing Task 2 carries double weight: (6.0 + 2 * 7.5) / 3 = 7.0
        XCTAssertEqual(IELTSScoringEngine.calculateWritingBand(task1Band: 6.0, task2Band: 7.5), 7.0)
        // (7.5 + 2 * 6.0) / 3 = 6.5
        XCTAssertEqual(IELTSScoringEngine.calculateWritingBand(task1Band: 7.5, task2Band: 6.0), 6.5)
    }

    func testRawScoreConversionTables() {
        XCTAssertEqual(IELTSScoringEngine.listeningBand(forRawScore: 40), 9.0)
        XCTAssertEqual(IELTSScoringEngine.listeningBand(forRawScore: 30), 7.0)
        XCTAssertEqual(IELTSScoringEngine.listeningBand(forRawScore: 23), 6.0)
        XCTAssertEqual(IELTSScoringEngine.listeningBand(forRawScore: 0), 0.0)

        XCTAssertEqual(IELTSScoringEngine.academicReadingBand(forRawScore: 39), 9.0)
        XCTAssertEqual(IELTSScoringEngine.academicReadingBand(forRawScore: 33), 7.5)
        XCTAssertEqual(IELTSScoringEngine.academicReadingBand(forRawScore: 30), 7.0)
        XCTAssertEqual(IELTSScoringEngine.academicReadingBand(forRawScore: 15), 5.0)
    }

    func testDeterministicAnswerGradingAndWordLimits() {
        let q1 = ExamQuestion(
            id: "q1", number: 1, format: .trueFalseNotGiven,
            prompt: "Test", acceptedAnswers: ["NOT GIVEN"],
            explanation: "E", evidenceQuote: "Q"
        )
        XCTAssertTrue(IELTSScoringEngine.isCorrect(response: "ng", for: q1))
        XCTAssertTrue(IELTSScoringEngine.isCorrect(response: "  Not Given. ", for: q1))
        XCTAssertFalse(IELTSScoringEngine.isCorrect(response: "TRUE", for: q1))

        let q2 = ExamQuestion(
            id: "q2", number: 2, format: .noteCompletion,
            prompt: "Test", acceptedAnswers: ["north"], maxWordCount: 1,
            explanation: "E", evidenceQuote: "north"
        )
        XCTAssertTrue(IELTSScoringEngine.isCorrect(response: "North", for: q2))
        XCTAssertFalse(IELTSScoringEngine.isCorrect(response: "the north", for: q2))
    }

    // MARK: - 2. Timer Engine Tests

    func testExamTimerDeterministicTickAndExpiry() {
        let timer = ExamTimerEngine(durationSeconds: 3, allowsPause: false)
        var expired = false
        timer.start { expired = true }
        XCTAssertEqual(timer.state, .running)

        // Pause should be ignored when allowsPause == false (strict exam mode)
        timer.pause()
        XCTAssertEqual(timer.state, .running)

        XCTAssertFalse(timer.tick())
        XCTAssertEqual(timer.remainingSeconds, 2)
        XCTAssertFalse(timer.tick())
        XCTAssertEqual(timer.remainingSeconds, 1)
        XCTAssertTrue(timer.tick())
        XCTAssertEqual(timer.remainingSeconds, 0)
        XCTAssertEqual(timer.state, .finished)
        XCTAssertTrue(expired)
    }

    // MARK: - 3. SQLite3 Database, Migrations, Backup, Restore & Export Tests

    func testDatabasePersistenceBackupAndExport() throws {
        let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("ielts_test_\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmpDir) }

        let dbURL = tmpDir.appendingPathComponent("test.sqlite")
        let db = try DatabaseManager(databaseURL: dbURL)
        XCTAssertGreaterThanOrEqual(db.currentSchemaVersion(), 1)

        var profile = try db.loadProfile()
        profile.targetBand = 7.5
        profile.displayName = "Researcher"
        try db.saveProfile(profile)

        let reloaded = try db.loadProfile()
        XCTAssertEqual(reloaded.targetBand, 7.5)
        XCTAssertEqual(reloaded.displayName, "Researcher")

        let attempt = ExamAttemptRecord(
            examID: "mock-01", examTitle: "Mock 1", module: "Reading",
            sessionMode: .examination, durationSeconds: 2400,
            readingRaw: 33, readingBand: 7.5, overallBand: 7.5
        )
        try db.saveAttempt(attempt)
        XCTAssertEqual(try db.loadAttempts().count, 1)

        // Backup & Export
        let backupURL = tmpDir.appendingPathComponent("backup.sqlite")
        try db.createBackup(to: backupURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: backupURL.path))

        let jsonData = try db.exportAllDataJSON()
        XCTAssertGreaterThan(jsonData.count, 100)

        // Delete & Restore
        try db.deleteCollection("exam_attempts")
        XCTAssertEqual(try db.loadAttempts().count, 0)
        try db.restoreBackup(from: backupURL)
        XCTAssertEqual(try db.loadAttempts().count, 1)
    }

    // MARK: - 4. RAG Retrieval & Knowledge Attribution Tests

    func testRAGSearchAndCitations() {
        let rag = RAGService(documents: OfficialKnowledgeBase.documents)
        let metrics = rag.metrics()
        XCTAssertGreaterThanOrEqual(metrics.totalDocuments, 8)
        XCTAssertGreaterThanOrEqual(metrics.totalChunks, 8)

        let hits = rag.search(query: "writing task 2 weighting assessment criteria", topK: 3, moduleFilter: "Writing")
        XCTAssertFalse(hits.isEmpty)
        XCTAssertTrue(hits.first?.citation.contains("https://ielts.org") ?? false)

        // Verify all sources carry required attribution metadata
        for src in OfficialKnowledgeBase.sources {
            XCTAssertFalse(src.sourceName.isEmpty)
            XCTAssertTrue(src.originalURL.hasPrefix("https://"))
            XCTAssertFalse(src.copyrightAndLicense.isEmpty)
            XCTAssertEqual(src.verificationStatus, "Verified")
        }
    }

    // MARK: - 5. Adaptive Learning Engine (SM-2, Mastery, Recurring Errors, Study Plan)

    func testAdaptiveSM2AndMasteryAndStudyPlan() {
        let engine = AdaptiveLearningEngine()
        var item = VocabularyBank.defaultVocabularyItems()[0]

        item = engine.scheduleNextReview(item: item, quality: 5)
        XCTAssertEqual(item.repetitions, 1)
        XCTAssertEqual(item.intervalDays, 1)

        item = engine.scheduleNextReview(item: item, quality: 4)
        XCTAssertEqual(item.repetitions, 2)
        XCTAssertEqual(item.intervalDays, 6)

        item = engine.scheduleNextReview(item: item, quality: 1)
        XCTAssertEqual(item.repetitions, 0)
        XCTAssertEqual(item.intervalDays, 1)

        // Grammar mastery requires >= 2 sessions at >= 85% and no active mistakes
        let p1 = engine.updateGrammarMastery(existing: nil, lessonID: "g1", correctInSession: 2, totalInSession: 2, hasActiveMistakesInTopic: false)
        XCTAssertEqual(p1.status, .reviewing)
        let p2 = engine.updateGrammarMastery(existing: p1, lessonID: "g1", correctInSession: 2, totalInSession: 2, hasActiveMistakesInTopic: false)
        XCTAssertEqual(p2.status, .mastered)

        // Recurring mistake detection
        let m1 = MistakeEntry(sourceModule: "Grammar", originalPrompt: "P1", learnerAnswer: "were", correctAnswer: "was", explanation: "E", errorCategory: "Subject-Verb Agreement", relatedGrammarRule: "Each of the")
        let m2 = MistakeEntry(sourceModule: "Writing", originalPrompt: "P2", learnerAnswer: "are", correctAnswer: "is", explanation: "E", errorCategory: "Subject-Verb Agreement", relatedGrammarRule: "Each of the")
        let merged = engine.recordMistake(m2, existing: [m1])
        XCTAssertEqual(merged.recurrenceCount, 2)
        XCTAssertTrue(merged.isRecurringPattern)

        // Weekly plan with breaks for 60m sessions
        let plan = engine.generateWeeklyPlan(profile: LearnerProfile(), mistakes: [merged], grammarProgress: [:], dueVocabCount: 12, sessionMinutes: 60)
        XCTAssertEqual(plan.sessionDurationMinutes, 60)
        XCTAssertTrue(plan.sessions.contains(where: { $0.isBreak }))
    }

    // MARK: - 6. Mock Exam Bank QA Validation (cross-exam)

    func testAuthoredMockExamsPassBankValidation() {
        let exams = MockExamBank.allExams
        XCTAssertFalse(exams.isEmpty)
        let audit = ContentValidator().validateBank(exams)
        XCTAssertEqual(audit.passedCount, exams.count, "Failed exams: \(audit.reports.filter { !$0.passed }.map { "\($0.examID): \($0.issues)" })")
        XCTAssertEqual(Set(exams.map(\.title)).count, exams.count)
        for exam in exams {
            XCTAssertEqual(exam.totalListeningQuestions, 40)
            XCTAssertEqual(exam.totalReadingQuestions, 40)
            XCTAssertFalse(exam.provenance.isOfficialIELTSMaterial)
        }
    }

    func testLegacyTemplateBankIsRejectedByCrossExamCheck() {
        let legacy = ContentValidator().validateBank(MockExamBank.legacyTemplateExams)
        XCTAssertEqual(legacy.totalCount, 30)
        XCTAssertEqual(legacy.passedCount, 0)
    }

    func testPartialSetReturnsNoBand() {
        let qs = MockExamBank.allExams[0].readingPassages[0].questions
        let graded = IELTSScoringEngine.gradeObjectiveModule(questions: qs, responses: [:], isListening: false)
        XCTAssertNil(graded.bandScore)
        XCTAssertEqual(graded.totalQuestions, qs.count)
    }

    // MARK: - 7. AI Structured JSON Parsing & 16 GB Model Routing

    func testStructuredJSONExtractionAnd16GBRouting() throws {
        struct DummyScore: Decodable { let band: Double; let note: String }
        let fenced = """
        Here is the assessment:
        ```json
        {"band": 7.5, "note": "Clear cohesion"}
        ```
        """
        let decoded = try LocalLLMService.decodeStructuredJSON(DummyScore.self, from: fenced)
        XCTAssertEqual(decoded.band, 7.5)
        XCTAssertEqual(decoded.note, "Clear cohesion")

        XCTAssertThrowsError(try LocalLLMService.decodeStructuredJSON(DummyScore.self, from: "not json at all"))

        let llm = LocalLLMService()
        let models = [
            LocalModelInfo(id: "qwen2.5:7b", name: "qwen2.5:7b", family: "Qwen", sizeBytes: 4_700_000_000, estimatedRAMGB: 5.5),
            LocalModelInfo(id: "llama3.1:70b", name: "llama3.1:70b", family: "Llama", sizeBytes: 40_000_000_000, estimatedRAMGB: 44.0)
        ]
        let best = llm.recommendModel(for: .arabicExplanation, from: models)
        XCTAssertEqual(best?.name, "qwen2.5:7b")
    }

    // MARK: - 8. Offline Writing & Speaking Assessment Safety

    func testOfflineAssessmentSafetyAndPronunciationDisclaimer() async {
        let service = AssessmentService(llm: LocalLLMService(), rag: RAGService())
        let essay = "Each of the samples are tested despite of limited informations. However, sustainable agriculture demonstrates significant benefits for rural communities and environmental resilience over the long term."
        let writingResult = await service.evaluateWriting(
            taskNumber: 2,
            promptText: "Discuss sustainable agriculture.",
            essayText: essay,
            profile: LearnerProfile(),
            config: ModelRoutingConfiguration(),
            fallbackModel: "",
            includeArabic: true
        )
        XCTAssertGreaterThanOrEqual(writingResult.sentenceCorrections.count, 1)
        XCTAssertNotNil(writingResult.arabicSummary)
        XCTAssertTrue(writingResult.disclaimer.lowercased().contains("not an official"))

        let speakingResult = service.evaluateSpeaking(
            transcript: "In my view, sustainable pasture management is essential because it protects soil carbon while supporting farm income across Ireland.",
            durationSeconds: 12.0,
            pauseRatio: 0.12,
            audioQualityOK: true
        )
        XCTAssertNil(speakingResult.pronunciationBand)
        XCTAssertTrue(speakingResult.pronunciationLimitationNote.lowercased().contains("non-native accents are never penalized"))
    }

    // MARK: - 9. Performance Check

    func testRAGAndBankValidationPerformance() {
        let rag = RAGService(documents: OfficialKnowledgeBase.documents)
        measure {
            for _ in 0..<50 {
                _ = rag.search(query: "ielts academic reading true false not given distractors", topK: 3)
            }
        }
    }
}
