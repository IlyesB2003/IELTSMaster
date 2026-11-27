import Foundation
import IELTSCore

/// Native ARM64 automated verification runner (runs all IELTSCore test suites
/// directly via `swift run IELTSTestRunner` even without Xcode.app's XCTest.framework).
@main
struct IELTSTestRunner {
    static var passed = 0
    static var failed = 0

    static func expect(_ condition: Bool, _ message: String) {
        if condition {
            passed += 1
        } else {
            failed += 1
            print("FAIL: \(message)")
        }
    }

    static func main() async {
        let start = Date()
        print("=== IELTS Master Automated Verification Suite (macOS ARM64) ===")

        // 1. Official IELTS Scoring & Rounding
        expect(IELTSScoringEngine.roundOfficialBand(6.25) == 6.5, "6.25 rounds up to 6.5")
        expect(IELTSScoringEngine.roundOfficialBand(6.75) == 7.0, "6.75 rounds up to 7.0")
        expect(IELTSScoringEngine.roundOfficialBand(6.125) == 6.0, "6.125 rounds down to 6.0")
        expect(IELTSScoringEngine.roundOfficialBand(6.625) == 6.5, "6.625 rounds down to 6.5")
        expect(IELTSScoringEngine.calculateOverallBand(listening: 6.5, reading: 6.5, writing: 5.0, speaking: 7.0) == 6.5, "Official overall 6.25 -> 6.5")
        expect(IELTSScoringEngine.calculateWritingBand(task1Band: 6.0, task2Band: 7.5) == 7.0, "Task 2 double weight (6.0 + 2*7.5)/3 = 7.0")
        expect(IELTSScoringEngine.listeningBand(forRawScore: 30) == 7.0, "Listening raw 30 -> 7.0")
        expect(IELTSScoringEngine.academicReadingBand(forRawScore: 33) == 7.5, "Reading raw 33 -> 7.5")
        print("[PASS] 1. Official IELTS Scoring, Rounding & Raw Conversion")

        // 2. Objective Grading & Word Limits
        let qTF = ExamQuestion(id: "q1", number: 1, format: .trueFalseNotGiven, prompt: "P", acceptedAnswers: ["NOT GIVEN"], explanation: "E", evidenceQuote: "Q")
        expect(IELTSScoringEngine.isCorrect(response: "ng", for: qTF), "NG shorthand accepted")
        let qLimit = ExamQuestion(id: "q2", number: 2, format: .noteCompletion, prompt: "P", acceptedAnswers: ["north"], maxWordCount: 1, explanation: "E", evidenceQuote: "north")
        expect(IELTSScoringEngine.isCorrect(response: "North", for: qLimit), "Case-insensitive match")
        expect(!IELTSScoringEngine.isCorrect(response: "the north", for: qLimit), "Exceeding maxWordCount rejected")
        print("[PASS] 2. Deterministic Grading & Word-Limit Enforcement")

        // 3. Timer Engine
        let timer = ExamTimerEngine(durationSeconds: 2, allowsPause: false)
        var didExpire = false
        timer.start { didExpire = true }
        timer.pause()
        expect(timer.state == .running, "Pause disabled in strict exam mode")
        _ = timer.tick()
        let done = timer.tick()
        expect(done && timer.state == .finished && didExpire, "Timer expires deterministically")
        print("[PASS] 3. Exam Timer Engine")

        // 4. SQLite3 Database, Migrations, Backup, Restore & Export
        do {
            let tmpDir = FileManager.default.temporaryDirectory.appendingPathComponent("ielts_runner_\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
            defer { try? FileManager.default.removeItem(at: tmpDir) }

            let db = try DatabaseManager(databaseURL: tmpDir.appendingPathComponent("test.sqlite"))
            expect(db.currentSchemaVersion() >= 1, "SQLite migration v1 applied")

            var prof = try db.loadProfile()
            prof.targetBand = 7.5
            try db.saveProfile(prof)
            expect(try db.loadProfile().targetBand == 7.5, "Profile persisted")

            try db.saveAttempt(ExamAttemptRecord(examID: "mock-01", examTitle: "Mock 1", module: "Reading", sessionMode: .examination, durationSeconds: 2100, readingRaw: 33, readingBand: 7.5, overallBand: 7.5))
            expect(try db.loadAttempts().count == 1, "Attempt persisted")

            let backup = tmpDir.appendingPathComponent("backup.sqlite")
            try db.createBackup(to: backup)
            let json = try db.exportAllDataJSON()
            expect(json.count > 100, "JSON export generated (\(json.count) bytes)")

            try db.deleteCollection("exam_attempts")
            expect(try db.loadAttempts().isEmpty, "Selective delete succeeded")
            try db.restoreBackup(from: backup)
            expect(try db.loadAttempts().count == 1, "Backup restore succeeded")
            print("[PASS] 4. SQLite3 Persistence, Migrations, Backup/Restore & JSON Export")
        } catch {
            expect(false, "Database test threw error: \(error)")
        }

        // 5. RAG Knowledge Base & Source Attribution
        let rag = RAGService(documents: OfficialKnowledgeBase.documents)
        let metrics = rag.metrics()
        let hits = rag.search(query: "writing task 2 assessment criteria band descriptors", topK: 3, moduleFilter: "Writing")
        expect(metrics.totalDocuments >= 8 && !hits.isEmpty, "RAG retrieved grounded IELTS criteria")
        expect(hits.first?.citation.contains("https://ielts.org") == true, "RAG includes authoritative citation")
        expect(OfficialKnowledgeBase.sources.allSatisfy { $0.verificationStatus == "Verified" && $0.originalURL.hasPrefix("https://") }, "All sources verified with URLs")
        print("[PASS] 5. Local RAG Hybrid Search & Authoritative Citations")

        // 6. Adaptive Learning Engine (SM-2, Mastery, Recurring Mistakes, Study Plan)
        let adaptive = AdaptiveLearningEngine()
        var v = VocabularyBank.defaultVocabularyItems()[0]
        v = adaptive.scheduleNextReview(item: v, quality: 5)
        expect(v.repetitions == 1 && v.intervalDays == 1, "SM-2 first interval = 1 day")
        v = adaptive.scheduleNextReview(item: v, quality: 4)
        expect(v.repetitions == 2 && v.intervalDays == 6, "SM-2 second interval = 6 days")
        let gp1 = adaptive.updateGrammarMastery(existing: nil, lessonID: "g1", correctInSession: 2, totalInSession: 2, hasActiveMistakesInTopic: false)
        let gp2 = adaptive.updateGrammarMastery(existing: gp1, lessonID: "g1", correctInSession: 2, totalInSession: 2, hasActiveMistakesInTopic: false)
        expect(gp1.status == .reviewing && gp2.status == .mastered, "Mastery requires verified retention")
        let plan = adaptive.generateWeeklyPlan(profile: LearnerProfile(), mistakes: [], grammarProgress: [:], dueVocabCount: 10, sessionMinutes: 60)
        expect(plan.sessions.contains(where: { $0.isBreak }), "60m plan includes scheduled cognitive breaks")
        print("[PASS] 6. Adaptive Learning Engine (SM-2, Mastery & Study Plans)")

        // 7. Mock Exam Bank Quality Assurance (bank-level, cross-exam)
        let exams = MockExamBank.allExams
        let validator = ContentValidator()
        let audit = validator.validateBank(exams)
        expect(!exams.isEmpty, "Mock exam bank is not empty")
        expect(audit.passedCount == exams.count, "All authored exams pass bank validation. Failures: \(audit.reports.filter { !$0.passed }.map { "\($0.examID): \($0.issues)" })")
        expect(Set(exams.map(\.id)).count == exams.count && Set(exams.map(\.title)).count == exams.count, "Exam IDs and titles unique")
        expect(exams.allSatisfy { $0.totalListeningQuestions == 40 && $0.totalReadingQuestions == 40 && !$0.provenance.isOfficialIELTSMaterial && $0.provenance.validationPassed }, "Authored exams: 40+40 questions, non-official, provenance marks validation passed")
        expect(audit.reports.allSatisfy { $0.crossExamDuplicateCount == 0 }, "No authored question stem near-duplicates another authored exam")
        // Regression: the old slot-filled template bank must now FAIL the cross-exam check.
        let legacy = validator.validateBank(MockExamBank.legacyTemplateExams)
        expect(legacy.totalCount == 100 && legacy.passedCount == 0, "Cross-exam validator rejects all 100 legacy template exams (passed: \(legacy.passedCount))")
        expect(ContentValidator.similarity("What is the rule regarding photography in public galleries at the Dublin centre?", "What is the rule regarding photography in public galleries at the Oxford centre?") >= ContentValidator.nearDuplicateThreshold, "Similarity flags stems that differ only by a substituted name")
        print("[PASS] 7. Mock Exam Bank QA (\(audit.passedCount)/\(exams.count) authored exams pass; legacy template bank rejected \(legacy.totalCount - legacy.passedCount)/\(legacy.totalCount))")

        // Shared content must decode in the native runtime, with no mock leakage.
        let shared = SharedContentCatalog.bundled
        expect(shared.mockExams.contains { $0.id == "exam22" }, "Shared native catalog contains the new full mock")
        expect(shared.reading.count >= 200 && shared.listening.count >= 200 && shared.speaking.count >= 200 && shared.writing1.count + shared.writing2.count >= 200,
               "All four native practice banks have at least 200 sessions")
        let sharedMockIDs = Set(shared.mockExams.flatMap { $0.readingPassages.flatMap(\.questions).map(\.id) + $0.listeningParts.flatMap(\.questions).map(\.id) })
        let sharedPracticeIDs = shared.reading.flatMap(\.questions).map(\.id) + shared.listening.flatMap(\.questions).map(\.id)
        expect(sharedMockIDs.isDisjoint(with: sharedPracticeIDs), "Native practice does not expose full mock questions")
        expect(Set(sharedPracticeIDs).count == sharedPracticeIDs.count, "Each native practice question belongs to one focused session")
        print("[PASS] Shared catalog: \(shared.mockExams.count) full mocks, \(shared.listening.count) Listening, \(shared.reading.count) Reading, \(shared.writing1.count + shared.writing2.count) Writing, \(shared.speaking.count) Speaking practice sessions")

        // 7b. Partial practice sets do not produce a band
        let oneExam = exams[0]
        let passageQs = oneExam.readingPassages[0].questions
        let partial = IELTSScoringEngine.gradeObjectiveModule(questions: passageQs, responses: [:], isListening: false)
        expect(partial.bandScore == nil && partial.totalQuestions == passageQs.count, "Partial set returns raw score only, no band")
        let allReading = oneExam.readingPassages.flatMap(\.questions)
        let perfect = Dictionary(uniqueKeysWithValues: allReading.map { ($0.id, $0.acceptedAnswers[0]) })
        let full = IELTSScoringEngine.gradeObjectiveModule(questions: allReading, responses: perfect, isListening: false)
        expect(full.rawScore == 40 && full.bandScore == 9.0, "Full 40-item Reading with first accepted answers scores 40/40 → band 9.0")
        let allListening = oneExam.listeningParts.flatMap(\.questions)
        let lPerfect = Dictionary(uniqueKeysWithValues: allListening.map { q in
            (q.id, q.options.first(where: { opt in q.acceptedAnswers.contains(opt) }) ?? q.acceptedAnswers[0])
        })
        let lFull = IELTSScoringEngine.gradeObjectiveModule(questions: allListening, responses: lPerfect, isListening: true)
        expect(lFull.rawScore == 40, "Listening answer keys accept the option text the UI submits (40/40)")
        print("[PASS] 7b. Partial-set banding withheld; answer keys self-consistent")

        // 8. Structured JSON Parsing & 16 GB M4 Routing
        struct Dummy: Decodable { let band: Double }
        let parsed = try? LocalLLMService.decodeStructuredJSON(Dummy.self, from: "```json\n{\"band\": 7.5}\n```")
        expect(parsed?.band == 7.5, "Structured JSON fenced extraction works")
        let llm = LocalLLMService()
        let rec = llm.recommendModel(for: .arabicExplanation, from: [
            LocalModelInfo(id: "qwen2.5:7b", name: "qwen2.5:7b", family: "Qwen", sizeBytes: 4_700_000_000, estimatedRAMGB: 5.5),
            LocalModelInfo(id: "llama3.1:70b", name: "llama3.1:70b", family: "Llama", sizeBytes: 40_000_000_000, estimatedRAMGB: 44.0)
        ])
        expect(rec?.name == "qwen2.5:7b", "16 GB M4 router selects comfortable 7B model over 70B")
        print("[PASS] 8. AI JSON Schema Validation & 16 GB Apple Silicon Routing")

        // 9. Offline Writing & Speaking Assessment Safety
        let assess = AssessmentService(llm: llm, rag: rag)
        let wRes = await assess.evaluateWriting(
            taskNumber: 2, promptText: "Prompt",
            essayText: "Each of the samples are tested despite of limited informations. Sustainable agriculture improves resilience.",
            profile: LearnerProfile(), config: ModelRoutingConfiguration(), fallbackModel: "", includeArabic: true
        )
        expect(wRes.sentenceCorrections.count >= 1 && wRes.arabicSummary != nil, "Offline writing analyzer detects errors & returns Arabic summary")
        let sRes = assess.evaluateSpeaking(transcript: "In my view sustainable pasture management protects soil carbon.", durationSeconds: 10, pauseRatio: 0.1, audioQualityOK: true)
        expect(sRes.pronunciationBand == nil && sRes.pronunciationLimitationNote.contains("Non-native accents are never penalized"), "Speaking evaluator avoids text-only pronunciation scoring")
        print("[PASS] 9. Offline Writing & Speaking Evaluation Safety")

        // 10. Non-Repeating Adaptive Question Bank & Weakness Diagnosis
        var seen: Set<String> = []
        let draw1 = AdaptiveQuestionBank.drawFreshSet(excluding: seen)
        seen.formUnion(draw1.items.map(\.id))
        let draw2 = AdaptiveQuestionBank.drawFreshSet(excluding: seen)
        let overlap = Set(draw1.items.map(\.id)).intersection(Set(draw2.items.map(\.id)))
        expect(draw1.items.count == 10 && draw2.items.count == 10 && overlap.isEmpty, "Consecutive adaptive tests have ZERO repeated questions")
        let weakRep = AdaptiveQuestionBank.analyzeWeaknesses(items: draw1.items, selectedAnswers: [:])
        expect(!weakRep.isEmpty && weakRep.first?.accuracy == 0.0, "Weakness analyzer identifies 0% skills first")
        print("[PASS] 10. Non-Repeating Adaptive Test Bank & Weakness Diagnosis")

        // 12. Skill tracking, non-repeating practice picker, lessons, generator validation
        let now = Date()
        let oldWrong = (0..<4).map { i in SkillEvent(skillTag: "tfng", module: "Reading", itemID: "o\(i)", correct: false, date: now.addingTimeInterval(-60 * 86_400)) }
        let recentRight = (0..<4).map { i in SkillEvent(skillTag: "tfng", module: "Reading", itemID: "r\(i)", correct: true, date: now) }
        let tfngMastery = SkillAnalyzer.mastery(from: oldWrong + recentRight, now: now).first
        expect((tfngMastery?.weightedAccuracy ?? 0) > 0.8, "Recent correct answers outweigh old wrong ones (recency weighting)")
        let weakEvents = (0..<5).map { i in SkillEvent(skillTag: "matching_headings", module: "Reading", itemID: "h\(i)", correct: i == 0, date: now) }
        expect(SkillAnalyzer.weaknesses(from: weakEvents + recentRight, now: now).first?.skillTag == "matching_headings", "Weakest skill identified from real answers")
        expect(SkillAnalyzer.weaknesses(from: Array(weakEvents.prefix(2)), now: now).isEmpty, "No weakness reported from too little evidence")

        let units = PracticeSetBuilder.readingUnits(from: exams)
        var exposure = ExposureState()
        var served: [String] = []
        for _ in 0..<units.count {
            guard let pick = PracticeSetBuilder.next(from: units, exposure: exposure, weakSkills: ["matching_headings"]) else { break }
            expect(!pick.isRepeat, "Practice set \(served.count + 1) is new")
            served.append(pick.unit.id)
            exposure.markUnitSeen(pick.unit.id, at: now.addingTimeInterval(Double(served.count)))
        }
        expect(Set(served).count == units.count, "Every Reading passage is served once before any repeats (\(served.count)/\(units.count))")
        let afterAll = PracticeSetBuilder.next(from: units, exposure: exposure, weakSkills: [])
        expect(afterAll?.isRepeat == true && afterAll?.unit.id == served.first, "After all are seen, the oldest comes back and is flagged as a repeat")
        let firstPick = PracticeSetBuilder.next(from: units, exposure: ExposureState(), weakSkills: ["matching_headings"])
        expect(firstPick?.unit.skillTags.contains("matching_headings") == true, "Weak skills are targeted first")
        var mockExposure = ExposureState()
        mockExposure.markExamAttempted(exams[0].id)
        let recMock = PracticeSetBuilder.nextMockExam(from: exams, exposure: mockExposure)
        expect(exams.count < 2 || (recMock?.exam.id != exams[0].id && recMock?.isRetake == false), "Recommended mock is one not yet taken")

        let authoredTags = Set(exams.flatMap { $0.listeningParts.flatMap(\.questions) + $0.readingPassages.flatMap(\.questions) }.map(\.skillTag))
        let missingLessons = authoredTags.filter { StrategyLessons.lesson(for: $0) == nil }
        expect(missingLessons.isEmpty, "Every skill in the exam bank has a lesson (missing: \(missingLessons.sorted()))")
        expect(StrategyLessons.all.allSatisfy { !$0.steps.isEmpty && !$0.arabicSummary.isEmpty }, "Every lesson has a method and an Arabic summary")

        let badDraft = PracticeGenerator.Draft(
            title: "Test", discipline: "Test",
            paragraphs: ["Too short a passage about bees."],
            questions: [PracticeGenerator.Draft.Item(type: "tfng", prompt: "Bees can fly.", options: [], answer: "MAYBE", evidence: "not in the passage at all", explanation: "x")]
        )
        let badIssues = PracticeGenerator.validate(badDraft, existingQuestions: [])
        expect(badIssues.contains { $0.contains("too short") } && badIssues.contains { $0.contains("evidence") } && badIssues.contains { $0.contains("invalid") },
               "Generator validation rejects short passages, invented evidence and invalid answers")
        print("[PASS] 12. Skill tracking, non-repeating practice, lessons, generator validation")

        // 11. Performance Benchmark (50 RAG Queries)
        let perfStart = Date()
        for _ in 0..<50 {
            _ = rag.search(query: "ielts academic reading true false not given distractors", topK: 3)
        }
        let ragMs = Date().timeIntervalSince(perfStart) * 1000.0
        expect(ragMs < 2000.0, "50 RAG queries completed in \(String(format: "%.1f", ragMs)) ms")
        print("[PASS] 10. Performance Benchmark (50 RAG queries: \(String(format: "%.1f", ragMs)) ms)")

        let totalMs = Date().timeIntervalSince(start) * 1000.0
        print("=== Summary: \(passed) assertions passed, \(failed) failed in \(String(format: "%.1f", totalMs)) ms ===")
        if failed > 0 {
            exit(1)
        }
    }
}
