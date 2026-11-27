import Foundation

/// Deterministic official IELTS scoring, rounding, answer grading, and CEFR mapping engine.
/// Never delegates objective calculations to LLMs.
public struct IELTSScoringEngine: Sendable {
    public init() {}

    // MARK: - Official Band Rounding (.25 -> .5, .75 -> next whole)

    /// Rounds an average band score using official IELTS rounding rules:
    /// - Values ending in .25 round UP to .5
    /// - Values ending in .75 round UP to the next whole band
    /// - Otherwise rounds to the nearest 0.5
    /// - Clamped strictly to [0.0, 9.0]
    public static func roundOfficialBand(_ rawAverage: Double) -> Double {
        let clamped = min(max(rawAverage, 0.0), 9.0)
        // Multiply by 2, add 0.5000001? Careful:
        // In IELTS:
        // .125 -> .0 (distance to 0 is .125, distance to .5 is .375)
        // .25  -> .5 (exact midpoint between .0 and .5 rounds UP)
        // .375 -> .5
        // .625 -> .5
        // .75  -> 1.0 (exact midpoint between .5 and 1.0 rounds UP)
        // .875 -> 1.0
        // Using floor(x * 2 + 0.5) handles exact .25 (0.5 + 0.5 = 1.0 -> 0.5) and .75 (1.5 + 0.5 = 2.0 -> 1.0)!
        let epsilon = 1e-9
        let halfSteps = floor((clamped * 2.0) + 0.5 + epsilon)
        return min(max(halfSteps / 2.0, 0.0), 9.0)
    }

    /// Official Overall IELTS Band Score: arithmetic mean of 4 equal-weight modules, rounded via official rules.
    public static func calculateOverallBand(
        listening: Double,
        reading: Double,
        writing: Double,
        speaking: Double
    ) -> Double {
        let average = (listening + reading + writing + speaking) / 4.0
        return roundOfficialBand(average)
    }

    /// Official Writing Overall Band: Task 2 carries twice the weight of Task 1 (2/3 Task 2 + 1/3 Task 1).
    public static func calculateWritingBand(task1Band: Double, task2Band: Double) -> Double {
        let weighted = (task1Band + (2.0 * task2Band)) / 3.0
        return roundOfficialBand(weighted)
    }

    /// Four-criterion average for Writing Task or Speaking (25% weight each).
    public static func calculateFourCriterionBand(
        c1: Double,
        c2: Double,
        c3: Double,
        c4: Double
    ) -> Double {
        let average = (c1 + c2 + c3 + c4) / 4.0
        return roundOfficialBand(average)
    }

    // MARK: - Raw Score to Band Conversion (40 Questions)

    /// Standard IELTS Listening raw-score (0..40) to band conversion.
    public static func listeningBand(forRawScore raw: Int) -> Double {
        let score = min(max(raw, 0), 40)
        switch score {
        case 39...40: return 9.0
        case 37...38: return 8.5
        case 35...36: return 8.0
        case 32...34: return 7.5
        case 30...31: return 7.0
        case 26...29: return 6.5
        case 23...25: return 6.0
        case 18...22: return 5.5
        case 16...17: return 5.0
        case 13...15: return 4.5
        case 11...12: return 4.0
        case 8...10:  return 3.5
        case 6...7:   return 3.0
        case 4...5:   return 2.5
        case 2...3:   return 2.0
        case 1:       return 1.0
        default:      return 0.0
        }
    }

    /// Standard IELTS Academic Reading raw-score (0..40) to band conversion.
    public static func academicReadingBand(forRawScore raw: Int) -> Double {
        let score = min(max(raw, 0), 40)
        switch score {
        case 39...40: return 9.0
        case 37...38: return 8.5
        case 35...36: return 8.0
        case 33...34: return 7.5
        case 30...32: return 7.0
        case 27...29: return 6.5
        case 23...26: return 6.0
        case 19...22: return 5.5
        case 15...18: return 5.0
        case 13...14: return 4.5
        case 10...12: return 4.0
        case 8...9:   return 3.5
        case 6...7:   return 3.0
        case 4...5:   return 2.5
        case 2...3:   return 2.0
        case 1:       return 1.0
        default:      return 0.0
        }
    }

    // MARK: - CEFR Approximate Alignment (Non-Interchangeable)

    /// Approximate Cambridge English CEFR alignment from estimated IELTS band.
    public static func approximateCEFR(forBand band: Double) -> CEFRLevel {
        switch band {
        case 8.5...:      return .c2
        case 7.0..<8.5:   return .c1
        case 5.5..<7.0:   return .b2
        case 4.0..<5.5:   return .b1
        case 3.0..<4.0:   return .a2
        default:          return .a1
        }
    }

    // MARK: - Deterministic Answer Grading

    public static func normalizeAnswer(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let collapsed = trimmed
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        // Normalize common T/F/NG & Y/N/NG shorthand
        switch collapsed {
        case "t": return "true"
        case "f": return "false"
        case "ng", "not given": return "not given"
        case "y": return "yes"
        case "n": return "no"
        default:
            // Strip trailing period if user typed one
            if collapsed.hasSuffix(".") {
                return String(collapsed.dropLast())
            }
            return collapsed
        }
    }

    /// Deterministically checks whether a learner response satisfies an objective IELTS question.
    public static func isCorrect(response: String, for question: ExamQuestion) -> Bool {
        let normalizedResponse = normalizeAnswer(response)
        guard !normalizedResponse.isEmpty else { return false }

        if let maxWords = question.maxWordCount {
            let count = countWords(in: normalizedResponse)
            if count > maxWords {
                return false
            }
        }

        for accepted in question.acceptedAnswers {
            if normalizeAnswer(accepted) == normalizedResponse {
                return true
            }
        }
        return false
    }

    /// Grades objective questions deterministically.
    ///
    /// `bandScore` is only returned for a complete 40-question test. The official raw-to-band
    /// tables are defined for 40 items; scaling a 13-question passage up to /40 would give a band
    /// with no real confidence, so partial sets return the raw score only.
    public static func gradeObjectiveModule(
        questions: [ExamQuestion],
        responses: [String: String],
        isListening: Bool
    ) -> (rawScore: Int, totalQuestions: Int, bandScore: Double?, incorrectQuestions: [ExamQuestion]) {
        var raw = 0
        var incorrect: [ExamQuestion] = []
        for q in questions {
            let answer = responses[q.id] ?? ""
            if isCorrect(response: answer, for: q) {
                raw += 1
            } else {
                incorrect.append(q)
            }
        }
        guard questions.count == 40 else {
            return (raw, questions.count, nil, incorrect)
        }
        let band = isListening ? listeningBand(forRawScore: raw) : academicReadingBand(forRawScore: raw)
        return (raw, 40, band, incorrect)
    }

    // MARK: - Text & Reading Speed Utilities

    public static func countWords(in text: String) -> Int {
        text.split { $0.isWhitespace || $0.isNewline }.count
    }

    public static func calculateReadingWPM(wordCount: Int, elapsedSeconds: Int) -> Double {
        guard elapsedSeconds > 0, wordCount > 0 else { return 0.0 }
        return (Double(wordCount) / Double(elapsedSeconds)) * 60.0
    }
}
