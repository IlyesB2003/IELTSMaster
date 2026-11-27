import Foundation

// MARK: - AI Provider & Model Management

public enum AIProviderKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case ollama = "Ollama (Local)"
    case anthropic = "Anthropic Claude (External)"
    case openAI = "OpenAI (External)"
    case gemini = "Google Gemini (External)"

    public var id: String { rawValue }

    public var isExternal: Bool {
        self != .ollama
    }
}

public enum ModelTaskRole: String, Codable, CaseIterable, Sendable, Identifiable {
    case aiTeacher = "AI Teacher"
    case writingEvaluator = "Writing Evaluator"
    case speakingExaminer = "Speaking Examiner"
    case questionGenerator = "Question Generator"
    case grammarCorrection = "Grammar Correction"
    case arabicExplanation = "Arabic Explanation"
    case vocabularyGeneration = "Vocabulary Generation"
    case contentVerification = "Content Verification"

    public var id: String { rawValue }
}

public struct LocalModelInfo: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let family: String
    public let sizeBytes: Int64
    public let parameterSize: String
    public let quantization: String
    public let estimatedRAMGB: Double
    public let contextWindow: Int
    public let capabilities: [String]
    public var tokensPerSecond: Double?
    public var isLoaded: Bool

    public init(
        id: String,
        name: String,
        family: String,
        sizeBytes: Int64,
        parameterSize: String = "Unknown",
        quantization: String = "Unknown",
        estimatedRAMGB: Double,
        contextWindow: Int = 8192,
        capabilities: [String] = ["chat", "json"],
        tokensPerSecond: Double? = nil,
        isLoaded: Bool = false
    ) {
        self.id = id
        self.name = name
        self.family = family
        self.sizeBytes = sizeBytes
        self.parameterSize = parameterSize
        self.quantization = quantization
        self.estimatedRAMGB = estimatedRAMGB
        self.contextWindow = contextWindow
        self.capabilities = capabilities
        self.tokensPerSecond = tokensPerSecond
        self.isLoaded = isLoaded
    }

    public var formattedSize: String {
        let gb = Double(sizeBytes) / 1_073_741_824.0
        return String(format: "%.2f GB", gb)
    }

    public var fitsComfortablyIn16GB: Bool {
        estimatedRAMGB <= 10.5
    }
}

public struct ModelRoutingConfiguration: Codable, Sendable {
    public var ollamaBaseURL: String
    public var activeProvider: AIProviderKind
    public var roleAssignments: [String: String] // ModelTaskRole.rawValue -> model name
    public var externalModelName: String
    public var maxConcurrentLoadedModels: Int

    public init(
        ollamaBaseURL: String = "http://127.0.0.1:11434",
        activeProvider: AIProviderKind = .ollama,
        roleAssignments: [String: String] = [:],
        externalModelName: String = "",
        maxConcurrentLoadedModels: Int = 1
    ) {
        self.ollamaBaseURL = ollamaBaseURL
        self.activeProvider = activeProvider
        self.roleAssignments = roleAssignments
        self.externalModelName = externalModelName
        self.maxConcurrentLoadedModels = maxConcurrentLoadedModels
    }

    public func model(for role: ModelTaskRole, fallback: String) -> String {
        if let assigned = roleAssignments[role.rawValue], !assigned.isEmpty {
            return assigned
        }
        return fallback
    }
}

// MARK: - AI Teacher & Assessment Structured Outputs

public struct TeacherMessage: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let role: String // "user", "assistant", "system"
    public let content: String
    public let arabicContent: String?
    public let citations: [String]
    public let timestamp: Date
    public let modelUsed: String?

    public init(
        id: String = UUID().uuidString,
        role: String,
        content: String,
        arabicContent: String? = nil,
        citations: [String] = [],
        timestamp: Date = Date(),
        modelUsed: String? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.arabicContent = arabicContent
        self.citations = citations
        self.timestamp = timestamp
        self.modelUsed = modelUsed
    }
}

public struct SentenceCorrection: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let originalSentence: String
    public let correctedSentence: String
    public let errorType: String
    public let explanation: String
    public let arabicExplanation: String?

    public init(
        id: String = UUID().uuidString,
        originalSentence: String,
        correctedSentence: String,
        errorType: String,
        explanation: String,
        arabicExplanation: String? = nil
    ) {
        self.id = id
        self.originalSentence = originalSentence
        self.correctedSentence = correctedSentence
        self.errorType = errorType
        self.explanation = explanation
        self.arabicExplanation = arabicExplanation
    }
}

public struct WritingEvaluationResult: Codable, Sendable {
    public let taskNumber: Int
    public let taskAchievementBand: Double
    public let coherenceCohesionBand: Double
    public let lexicalResourceBand: Double
    public let grammaticalRangeBand: Double
    public let overallTaskBand: Double
    public let wordCount: Int
    public let meetsWordCount: Bool
    public let confidence: AssessmentConfidence
    public let summaryFeedback: String
    public let paragraphAnalysis: String
    public let argumentAnalysis: String
    public let repeatedWords: [String]
    public let sentenceCorrections: [SentenceCorrection]
    public let vocabularyUpgrades: [String]
    public let targetedExercises: [String]
    public let arabicSummary: String?
    public let disclaimer: String

    public init(
        taskNumber: Int,
        taskAchievementBand: Double,
        coherenceCohesionBand: Double,
        lexicalResourceBand: Double,
        grammaticalRangeBand: Double,
        overallTaskBand: Double,
        wordCount: Int,
        meetsWordCount: Bool,
        confidence: AssessmentConfidence,
        summaryFeedback: String,
        paragraphAnalysis: String,
        argumentAnalysis: String,
        repeatedWords: [String],
        sentenceCorrections: [SentenceCorrection],
        vocabularyUpgrades: [String],
        targetedExercises: [String],
        arabicSummary: String? = nil,
        disclaimer: String = "AI-assisted band estimate based on public IELTS Writing assessment criteria. Not an official IELTS score."
    ) {
        self.taskNumber = taskNumber
        self.taskAchievementBand = taskAchievementBand
        self.coherenceCohesionBand = coherenceCohesionBand
        self.lexicalResourceBand = lexicalResourceBand
        self.grammaticalRangeBand = grammaticalRangeBand
        self.overallTaskBand = overallTaskBand
        self.wordCount = wordCount
        self.meetsWordCount = meetsWordCount
        self.confidence = confidence
        self.summaryFeedback = summaryFeedback
        self.paragraphAnalysis = paragraphAnalysis
        self.argumentAnalysis = argumentAnalysis
        self.repeatedWords = repeatedWords
        self.sentenceCorrections = sentenceCorrections
        self.vocabularyUpgrades = vocabularyUpgrades
        self.targetedExercises = targetedExercises
        self.arabicSummary = arabicSummary
        self.disclaimer = disclaimer
    }
}

public struct SpeakingAcousticMetrics: Codable, Sendable {
    public let durationSeconds: Double
    public let wordCount: Int
    public let wordsPerMinute: Double
    public let pauseRatio: Double
    public let fillerWordCount: Int
    public let detectedFillers: [String]
    public let uniqueWordRatio: Double
    public let audioQualityOK: Bool

    public init(
        durationSeconds: Double,
        wordCount: Int,
        wordsPerMinute: Double,
        pauseRatio: Double,
        fillerWordCount: Int,
        detectedFillers: [String],
        uniqueWordRatio: Double,
        audioQualityOK: Bool
    ) {
        self.durationSeconds = durationSeconds
        self.wordCount = wordCount
        self.wordsPerMinute = wordsPerMinute
        self.pauseRatio = pauseRatio
        self.fillerWordCount = fillerWordCount
        self.detectedFillers = detectedFillers
        self.uniqueWordRatio = uniqueWordRatio
        self.audioQualityOK = audioQualityOK
    }
}

public struct SpeakingEvaluationResult: Codable, Sendable {
    public let fluencyCoherenceBand: Double
    public let lexicalResourceBand: Double
    public let grammaticalRangeBand: Double
    public let pronunciationBand: Double?
    public let overallSpeakingBand: Double
    public let pronunciationConfidence: AssessmentConfidence
    public let pronunciationLimitationNote: String
    public let acousticMetrics: SpeakingAcousticMetrics
    public let strengths: [String]
    public let improvements: [String]
    public let grammarNotes: [String]
    public let vocabularySuggestions: [String]
    public let disclaimer: String

    public init(
        fluencyCoherenceBand: Double,
        lexicalResourceBand: Double,
        grammaticalRangeBand: Double,
        pronunciationBand: Double?,
        overallSpeakingBand: Double,
        pronunciationConfidence: AssessmentConfidence,
        pronunciationLimitationNote: String,
        acousticMetrics: SpeakingAcousticMetrics,
        strengths: [String],
        improvements: [String],
        grammarNotes: [String],
        vocabularySuggestions: [String],
        disclaimer: String = "AI-assisted estimate based on public IELTS Speaking criteria. Non-native accents are never penalized. Not an official IELTS score."
    ) {
        self.fluencyCoherenceBand = fluencyCoherenceBand
        self.lexicalResourceBand = lexicalResourceBand
        self.grammaticalRangeBand = grammaticalRangeBand
        self.pronunciationBand = pronunciationBand
        self.overallSpeakingBand = overallSpeakingBand
        self.pronunciationConfidence = pronunciationConfidence
        self.pronunciationLimitationNote = pronunciationLimitationNote
        self.acousticMetrics = acousticMetrics
        self.strengths = strengths
        self.improvements = improvements
        self.grammarNotes = grammarNotes
        self.vocabularySuggestions = vocabularySuggestions
        self.disclaimer = disclaimer
    }
}

public struct DiagnosticAssessmentResult: Codable, Sendable {
    public let estimatedCEFR: CEFRLevel
    public let overallBand: Double
    public let listeningBand: Double
    public let readingBand: Double
    public let writingBand: Double
    public let speakingBand: Double
    public let grammarAccuracy: Double
    public let vocabularyAccuracy: Double
    public let confidence: AssessmentConfidence
    public let strengths: [String]
    public let weaknesses: [String]
    public let priorities: [String]
    public let cefrDisclaimer: String

    public init(
        estimatedCEFR: CEFRLevel,
        overallBand: Double,
        listeningBand: Double,
        readingBand: Double,
        writingBand: Double,
        speakingBand: Double,
        grammarAccuracy: Double,
        vocabularyAccuracy: Double,
        confidence: AssessmentConfidence,
        strengths: [String],
        weaknesses: [String],
        priorities: [String],
        cefrDisclaimer: String = "CEFR and IELTS are distinct frameworks and are not strictly interchangeable. These estimates serve as a starting baseline and refine as you complete full practice tasks."
    ) {
        self.estimatedCEFR = estimatedCEFR
        self.overallBand = overallBand
        self.listeningBand = listeningBand
        self.readingBand = readingBand
        self.writingBand = writingBand
        self.speakingBand = speakingBand
        self.grammarAccuracy = grammarAccuracy
        self.vocabularyAccuracy = vocabularyAccuracy
        self.confidence = confidence
        self.strengths = strengths
        self.weaknesses = weaknesses
        self.priorities = priorities
        self.cefrDisclaimer = cefrDisclaimer
    }
}
