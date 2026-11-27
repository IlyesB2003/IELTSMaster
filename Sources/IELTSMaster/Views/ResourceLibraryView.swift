import SwiftUI
import IELTSCore

public struct ResourceLibraryView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var ragQuery: String = "writing task 2 assessment criteria"
    @LocalState private var ragResults: [RAGSearchResult] = []
    @LocalState private var qaSummary: String = ""

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Resource library & RAG knowledge base",
                    subtitle: "Authoritative IELTS educational references with verified attribution, local vector/BM25 retrieval inspection, and automated Mock Exam Quality Assurance validation.",
                    badgeText: "\(OfficialKnowledgeBase.sources.count) Verified Sources"
                )

                // Local RAG Inspector
                IMCard {
                    let m = app.rag.metrics()
                    HStack {
                        Text("Local RAG knowledge retrieval").imText(.title2)
                        Spacer()
                        IMBadge(text: "\(m.totalDocuments) docs • \(m.totalChunks) chunks • \(m.embeddingDimension)d")
                    }
                    HStack {
                        TextField("Query official IELTS criteria, scoring, or strategies...", text: $ragQuery)
                            .textFieldStyle(.roundedBorder)
                        Button("Retrieve chunks") {
                            ragResults = app.rag.search(query: ragQuery, topK: 4)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    ForEach(ragResults) { hit in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(hit.chunk.documentTitle).imText(.body4)
                                Spacer()
                                IMBadge(text: String(format: "Score %.2f", hit.score))
                            }
                            Text(hit.chunk.text).imText(.caption2).foregroundStyle(.secondary)
                            Text("Source: \(hit.citation)").imText(.caption5).foregroundStyle(IMTheme.accentPrimary)
                        }
                        Divider()
                    }
                }

                // Content QA Validator
                IMCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mock examination bank QA validation").imText(.title2)
                            Text("Verifies all \(app.mockExams.count) mock exams for exact 40+40 question counts, evidence-passage consistency, zero duplicate prompts, and non-official provenance labeling.")
                                .imText(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Run full QA audit") {
                            let audit = app.validator.validateBank(app.mockExams)
                            qaSummary = "QA Audit complete: \(audit.passedCount) / \(audit.totalCount) mock exams passed all structural, evidence, uniqueness, and provenance checks."
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    if !qaSummary.isEmpty {
                        Text(qaSummary).imText(.body4).foregroundStyle(IMTheme.statusSuccess)
                    }
                }

                // Verified Authoritative Sources
                IMCard {
                    Text("Authoritative source attribution registry").imText(.title2)
                    ForEach(OfficialKnowledgeBase.sources) { src in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(src.sourceName).imText(.body4)
                                Spacer()
                                IMBadge(text: src.verificationStatus, tint: IMTheme.statusSuccess)
                                IMBadge(text: src.category)
                            }
                            Text(src.summary).imText(.body6).foregroundStyle(.secondary)
                            Text("URL: \(src.originalURL) • Accessed: \(src.accessDate)").imText(.caption5).foregroundStyle(IMTheme.accentPrimary)
                            Text("License & copyright: \(src.copyrightAndLicense)").imText(.caption5).foregroundStyle(.secondary)
                        }
                        Divider()
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
        .onAppear {
            if ragResults.isEmpty {
                ragResults = app.rag.search(query: ragQuery, topK: 3)
            }
        }
    }
}
