import Foundation

// MARK: - Language & Localization

public enum SupportedLanguage: String, Codable, CaseIterable, Sendable, Identifiable {
    case english = "en"
    case arabic = "ar"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية (Arabic)"
        }
    }

    public var isRTL: Bool {
        self == .arabic
    }
}

public enum LanguageAssistanceMode: String, Codable, CaseIterable, Sendable, Identifiable {
    case bilingualOnDemand = "bilingual_on_demand"
    case adaptiveFade = "adaptive_fade"
    case englishImmersion = "english_immersion"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .bilingualOnDemand: return "English default with Arabic on request"
        case .adaptiveFade: return "Adaptive Arabic reduction"
        case .englishImmersion: return "English only immersion"
        }
    }
}

// MARK: - CEFR & IELTS Band Types

public enum CEFRLevel: String, Codable, CaseIterable, Sendable, Comparable, Identifiable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"

    public var id: String { rawValue }

    public var order: Int {
        switch self {
        case .a1: return 1
        case .a2: return 2
        case .b1: return 3
        case .b2: return 4
        case .c1: return 5
        case .c2: return 6
        }
    }

    public static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool {
        lhs.order < rhs.order
    }

    public var descriptor: String {
        switch self {
        case .a1: return "Breakthrough (Basic User)"
        case .a2: return "Waystage (Basic User)"
        case .b1: return "Threshold (Independent User)"
        case .b2: return "Vantage (Independent User)"
        case .c1: return "Effective Operational Proficiency (Proficient User)"
        case .c2: return "Mastery (Proficient User)"
        }
    }
}

public enum AssessmentConfidence: String, Codable, CaseIterable, Sendable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case unavailable = "Unavailable"
}

public enum ExamModule: String, Codable, CaseIterable, Sendable, Identifiable {
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    case speaking = "Speaking"

    public var id: String { rawValue }

    public var officialDurationMinutes: Int {
        switch self {
        case .listening: return 32 // ~30 min audio + 2 min review (computer-delivered)
        case .reading: return 60
        case .writing: return 60
        case .speaking: return 14
        }
    }
}

public enum SessionMode: String, Codable, CaseIterable, Sendable, Identifiable {
    case examination = "Examination Mode"
    case learning = "Learning Mode"
    case untimedPractice = "Untimed Practice"
    case adaptive = "Adaptive Practice"

    public var id: String { rawValue }

    public var allowsAIHelp: Bool {
        self != .examination
    }

    public var allowsArabicAssistance: Bool {
        self != .examination
    }

    public var allowsAudioReplay: Bool {
        self != .examination
    }
}

public enum DifficultyTier: String, Codable, CaseIterable, Sendable, Identifiable {
    case foundation = "Foundation (Band 5.0 to 6.0)"
    case intermediate = "Standard Academic (Band 6.0 to 7.0)"
    case target = "Target High Band (Band 7.0 to 8.0)"
    case advanced = "Advanced Academic (Band 8.0 to 9.0)"

    public var id: String { rawValue }
}

// MARK: - Source Attribution & Provenance

public enum ContentOrigin: String, Codable, Sendable {
    case officialPublicSample = "Official Public Sample"
    case originalPractice = "Original IELTS-Style Practice"
    case aiGeneratedValidated = "AI-Generated (Validated)"
}

public struct SourceAttribution: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let sourceName: String
    public let originalURL: String
    public let accessDate: String
    public let copyrightAndLicense: String
    public let category: String
    public let verificationStatus: String
    public let summary: String

    public init(
        id: String,
        sourceName: String,
        originalURL: String,
        accessDate: String,
        copyrightAndLicense: String,
        category: String,
        verificationStatus: String,
        summary: String
    ) {
        self.id = id
        self.sourceName = sourceName
        self.originalURL = originalURL
        self.accessDate = accessDate
        self.copyrightAndLicense = copyrightAndLicense
        self.category = category
        self.verificationStatus = verificationStatus
        self.summary = summary
    }
}

public struct ContentProvenance: Codable, Hashable, Sendable {
    public let origin: ContentOrigin
    public let isOfficialIELTSMaterial: Bool
    public let generatorModel: String?
    public let validatedAt: Date
    public let validationPassed: Bool
    public let validationNotes: [String]
    public let sourceReferenceIDs: [String]

    public init(
        origin: ContentOrigin,
        isOfficialIELTSMaterial: Bool,
        generatorModel: String? = nil,
        validatedAt: Date = Date(),
        validationPassed: Bool = true,
        validationNotes: [String] = [],
        sourceReferenceIDs: [String] = []
    ) {
        self.origin = origin
        self.isOfficialIELTSMaterial = isOfficialIELTSMaterial
        self.generatorModel = generatorModel
        self.validatedAt = validatedAt
        self.validationPassed = validationPassed
        self.validationNotes = validationNotes
        self.sourceReferenceIDs = sourceReferenceIDs
    }
}

// MARK: - Question Models (All Official Listening & Reading Formats)

public enum QuestionFormat: String, Codable, CaseIterable, Sendable, Identifiable {
    case multipleChoice = "Multiple Choice"
    case trueFalseNotGiven = "True / False / Not Given"
    case yesNoNotGiven = "Yes / No / Not Given"
    case matchingHeadings = "Matching Headings"
    case matchingInformation = "Matching Information"
    case matchingFeatures = "Matching Features"
    case matchingSentenceEndings = "Matching Sentence Endings"
    case matching = "Matching"
    case formCompletion = "Form Completion"
    case noteCompletion = "Note Completion"
    case tableCompletion = "Table Completion"
    case flowchartCompletion = "Flowchart Completion"
    case summaryCompletion = "Summary Completion"
    case sentenceCompletion = "Sentence Completion"
    case diagramLabeling = "Map / Diagram Labeling"
    case shortAnswer = "Short Answer"

    public var id: String { rawValue }
}

public enum EnglishAccent: String, Codable, CaseIterable, Sendable, Identifiable {
    case british = "en-GB"
    case american = "en-US"
    case australian = "en-AU"
    case canadian = "en-CA"
    case irish = "en-IE"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .british: return "British English"
        case .american: return "American English"
        case .australian: return "Australian English"
        case .canadian: return "Canadian English"
        case .irish: return "Irish English"
        }
    }
}

public struct ExamQuestion: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let number: Int
    public let format: QuestionFormat
    public let prompt: String
    public let options: [String]
    public let acceptedAnswers: [String]
    public let maxWordCount: Int?
    public let explanation: String
    public let arabicExplanation: String?
    public let evidenceQuote: String
    public let distractorNote: String?
    public let skillTag: String

    public init(
        id: String,
        number: Int,
        format: QuestionFormat,
        prompt: String,
        options: [String] = [],
        acceptedAnswers: [String],
        maxWordCount: Int? = nil,
        explanation: String,
        arabicExplanation: String? = nil,
        evidenceQuote: String,
        distractorNote: String? = nil,
        skillTag: String = "comprehension"
    ) {
        self.id = id
        self.number = number
        self.format = format
        self.prompt = prompt
        self.options = options
        self.acceptedAnswers = acceptedAnswers
        self.maxWordCount = maxWordCount
        self.explanation = explanation
        self.arabicExplanation = arabicExplanation
        self.evidenceQuote = evidenceQuote
        self.distractorNote = distractorNote
        self.skillTag = skillTag
    }
}

// MARK: - Listening Module Models

public struct DialogueTurn: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let speaker: String
    public let accent: EnglishAccent
    public let text: String

    public init(id: String = UUID().uuidString, speaker: String, accent: EnglishAccent, text: String) {
        self.id = id
        self.speaker = speaker
        self.accent = accent
        self.text = text
    }
}

public struct ListeningPart: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let partNumber: Int // 1..4
    public let title: String
    public let contextDescription: String
    public let primaryAccent: EnglishAccent
    public let dialogue: [DialogueTurn]
    public let questions: [ExamQuestion]
    public let keyVocabulary: [String]

    public init(
        id: String,
        partNumber: Int,
        title: String,
        contextDescription: String,
        primaryAccent: EnglishAccent,
        dialogue: [DialogueTurn],
        questions: [ExamQuestion],
        keyVocabulary: [String]
    ) {
        self.id = id
        self.partNumber = partNumber
        self.title = title
        self.contextDescription = contextDescription
        self.primaryAccent = primaryAccent
        self.dialogue = dialogue
        self.questions = questions
        self.keyVocabulary = keyVocabulary
    }

    public var fullTranscript: String {
        dialogue.map { "\($0.speaker): \($0.text)" }.joined(separator: "\n\n")
    }
}

// MARK: - Reading Module Models

public struct ReadingPassage: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let passageNumber: Int // 1..3
    public let title: String
    public let discipline: String
    public let paragraphs: [String]
    public let questions: [ExamQuestion]
    public let estimatedWordCount: Int

    public init(
        id: String,
        passageNumber: Int,
        title: String,
        discipline: String,
        paragraphs: [String],
        questions: [ExamQuestion]
    ) {
        self.id = id
        self.passageNumber = passageNumber
        self.title = title
        self.discipline = discipline
        self.paragraphs = paragraphs
        self.questions = questions
        self.estimatedWordCount = paragraphs.joined(separator: " ").split { $0.isWhitespace || $0.isNewline }.count
    }

    public var fullText: String {
        paragraphs.enumerated().map { idx, p in
            let label = String(UnicodeScalar(65 + idx)!)
            return "\(label). \(p)"
        }.joined(separator: "\n\n")
    }
}

// MARK: - Writing Module Models

public enum WritingTask1VisualType: String, Codable, CaseIterable, Sendable {
    case lineChart = "Line Chart"
    case barChart = "Bar Chart"
    case pieChart = "Pie Chart"
    case table = "Table"
    case processDiagram = "Process Diagram"
    case mapComparison = "Map Comparison"
    case combinedChart = "Combined Visual Data"
}

public struct VisualDataPoint: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let series: String
    public let category: String
    public let value: Double
    public let unit: String

    public init(id: String = UUID().uuidString, series: String, category: String, value: Double, unit: String) {
        self.id = id
        self.series = series
        self.category = category
        self.value = value
        self.unit = unit
    }
}

public struct WritingTask1Prompt: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let visualType: WritingTask1VisualType
    public let instructions: String
    public let minimumWords: Int
    public let dataPoints: [VisualDataPoint]
    public let processSteps: [String]
    public let keyOverviewPoints: [String]

    public init(
        id: String,
        title: String,
        visualType: WritingTask1VisualType,
        instructions: String,
        minimumWords: Int = 150,
        dataPoints: [VisualDataPoint] = [],
        processSteps: [String] = [],
        keyOverviewPoints: [String] = []
    ) {
        self.id = id
        self.title = title
        self.visualType = visualType
        self.instructions = instructions
        self.minimumWords = minimumWords
        self.dataPoints = dataPoints
        self.processSteps = processSteps
        self.keyOverviewPoints = keyOverviewPoints
    }
}

public enum WritingTask2EssayType: String, Codable, CaseIterable, Sendable {
    case opinion = "Opinion (Agree / Disagree)"
    case discussion = "Discussion (Both Views + Opinion)"
    case advantagesDisadvantages = "Advantages & Disadvantages"
    case problemSolution = "Problem & Solution"
    case twoPartQuestion = "Two-Part Question"
}

public struct WritingTask2Prompt: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let essayType: WritingTask2EssayType
    public let topicDomain: String
    public let promptText: String
    public let minimumWords: Int

    public init(
        id: String,
        title: String,
        essayType: WritingTask2EssayType,
        topicDomain: String,
        promptText: String,
        minimumWords: Int = 250
    ) {
        self.id = id
        self.title = title
        self.essayType = essayType
        self.topicDomain = topicDomain
        self.promptText = promptText
        self.minimumWords = minimumWords
    }
}

public struct WritingModelSample: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let taskNumber: Int // 1 or 2
    public let estimatedBand: Double
    public let promptSummary: String
    public let essayText: String
    public let examinerNotes: String
    public let arabicSummary: String
    public let disclaimer: String

    public init(
        id: String,
        taskNumber: Int,
        estimatedBand: Double,
        promptSummary: String,
        essayText: String,
        examinerNotes: String,
        arabicSummary: String,
        disclaimer: String = "Original educational example created to illustrate IELTS band descriptors. Not an official IELTS script."
    ) {
        self.id = id
        self.taskNumber = taskNumber
        self.estimatedBand = estimatedBand
        self.promptSummary = promptSummary
        self.essayText = essayText
        self.examinerNotes = examinerNotes
        self.arabicSummary = arabicSummary
        self.disclaimer = disclaimer
    }
}

// MARK: - Speaking Module Models

public struct SpeakingCueCard: Codable, Hashable, Sendable {
    public let topic: String
    public let bulletPoints: [String]
    public let prepSeconds: Int
    public let speakSeconds: Int

    public init(topic: String, bulletPoints: [String], prepSeconds: Int = 60, speakSeconds: Int = 120) {
        self.topic = topic
        self.bulletPoints = bulletPoints
        self.prepSeconds = prepSeconds
        self.speakSeconds = speakSeconds
    }
}

public struct SpeakingPromptSet: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let theme: String
    public let part1Questions: [String]
    public let part2CueCard: SpeakingCueCard
    public let part3Questions: [String]

    public init(
        id: String,
        theme: String,
        part1Questions: [String],
        part2CueCard: SpeakingCueCard,
        part3Questions: [String]
    ) {
        self.id = id
        self.theme = theme
        self.part1Questions = part1Questions
        self.part2CueCard = part2CueCard
        self.part3Questions = part3Questions
    }
}

// MARK: - Complete Mock Exam

public struct MockExam: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let examNumber: Int
    public let title: String
    public let difficulty: DifficultyTier
    public let theme: String
    public let listeningParts: [ListeningPart]
    public let readingPassages: [ReadingPassage]
    public let writingTask1: WritingTask1Prompt
    public let writingTask2: WritingTask2Prompt
    public let speakingSet: SpeakingPromptSet
    public let provenance: ContentProvenance

    public init(
        id: String,
        examNumber: Int,
        title: String,
        difficulty: DifficultyTier,
        theme: String,
        listeningParts: [ListeningPart],
        readingPassages: [ReadingPassage],
        writingTask1: WritingTask1Prompt,
        writingTask2: WritingTask2Prompt,
        speakingSet: SpeakingPromptSet,
        provenance: ContentProvenance
    ) {
        self.id = id
        self.examNumber = examNumber
        self.title = title
        self.difficulty = difficulty
        self.theme = theme
        self.listeningParts = listeningParts
        self.readingPassages = readingPassages
        self.writingTask1 = writingTask1
        self.writingTask2 = writingTask2
        self.speakingSet = speakingSet
        self.provenance = provenance
    }

    public var totalListeningQuestions: Int {
        listeningParts.reduce(0) { $0 + $1.questions.count }
    }

    public var totalReadingQuestions: Int {
        readingPassages.reduce(0) { $0 + $1.questions.count }
    }
}

// MARK: - Learner Profile, Attempts, Mistakes, Curriculum

public struct LearnerProfile: Codable, Sendable {
    public var id: String
    public var displayName: String
    public var targetBand: Double
    public var estimatedOverallBand: Double
    public var estimatedListeningBand: Double
    public var estimatedReadingBand: Double
    public var estimatedWritingBand: Double
    public var estimatedSpeakingBand: Double
    public var estimatedCEFR: CEFRLevel
    public var assessmentConfidence: AssessmentConfidence
    public var hasCompletedDiagnostic: Bool
    public var languageMode: LanguageAssistanceMode
    public var preferredSessionMinutes: Int
    public var academicInterests: [String]
    public var professionalGoal: String
    public var externalAIConsentGranted: Bool
    public var audioRetentionDays: Int
    public var updatedAt: Date

    public init(
        id: String = "primary-learner",
        displayName: String = "IELTS Academic Candidate",
        targetBand: Double = 7.5,
        estimatedOverallBand: Double = 5.5,
        estimatedListeningBand: Double = 5.5,
        estimatedReadingBand: Double = 5.5,
        estimatedWritingBand: Double = 5.0,
        estimatedSpeakingBand: Double = 5.5,
        estimatedCEFR: CEFRLevel = .b2,
        assessmentConfidence: AssessmentConfidence = .low,
        hasCompletedDiagnostic: Bool = false,
        languageMode: LanguageAssistanceMode = .adaptiveFade,
        preferredSessionMinutes: Int = 45,
        academicInterests: [String] = [
            "Agricultural Sciences",
            "Animal Science",
            "Animal Nutrition",
            "Biotechnology",
            "Environmental Science",
            "Scientific Research"
        ],
        professionalGoal: String = "International academic and professional communication, including employment in Ireland",
        externalAIConsentGranted: Bool = false,
        audioRetentionDays: Int = 90,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.targetBand = targetBand
        self.estimatedOverallBand = estimatedOverallBand
        self.estimatedListeningBand = estimatedListeningBand
        self.estimatedReadingBand = estimatedReadingBand
        self.estimatedWritingBand = estimatedWritingBand
        self.estimatedSpeakingBand = estimatedSpeakingBand
        self.estimatedCEFR = estimatedCEFR
        self.assessmentConfidence = assessmentConfidence
        self.hasCompletedDiagnostic = hasCompletedDiagnostic
        self.languageMode = languageMode
        self.preferredSessionMinutes = preferredSessionMinutes
        self.academicInterests = academicInterests
        self.professionalGoal = professionalGoal
        self.externalAIConsentGranted = externalAIConsentGranted
        self.audioRetentionDays = audioRetentionDays
        self.updatedAt = updatedAt
    }

    public var shouldShowArabicByDefault: Bool {
        switch languageMode {
        case .englishImmersion:
            return false
        case .bilingualOnDemand:
            return true
        case .adaptiveFade:
            return estimatedOverallBand < 6.5
        }
    }
}

public struct ExamAttemptRecord: Codable, Identifiable, Sendable {
    public let id: String
    public let examID: String
    public let examTitle: String
    public let module: String // "Full Mock" or ExamModule.rawValue
    public let sessionMode: SessionMode
    public let date: Date
    public let durationSeconds: Int
    public let listeningRaw: Int?
    public let listeningBand: Double?
    public let readingRaw: Int?
    public let readingBand: Double?
    public let writingBand: Double?
    public let speakingBand: Double?
    public let overallBand: Double
    public let readingWPM: Double?
    public let isEstimate: Bool
    public let notes: String

    public init(
        id: String = UUID().uuidString,
        examID: String,
        examTitle: String,
        module: String,
        sessionMode: SessionMode,
        date: Date = Date(),
        durationSeconds: Int,
        listeningRaw: Int? = nil,
        listeningBand: Double? = nil,
        readingRaw: Int? = nil,
        readingBand: Double? = nil,
        writingBand: Double? = nil,
        speakingBand: Double? = nil,
        overallBand: Double,
        readingWPM: Double? = nil,
        isEstimate: Bool = true,
        notes: String = ""
    ) {
        self.id = id
        self.examID = examID
        self.examTitle = examTitle
        self.module = module
        self.sessionMode = sessionMode
        self.date = date
        self.durationSeconds = durationSeconds
        self.listeningRaw = listeningRaw
        self.listeningBand = listeningBand
        self.readingRaw = readingRaw
        self.readingBand = readingBand
        self.writingBand = writingBand
        self.speakingBand = speakingBand
        self.overallBand = overallBand
        self.readingWPM = readingWPM
        self.isEstimate = isEstimate
        self.notes = notes
    }
}

public enum MasteryStatus: String, Codable, CaseIterable, Sendable {
    case needsWork = "Needs Work"
    case reviewing = "Reviewing"
    case mastered = "Mastered"
}

public struct MistakeEntry: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var sourceModule: String
    public var originalPrompt: String
    public var learnerAnswer: String
    public var correctAnswer: String
    public var explanation: String
    public var arabicExplanation: String?
    public var errorCategory: String
    public var relatedGrammarRule: String
    public var relevantVocabulary: [String]
    public var recurrenceCount: Int
    public var occurredAt: Date
    public var masteryStatus: MasteryStatus
    public var nextRevisionDate: Date

    public init(
        id: String = UUID().uuidString,
        sourceModule: String,
        originalPrompt: String,
        learnerAnswer: String,
        correctAnswer: String,
        explanation: String,
        arabicExplanation: String? = nil,
        errorCategory: String,
        relatedGrammarRule: String,
        relevantVocabulary: [String] = [],
        recurrenceCount: Int = 1,
        occurredAt: Date = Date(),
        masteryStatus: MasteryStatus = .needsWork,
        nextRevisionDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    ) {
        self.id = id
        self.sourceModule = sourceModule
        self.originalPrompt = originalPrompt
        self.learnerAnswer = learnerAnswer
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.arabicExplanation = arabicExplanation
        self.errorCategory = errorCategory
        self.relatedGrammarRule = relatedGrammarRule
        self.relevantVocabulary = relevantVocabulary
        self.recurrenceCount = recurrenceCount
        self.occurredAt = occurredAt
        self.masteryStatus = masteryStatus
        self.nextRevisionDate = nextRevisionDate
    }

    public var isRecurringPattern: Bool {
        recurrenceCount >= 2
    }
}

public struct VocabularyItem: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var word: String
    public var partOfSpeech: String
    public var ipa: String
    public var category: String
    public var cefrLevel: CEFRLevel
    public var definition: String
    public var arabicTranslation: String
    public var exampleSentence: String
    public var collocations: [String]
    public var synonyms: [String]
    public var wordFamily: [String]
    // SM-2 Spaced Repetition state
    public var easeFactor: Double
    public var intervalDays: Int
    public var repetitions: Int
    public var nextReviewDate: Date
    public var lastReviewedAt: Date?

    public init(
        id: String,
        word: String,
        partOfSpeech: String,
        ipa: String,
        category: String,
        cefrLevel: CEFRLevel,
        definition: String,
        arabicTranslation: String,
        exampleSentence: String,
        collocations: [String],
        synonyms: [String] = [],
        wordFamily: [String] = [],
        easeFactor: Double = 2.5,
        intervalDays: Int = 0,
        repetitions: Int = 0,
        nextReviewDate: Date = Date(),
        lastReviewedAt: Date? = nil
    ) {
        self.id = id
        self.word = word
        self.partOfSpeech = partOfSpeech
        self.ipa = ipa
        self.category = category
        self.cefrLevel = cefrLevel
        self.definition = definition
        self.arabicTranslation = arabicTranslation
        self.exampleSentence = exampleSentence
        self.collocations = collocations
        self.synonyms = synonyms
        self.wordFamily = wordFamily
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
        self.repetitions = repetitions
        self.nextReviewDate = nextReviewDate
        self.lastReviewedAt = lastReviewedAt
    }
}

public struct GrammarExercise: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let prompt: String
    public let options: [String]
    public let correctIndex: Int
    public let explanation: String
    public let arabicExplanation: String

    public init(
        id: String,
        prompt: String,
        options: [String],
        correctIndex: Int,
        explanation: String,
        arabicExplanation: String
    ) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
        self.arabicExplanation = arabicExplanation
    }
}

public struct GrammarLesson: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let order: Int
    public let title: String
    public let cefrRange: String
    public let prerequisites: [String]
    public let summary: String
    public let detailedRules: [String]
    public let examples: [String]
    public let commonIELTSTraps: [String]
    public let arabicExplanation: String
    public let exercises: [GrammarExercise]

    public init(
        id: String,
        order: Int,
        title: String,
        cefrRange: String,
        prerequisites: [String] = [],
        summary: String,
        detailedRules: [String],
        examples: [String],
        commonIELTSTraps: [String],
        arabicExplanation: String,
        exercises: [GrammarExercise]
    ) {
        self.id = id
        self.order = order
        self.title = title
        self.cefrRange = cefrRange
        self.prerequisites = prerequisites
        self.summary = summary
        self.detailedRules = detailedRules
        self.examples = examples
        self.commonIELTSTraps = commonIELTSTraps
        self.arabicExplanation = arabicExplanation
        self.exercises = exercises
    }
}

public struct GrammarProgressRecord: Codable, Identifiable, Sendable {
    public var id: String // matches GrammarLesson.id
    public var attempts: Int
    public var correctCount: Int
    public var totalQuestions: Int
    public var status: MasteryStatus
    public var lastPracticedAt: Date?
    public var nextReassessmentDate: Date?

    public init(
        id: String,
        attempts: Int = 0,
        correctCount: Int = 0,
        totalQuestions: Int = 0,
        status: MasteryStatus = .needsWork,
        lastPracticedAt: Date? = nil,
        nextReassessmentDate: Date? = nil
    ) {
        self.id = id
        self.attempts = attempts
        self.correctCount = correctCount
        self.totalQuestions = totalQuestions
        self.status = status
        self.lastPracticedAt = lastPracticedAt
        self.nextReassessmentDate = nextReassessmentDate
    }

    public var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions)
    }
}

public struct AcademicEnglishUnit: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let isSpecializedAgriBio: Bool
    public let overview: String
    public let keyConventions: [String]
    public let modelExcerpt: String
    public let keyPhrases: [String]
    public let arabicNotes: String
    public let practiceTask: String

    public init(
        id: String,
        title: String,
        category: String,
        isSpecializedAgriBio: Bool,
        overview: String,
        keyConventions: [String],
        modelExcerpt: String,
        keyPhrases: [String],
        arabicNotes: String,
        practiceTask: String
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.isSpecializedAgriBio = isSpecializedAgriBio
        self.overview = overview
        self.keyConventions = keyConventions
        self.modelExcerpt = modelExcerpt
        self.keyPhrases = keyPhrases
        self.arabicNotes = arabicNotes
        self.practiceTask = practiceTask
    }
}

public struct StudySessionItem: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var dayLabel: String
    public var title: String
    public var module: String
    public var durationMinutes: Int
    public var focusReason: String
    public var isBreak: Bool
    public var isCompleted: Bool

    public init(
        id: String = UUID().uuidString,
        dayLabel: String,
        title: String,
        module: String,
        durationMinutes: Int,
        focusReason: String,
        isBreak: Bool = false,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.dayLabel = dayLabel
        self.title = title
        self.module = module
        self.durationMinutes = durationMinutes
        self.focusReason = focusReason
        self.isBreak = isBreak
        self.isCompleted = isCompleted
    }
}

public struct StudyPlan: Codable, Identifiable, Sendable {
    public var id: String
    public var createdAt: Date
    public var sessionDurationMinutes: Int
    public var targetBand: Double
    public var priorityWeaknesses: [String]
    public var sessions: [StudySessionItem]

    public init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        sessionDurationMinutes: Int,
        targetBand: Double,
        priorityWeaknesses: [String],
        sessions: [StudySessionItem]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.sessionDurationMinutes = sessionDurationMinutes
        self.targetBand = targetBand
        self.priorityWeaknesses = priorityWeaknesses
        self.sessions = sessions
    }
}

public struct EssaySubmission: Codable, Identifiable, Sendable {
    public var id: String
    public var taskNumber: Int
    public var promptID: String
    public var promptTitle: String
    public var text: String
    public var wordCount: Int
    public var estimatedBand: Double?
    public var feedbackJSON: String?
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: String = UUID().uuidString,
        taskNumber: Int,
        promptID: String,
        promptTitle: String,
        text: String,
        wordCount: Int,
        estimatedBand: Double? = nil,
        feedbackJSON: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.taskNumber = taskNumber
        self.promptID = promptID
        self.promptTitle = promptTitle
        self.text = text
        self.wordCount = wordCount
        self.estimatedBand = estimatedBand
        self.feedbackJSON = feedbackJSON
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct AudioRecordingRecord: Codable, Identifiable, Sendable {
    public var id: String
    public var context: String // "Speaking Part 2", "Pronunciation Lab"
    public var filePath: String
    public var durationSeconds: Double
    public var transcript: String
    public var estimatedWPM: Double
    public var pauseRatio: Double
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        context: String,
        filePath: String,
        durationSeconds: Double,
        transcript: String,
        estimatedWPM: Double,
        pauseRatio: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.context = context
        self.filePath = filePath
        self.durationSeconds = durationSeconds
        self.transcript = transcript
        self.estimatedWPM = estimatedWPM
        self.pauseRatio = pauseRatio
        self.createdAt = createdAt
    }
}
