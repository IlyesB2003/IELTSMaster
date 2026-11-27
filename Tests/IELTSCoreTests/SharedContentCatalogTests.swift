import XCTest
@testable import IELTSCore

final class SharedContentCatalogTests: XCTestCase {
    func testBundledCatalogDecodesAndSeparatesAllFourPracticeSkills() {
        let catalog = SharedContentCatalog.bundled
        XCTAssertTrue(catalog.mockExams.contains { $0.id == "exam22" })
        XCTAssertTrue(catalog.mockExams.allSatisfy { $0.totalListeningQuestions == 40 && $0.totalReadingQuestions == 40 })
        XCTAssertGreaterThanOrEqual(catalog.reading.count, 200)
        XCTAssertGreaterThanOrEqual(catalog.listening.count, 200)
        XCTAssertGreaterThanOrEqual(catalog.writing1.count + catalog.writing2.count, 200)
        XCTAssertGreaterThanOrEqual(catalog.speaking.count, 200)
        let mockIDs = Set(catalog.mockExams.flatMap {
            $0.readingPassages.flatMap(\.questions).map(\.id) + $0.listeningParts.flatMap(\.questions).map(\.id)
        })
        let practiceQuestions = catalog.reading.flatMap(\.questions) + catalog.listening.flatMap(\.questions)
        XCTAssertTrue(mockIDs.isDisjoint(with: practiceQuestions.map(\.id)))
        XCTAssertEqual(Set(practiceQuestions.map(\.id)).count, practiceQuestions.count)
        XCTAssertTrue(catalog.reading.allSatisfy { (2...4).contains($0.questions.count) })
        XCTAssertTrue(catalog.listening.allSatisfy { (2...4).contains($0.questions.count) })
        let mockWritingIDs = Set(catalog.mockExams.flatMap { [$0.writingTask1.id, $0.writingTask2.id] })
        XCTAssertTrue(mockWritingIDs.isDisjoint(with: catalog.writing1.map(\.id) + catalog.writing2.map(\.id)))
        XCTAssertTrue(Set(catalog.mockExams.map { $0.speakingSet.id }).isDisjoint(with: catalog.speaking.map(\.id)))
    }
}
