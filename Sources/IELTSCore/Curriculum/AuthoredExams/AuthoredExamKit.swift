import Foundation

/// Compact builders for hand-authored mock exams.
///
/// Authored exams are written one at a time as complete texts: every passage, script and
/// question is specific to that exam. Nothing here substitutes words into a shared template.
/// `ContentValidator.validateBank` rejects exams that reuse another exam's stems or paragraphs.
enum AuthorKit {

    // MARK: Dialogue

    static func turn(_ speaker: String, _ accent: EnglishAccent, _ text: String) -> DialogueTurn {
        DialogueTurn(speaker: speaker, accent: accent, text: text)
    }

    // MARK: Questions

    /// Single-answer multiple choice. `options` are written as "A. …", "B. …".
    /// The submitted value is the full option text, so the letter, the full option and the
    /// option text without its letter are all accepted.
    static func mcq(
        _ prefix: String, _ n: Int, _ prompt: String, _ options: [String], _ letter: String,
        why: String, evidence: String, distractor: String? = nil, skill: String = "multiple_choice"
    ) -> ExamQuestion {
        ExamQuestion(
            id: "\(prefix)\(n)", number: n, format: .multipleChoice, prompt: prompt, options: options,
            acceptedAnswers: letterAnswers(letter, options), explanation: why,
            evidenceQuote: evidence, distractorNote: distractor, skillTag: skill
        )
    }

    /// Matching task (headings, information, features, sentence endings, or listening matching).
    static func match(
        _ prefix: String, _ n: Int, _ format: QuestionFormat, _ prompt: String, _ options: [String], _ letter: String,
        why: String, evidence: String, distractor: String? = nil, skill: String
    ) -> ExamQuestion {
        ExamQuestion(
            id: "\(prefix)\(n)", number: n, format: format, prompt: prompt, options: options,
            acceptedAnswers: letterAnswers(letter, options), explanation: why,
            evidenceQuote: evidence, distractorNote: distractor, skillTag: skill
        )
    }

    static func tfng(
        _ prefix: String, _ n: Int, _ statement: String, _ answer: String,
        why: String, evidence: String, distractor: String? = nil
    ) -> ExamQuestion {
        ExamQuestion(
            id: "\(prefix)\(n)", number: n, format: .trueFalseNotGiven, prompt: statement,
            options: ["TRUE", "FALSE", "NOT GIVEN"], acceptedAnswers: [answer], explanation: why,
            evidenceQuote: evidence, distractorNote: distractor, skillTag: "tfng"
        )
    }

    static func ynng(
        _ prefix: String, _ n: Int, _ statement: String, _ answer: String,
        why: String, evidence: String, distractor: String? = nil
    ) -> ExamQuestion {
        ExamQuestion(
            id: "\(prefix)\(n)", number: n, format: .yesNoNotGiven, prompt: statement,
            options: ["YES", "NO", "NOT GIVEN"], acceptedAnswers: [answer], explanation: why,
            evidenceQuote: evidence, distractorNote: distractor, skillTag: "ynng"
        )
    }

    /// Completion / short-answer item typed by the learner. `answers` lists every accepted spelling.
    static func gap(
        _ prefix: String, _ n: Int, _ format: QuestionFormat, _ prompt: String, _ answers: [String], maxWords: Int,
        why: String, evidence: String, skill: String
    ) -> ExamQuestion {
        ExamQuestion(
            id: "\(prefix)\(n)", number: n, format: format, prompt: prompt, options: [],
            acceptedAnswers: answers, maxWordCount: maxWords, explanation: why,
            evidenceQuote: evidence, skillTag: skill
        )
    }

    private static func letterAnswers(_ letter: String, _ options: [String]) -> [String] {
        var answers = [letter]
        if let full = options.first(where: { $0.hasPrefix("\(letter). ") }) {
            answers.append(full)
            answers.append(String(full.dropFirst(letter.count + 2)))
        }
        return answers
    }

    // MARK: Provenance

    static func provenance(_ notes: [String]) -> ContentProvenance {
        ContentProvenance(
            origin: .originalPractice,
            isOfficialIELTSMaterial: false,
            generatorModel: "Hand-authored (Claude) — original IELTS-style text",
            validationPassed: true,
            validationNotes: notes + [
                "Original practice material written to the public IELTS Academic format. Not an official or past IELTS paper.",
                "People and organisations named in passages and scripts are fictional unless the text states otherwise."
            ],
            sourceReferenceIDs: ["src-ielts-org", "src-british-council", "src-idp-ielts"]
        )
    }
}
