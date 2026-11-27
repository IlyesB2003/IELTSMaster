import Foundation
import IELTSCore

/// Exports the complete validated IELTSMaster curriculum (32 total exams: existing hand-authored
/// exams + 30 MockExamBank exams, 20 Grammar lessons, Vocabulary, Academic English, Writing Band 4-9
/// samples, and Skills Coach lessons) to `Web/server/content/content.json`.
@main
struct IELTSExport {
    static func main() throws {
        let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Web/server/content"
        let outURL = URL(fileURLWithPath: outDir).appendingPathComponent("content.json")

        // Preserve existing hand-authored exams (authored-01, authored-02) and Skills Coach lessons if present
        var existingRoot: [String: Any] = [:]
        if let raw = try? Data(contentsOf: outURL),
           let json = try? JSONSerialization.jsonObject(with: raw) as? [String: Any] {
            existingRoot = json
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        func toJSONObject<T: Encodable>(_ value: T) throws -> Any {
            let data = try encoder.encode(value)
            return try JSONSerialization.jsonObject(with: data)
        }

        // Keep hand-authored exams first (authored-01, authored-02), then append all 30 diverse bank exams (mock-01..mock-30)
        var mergedExams: [[String: Any]] = []
        var seenIDs = Set<String>()
        let allCombined = MockExamBank.allExams + MockExamBank.legacyTemplateExams
        if let serialized = try toJSONObject(allCombined) as? [[String: Any]] {
            for ex in serialized {
                if let id = ex["id"] as? String, !seenIDs.contains(id) {
                    mergedExams.append(ex)
                    seenIDs.insert(id)
                }
            }
        }

        // Tag pool separation:
        // - First 62 exams (authored-01, authored-02, mock-01..mock-60) -> Full Mock Exam Center (`pool: "mock"`)
        // - Remaining 40 exams (mock-61..mock-100) -> Dedicated Practice & Single-Module Pool (`pool: "practice"`)
        for i in mergedExams.indices {
            let num = mergedExams[i]["examNumber"] as? Int ?? 0
            let id = mergedExams[i]["id"] as? String ?? ""
            let isPracticePool = id.hasPrefix("mock-") && num >= 61
            mergedExams[i]["pool"] = isPracticePool ? "practice" : "mock"
        }

        // Merge skillTitles with all skill tags used across MockExamBank
        var skillTitles = (existingRoot["skillTitles"] as? [String: String]) ?? [:]
        let extraTitles: [String: String] = [
            "tfng": "True / False / Not Given",
            "ynng": "Yes / No / Not Given",
            "matching_headings": "Matching Headings",
            "matching_information": "Matching Information",
            "matching_features": "Matching Features",
            "matching_endings": "Matching Sentence Endings",
            "multiple_choice": "Multiple Choice",
            "summary_completion": "Summary Completion",
            "diagram_labeling": "Map & Diagram Labeling",
            "scanning": "Scanning for Detail",
            "inference": "Inference & Tone",
            "paraphrasing": "Paraphrasing & Synonyms",
            "main_idea": "Main Idea & Global Meaning",
            "listening_detail": "Listening for Detail",
            "distractor_correction": "Self-Correction Distractors",
            "numbers": "Numbers, Dates & Prices",
            "alphanumeric": "Spelling & Codes",
            "map_labeling": "Map & Spatial Directions",
            "flowchart": "Flowchart & Process Sequence",
            "lecture_notes": "Academic Lecture Note Completion"
        ]
        for (k, v) in extraTitles where skillTitles[k] == nil {
            skillTitles[k] = v
        }

        var output = existingRoot
        output["version"] = "4.0.0"
        output["exportedAt"] = ISO8601DateFormatter().string(from: Date())
        output["exams"] = mergedExams
        output["skillTitles"] = skillTitles
        output["grammarLessons"] = try toJSONObject(GrammarCurriculum.lessons)
        output["vocabulary"] = try toJSONObject(VocabularyBank.defaultVocabularyItems())
        output["academicUnits"] = try toJSONObject(AcademicEnglishContent.units)
        output["writingSamples"] = try toJSONObject(WritingModelSamples.samples)
        output["sources"] = try toJSONObject(OfficialKnowledgeBase.sources)
        output["knowledgeDocs"] = try toJSONObject(OfficialKnowledgeBase.documents)

        try FileManager.default.createDirectory(at: outURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let finalData = try JSONSerialization.data(withJSONObject: output, options: [.sortedKeys])
        try finalData.write(to: outURL)

        let mockCount = mergedExams.filter { ($0["pool"] as? String) == "mock" }.count
        let practiceCount = mergedExams.filter { ($0["pool"] as? String) == "practice" }.count
        print("Exported content.json v3.0.0: \(mergedExams.count) total exams (\(mockCount) Full Mock + \(practiceCount) Practice Pool), \(GrammarCurriculum.lessons.count) grammar lessons, \(VocabularyBank.defaultVocabularyItems().count) vocabulary items, \(AcademicEnglishContent.units.count) academic units, \(OfficialKnowledgeBase.sources.count) verified sources, \(OfficialKnowledgeBase.documents.count) RAG docs.")
    }
}
