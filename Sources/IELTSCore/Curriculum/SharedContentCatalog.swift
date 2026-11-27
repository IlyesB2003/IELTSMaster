import Foundation

/// Shared original content. Practice arrays contain no full-mock questions or prompts.
/// Regenerate with `node Scripts/sync_native_content.mjs` after changing source content.
public struct SharedContentCatalog: Decodable, Sendable {
    public let mockExams: [MockExam]
    public let reading: [ReadingPassage]
    public let listening: [ListeningPart]
    public let writing1: [WritingTask1Prompt]
    public let writing2: [WritingTask2Prompt]
    public let speaking: [SpeakingPromptSet]

    public static let bundled: SharedContentCatalog = {
        guard let url = Bundle.module.url(forResource: "catalog", withExtension: "json", subdirectory: "Content") else {
            preconditionFailure("Missing bundled content. Run node Scripts/sync_native_content.mjs before building.")
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let catalog = try decoder.decode(Self.self, from: Data(contentsOf: url))
            precondition(!catalog.mockExams.isEmpty && !catalog.writing1.isEmpty && !catalog.writing2.isEmpty && !catalog.speaking.isEmpty,
                         "Bundled content has an empty required bank")
            return catalog
        } catch {
            preconditionFailure("Cannot decode bundled IELTS content: \(error)")
        }
    }()
}
