import Foundation

/// Rubric-based Writing and Speaking evaluation service.
/// Always performs deterministic linguistic/acoustic pre-analysis first,
/// optionally enhances with local LLM structured JSON rubric evaluation,
/// and clearly states uncertainty and non-official status.
public final class AssessmentService: @unchecked Sendable {
    private let llm: LocalLLMService
    private let rag: RAGService

    public init(llm: LocalLLMService, rag: RAGService) {
        self.llm = llm
        self.rag = rag
    }

    // MARK: - Academic Writing Evaluation

    public func evaluateWriting(
        taskNumber: Int,
        promptText: String,
        essayText: String,
        profile: LearnerProfile,
        config: ModelRoutingConfiguration,
        fallbackModel: String,
        includeArabic: Bool
    ) async -> WritingEvaluationResult {
        let wordCount = IELTSScoringEngine.countWords(in: essayText)
        let minWords = taskNumber == 1 ? 150 : 250
        let meetsWordCount = wordCount >= minWords

        // Deterministic pre-analysis
        let repeatedWords = detectRepeatedContentWords(in: essayText)
        let paragraphs = essayText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let deterministicCorrections = detectCommonGrammarIssues(in: essayText)

        // Attempt LLM rubric pass if a model is available
        let activeModel = config.model(for: .writingEvaluator, fallback: fallbackModel)
        if !activeModel.isEmpty || (config.activeProvider.isExternal && profile.externalAIConsentGranted) {
            let (ragContext, _) = rag.buildGroundedContext(for: "IELTS writing task \(taskNumber) assessment criteria band descriptors", module: "Writing", topK: 2)
            struct LLMWritingSchema: Decodable {
                let taskAchievementBand: Double
                let coherenceCohesionBand: Double
                let lexicalResourceBand: Double
                let grammaticalRangeBand: Double
                let summaryFeedback: String
                let paragraphAnalysis: String
                let argumentAnalysis: String
                let vocabularyUpgrades: [String]
                let targetedExercises: [String]
                let arabicSummary: String?
            }

            let system = """
            You are an IELTS Academic Writing rubric evaluator. Use ONLY the public IELTS Writing assessment criteria.
            Never claim official examiner status. Evaluate Task \(taskNumber) (minimum \(minWords) words, actual \(wordCount) words).
            \(ragContext)
            Return JSON with keys: taskAchievementBand (0-9 in 0.5 steps), coherenceCohesionBand, lexicalResourceBand, grammaticalRangeBand, summaryFeedback, paragraphAnalysis, argumentAnalysis, vocabularyUpgrades (array of strings), targetedExercises (array of strings), arabicSummary (\(includeArabic ? "concise Arabic summary" : "null")).
            """

            let user = "Prompt:\n\(promptText)\n\nCandidate Response (\(wordCount) words):\n\(essayText)"

            if let parsed = try? await llm.requestStructuredJSON(
                LLMWritingSchema.self,
                config: config,
                role: .writingEvaluator,
                fallbackModel: fallbackModel,
                systemPrompt: system,
                userPrompt: user,
                externalConsentGranted: profile.externalAIConsentGranted,
                maxRetries: 1
            ) {
                let ta = IELTSScoringEngine.roundOfficialBand(parsed.taskAchievementBand)
                let cc = IELTSScoringEngine.roundOfficialBand(parsed.coherenceCohesionBand)
                let lr = IELTSScoringEngine.roundOfficialBand(parsed.lexicalResourceBand)
                let gra = IELTSScoringEngine.roundOfficialBand(parsed.grammaticalRangeBand)
                let overall = IELTSScoringEngine.calculateFourCriterionBand(c1: ta, c2: cc, c3: lr, c4: gra)
                return WritingEvaluationResult(
                    taskNumber: taskNumber,
                    taskAchievementBand: ta,
                    coherenceCohesionBand: cc,
                    lexicalResourceBand: lr,
                    grammaticalRangeBand: gra,
                    overallTaskBand: overall,
                    wordCount: wordCount,
                    meetsWordCount: meetsWordCount,
                    confidence: wordCount >= minWords ? .moderate : .low,
                    summaryFeedback: parsed.summaryFeedback,
                    paragraphAnalysis: parsed.paragraphAnalysis,
                    argumentAnalysis: parsed.argumentAnalysis,
                    repeatedWords: repeatedWords,
                    sentenceCorrections: deterministicCorrections,
                    vocabularyUpgrades: parsed.vocabularyUpgrades,
                    targetedExercises: parsed.targetedExercises,
                    arabicSummary: includeArabic ? parsed.arabicSummary : nil
                )
            }
        }

        // Deterministic offline rubric estimation when no LLM is connected
        return deterministicWritingEvaluation(
            taskNumber: taskNumber,
            essayText: essayText,
            wordCount: wordCount,
            minWords: minWords,
            paragraphs: paragraphs,
            repeatedWords: repeatedWords,
            corrections: deterministicCorrections,
            includeArabic: includeArabic
        )
    }

    private func deterministicWritingEvaluation(
        taskNumber: Int,
        essayText: String,
        wordCount: Int,
        minWords: Int,
        paragraphs: [String],
        repeatedWords: [String],
        corrections: [SentenceCorrection],
        includeArabic: Bool
    ) -> WritingEvaluationResult {
        let lower = essayText.lowercased()
        let tokens = lower.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { $0.count >= 2 }
        let uniqueRatio = tokens.isEmpty ? 0.0 : Double(Set(tokens).count) / Double(tokens.count)

        let cohesiveMarkers = ["however", "moreover", "furthermore", "consequently", "nevertheless", "in contrast", "whereas", "although", "overall", "in addition", "therefore"]
        let cohesionHits = cohesiveMarkers.filter { lower.contains($0) }.count

        let academicWords = ["significant", "proportion", "fluctuated", "substantially", "evidence", "sustainable", "agricultural", "policy", "demonstrates", "consequently", "mitigate", "allocate", "productivity", "empirical"]
        let academicHits = academicWords.filter { lower.contains($0) }.count

        // Conservative deterministic bands (explicitly marked Low confidence offline)
        var ta = wordCount >= minWords ? 6.0 : (wordCount >= minWords / 2 ? 5.0 : 4.0)
        if paragraphs.count >= (taskNumber == 1 ? 3 : 4) && wordCount >= minWords { ta += 0.5 }

        var cc = 5.5
        if paragraphs.count >= 3 { cc += 0.5 }
        if cohesionHits >= 3 { cc += 0.5 }

        var lr = 5.5
        if uniqueRatio >= 0.52 && wordCount >= minWords { lr += 0.5 }
        if academicHits >= 3 { lr += 0.5 }
        if repeatedWords.count >= 4 { lr -= 0.5 }

        var gra = 6.0
        if corrections.count >= 3 { gra -= 0.5 }
        if lower.contains("although") || lower.contains("whereas") || lower.contains("which") { gra += 0.5 }

        ta = IELTSScoringEngine.roundOfficialBand(ta)
        cc = IELTSScoringEngine.roundOfficialBand(cc)
        lr = IELTSScoringEngine.roundOfficialBand(lr)
        gra = IELTSScoringEngine.roundOfficialBand(gra)
        let overall = IELTSScoringEngine.calculateFourCriterionBand(c1: ta, c2: cc, c3: lr, c4: gra)

        let summary = "Offline structural analysis completed (\(wordCount) words, \(paragraphs.count) paragraph(s)). Connect a local Ollama model in AI Model Manager for deep semantic rubric commentary."
        let paragraphNote = paragraphs.count >= (taskNumber == 1 ? 3 : 4)
            ? "Paragraphing structure (\(paragraphs.count) paragraphs) supports clear progression."
            : "Add clear paragraph breaks: introduction, overview/main body paragraphs, and conclusion."
        let argumentNote = taskNumber == 1
            ? "Ensure a dedicated overview paragraph summarizing the main trends without listing every number."
            : "Verify that every body paragraph begins with a clear topic sentence supported by concrete academic evidence."

        let arabic: String? = includeArabic
            ? "تم إجراء تحليل هيكلي محلي (\(wordCount) كلمة في \(paragraphs.count) فقرات). التقدير المبدئي هو \(String(format: "%.1f", overall)) وهو تقدير إرشادي وليس درجة IELTS رسمية. ركّز على تقليل تكرار الكلمات واستخدام جمل مركّبة دقيقة."
            : nil

        return WritingEvaluationResult(
            taskNumber: taskNumber,
            taskAchievementBand: ta,
            coherenceCohesionBand: cc,
            lexicalResourceBand: lr,
            grammaticalRangeBand: gra,
            overallTaskBand: overall,
            wordCount: wordCount,
            meetsWordCount: wordCount >= minWords,
            confidence: .low,
            summaryFeedback: summary,
            paragraphAnalysis: paragraphNote,
            argumentAnalysis: argumentNote,
            repeatedWords: repeatedWords,
            sentenceCorrections: corrections,
            vocabularyUpgrades: [
                "Replace 'very big' with 'substantial' or 'considerable'.",
                "Replace 'a lot of' with 'a significant proportion of' or 'numerous'.",
                "Replace 'good/bad' with 'beneficial/detrimental' in academic prose."
            ],
            targetedExercises: [
                "Rewrite two simple sentences using concessive clauses ('Although...', 'Whereas...').",
                "Replace repeated nouns with precise academic synonyms or pronoun reference."
            ],
            arabicSummary: arabic
        )
    }

    // MARK: - Speaking Evaluation (Acoustic + Transcript)

    public func evaluateSpeaking(
        transcript: String,
        durationSeconds: Double,
        pauseRatio: Double,
        audioQualityOK: Bool
    ) -> SpeakingEvaluationResult {
        let words = transcript.split { $0.isWhitespace || $0.isNewline }.map(String.init)
        let wordCount = words.count
        let minutes = max(durationSeconds / 60.0, 0.05)
        let wpm = Double(wordCount) / minutes

        let lowerWords = words.map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }.filter { !$0.isEmpty }
        let uniqueRatio = lowerWords.isEmpty ? 0.0 : Double(Set(lowerWords).count) / Double(lowerWords.count)

        let fillerSet = ["um", "uh", "erm", "like", "basically", "actually"]
        let detectedFillers = lowerWords.filter { fillerSet.contains($0) }

        let metrics = SpeakingAcousticMetrics(
            durationSeconds: durationSeconds,
            wordCount: wordCount,
            wordsPerMinute: (wpm * 10).rounded() / 10,
            pauseRatio: (pauseRatio * 100).rounded() / 100,
            fillerWordCount: detectedFillers.count,
            detectedFillers: Array(Set(detectedFillers)),
            uniqueWordRatio: (uniqueRatio * 100).rounded() / 100,
            audioQualityOK: audioQualityOK
        )

        var fc = 5.5
        if wpm >= 110 && wpm <= 165 && pauseRatio < 0.30 { fc += 1.0 }
        else if wpm >= 90 { fc += 0.5 }
        if detectedFillers.count > 6 { fc -= 0.5 }

        var lr = 5.5
        if uniqueRatio >= 0.55 && wordCount >= 60 { lr += 1.0 }
        else if uniqueRatio >= 0.45 { lr += 0.5 }

        var gra = 5.5
        let lower = transcript.lowercased()
        if lower.contains("because") || lower.contains("although") || lower.contains("which") || lower.contains("if") {
            gra += 0.5
        }
        if wordCount >= 90 { gra += 0.5 }

        fc = IELTSScoringEngine.roundOfficialBand(fc)
        lr = IELTSScoringEngine.roundOfficialBand(lr)
        gra = IELTSScoringEngine.roundOfficialBand(gra)

        // Pronunciation cannot be accurately scored from text transcription alone!
        let pronunciationBand: Double? = nil
        let pronConfidence: AssessmentConfidence = audioQualityOK ? .low : .unavailable
        let pronNote = "Pronunciation band is not scored from text transcription alone. Acoustic timing and pause ratio were measured from your audio, while segmental/intonation scoring requires dedicated phoneme-level alignment or human/examiner review. Non-native accents are never penalized."

        let overall = IELTSScoringEngine.roundOfficialBand((fc + lr + gra) / 3.0)

        var strengths: [String] = []
        var improvements: [String] = []
        if wpm >= 105 && wpm <= 165 {
            strengths.append("Natural academic speech rate (\(Int(wpm)) WPM).")
        } else {
            improvements.append("Aim for a steady speech rate between 110 and 155 WPM (measured \(Int(wpm)) WPM).")
        }
        if pauseRatio < 0.28 {
            strengths.append("Low excessive hesitation ratio (\(Int(pauseRatio * 100))% silence).")
        } else {
            improvements.append("Reduce long hesitations by using natural discourse planning phrases.")
        }
        if uniqueRatio >= 0.50 {
            strengths.append("Good lexical diversity across your response.")
        } else {
            improvements.append("Broaden vocabulary range and paraphrase key ideas rather than repeating words.")
        }

        return SpeakingEvaluationResult(
            fluencyCoherenceBand: fc,
            lexicalResourceBand: lr,
            grammaticalRangeBand: gra,
            pronunciationBand: pronunciationBand,
            overallSpeakingBand: overall,
            pronunciationConfidence: pronConfidence,
            pronunciationLimitationNote: pronNote,
            acousticMetrics: metrics,
            strengths: strengths,
            improvements: improvements,
            grammarNotes: ["Use a mix of present/past tenses, relative clauses, and conditionals in Part 3 abstract answers."],
            vocabularySuggestions: ["Incorporate precise collocations such as 'sustainable practice', 'empirical evidence', and 'long-term impact'."]
        )
    }

    // MARK: - Deterministic Linguistic Helpers

    public func detectRepeatedContentWords(in text: String) -> [String] {
        let stop: Set<String> = ["the", "and", "that", "this", "with", "from", "have", "were", "been", "their", "there", "which", "about", "would", "could", "should", "these", "those", "also", "more", "most", "some", "into", "over", "than"]
        let words = text.lowercased()
            .components(separatedBy: CharacterSet.letters.inverted)
            .filter { $0.count >= 5 && !stop.contains($0) }
        var counts: [String: Int] = [:]
        for w in words { counts[w, default: 0] += 1 }
        return counts.filter { $0.value >= 4 }
            .sorted { $0.value > $1.value }
            .prefix(8)
            .map { "\($0.key) (\($0.value)x)" }
    }

    public func detectCommonGrammarIssues(in text: String) -> [SentenceCorrection] {
        var issues: [SentenceCorrection] = []
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for sentence in sentences {
            let lower = sentence.lowercased()
            if lower.contains("each of the") && lower.contains(" are ") {
                issues.append(SentenceCorrection(
                    originalSentence: sentence,
                    correctedSentence: sentence.replacingOccurrences(of: " are ", with: " is "),
                    errorType: "Subject-Verb Agreement",
                    explanation: "'Each of the + plural noun' takes a singular verb ('is' / 'was').",
                    arabicExplanation: "عبارة 'each of the' يتبعها دائماً فعل مفرد حتى لو كان الاسم بعدها جمعاً."
                ))
            }
            if lower.contains("informations") || lower.contains("researches") || lower.contains("equipments") {
                issues.append(SentenceCorrection(
                    originalSentence: sentence,
                    correctedSentence: sentence
                        .replacingOccurrences(of: "informations", with: "information")
                        .replacingOccurrences(of: "researches", with: "research")
                        .replacingOccurrences(of: "equipments", with: "equipment"),
                    errorType: "Uncountable Nouns",
                    explanation: "Academic nouns such as 'information', 'research', and 'equipment' are uncountable in English and do not take a plural '-s'.",
                    arabicExplanation: "الأسماء غير المعدودة مثل information و research و equipment لا تُجمع بإضافة s في الإنجليزية."
                ))
            }
            if lower.contains("despite of") {
                issues.append(SentenceCorrection(
                    originalSentence: sentence,
                    correctedSentence: sentence.replacingOccurrences(of: "despite of", with: "despite", options: .caseInsensitive),
                    errorType: "Preposition Usage",
                    explanation: "Use 'despite + noun/gerund' or 'in spite of + noun/gerund', never 'despite of'.",
                    arabicExplanation: "نستخدم despite بدون of، أو نستخدم in spite of."
                ))
            }
        }
        return issues
    }
}
