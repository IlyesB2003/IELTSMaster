import Foundation
import NaturalLanguage
import Accelerate

public struct RAGChunk: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let documentID: String
    public let documentTitle: String
    public let category: String
    public let module: String
    public let sourceName: String
    public let sourceURL: String
    public let version: Int
    public let text: String
    public let tokenFrequencies: [String: Double]
    public let vector: [Float]

    public init(
        id: String,
        documentID: String,
        documentTitle: String,
        category: String,
        module: String,
        sourceName: String,
        sourceURL: String,
        version: Int,
        text: String,
        tokenFrequencies: [String: Double],
        vector: [Float]
    ) {
        self.id = id
        self.documentID = documentID
        self.documentTitle = documentTitle
        self.category = category
        self.module = module
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.version = version
        self.text = text
        self.tokenFrequencies = tokenFrequencies
        self.vector = vector
    }
}

public struct RAGSearchResult: Identifiable, Sendable {
    public let id: String
    public let chunk: RAGChunk
    public let score: Double
    public let lexicalScore: Double
    public let semanticScore: Double

    public var citation: String {
        "\(chunk.documentTitle) — \(chunk.sourceName) (\(chunk.sourceURL))"
    }
}

public struct RAGRetrievalMetrics: Sendable {
    public let totalDocuments: Int
    public let totalChunks: Int
    public let averageChunkTokens: Double
    public let embeddingDimension: Int
    public let usesAppleNLEmbedding: Bool
}

/// Local-first Retrieval-Augmented Generation engine.
/// Uses deterministic chunking with overlap, BM25-style lexical scoring,
/// Apple NaturalLanguage word embeddings + Accelerate vDSP cosine similarity,
/// metadata filtering, and source citation formatting.
public final class RAGService: @unchecked Sendable {
    private var chunks: [RAGChunk] = []
    private var documentCount: Int = 0
    private var idfTable: [String: Double] = [:]
    private let embeddingDimension = 64
    private let nlEmbedding: NLEmbedding?
    private let lock = NSLock()

    public init(documents: [KnowledgeDocument] = OfficialKnowledgeBase.documents) {
        self.nlEmbedding = NLEmbedding.wordEmbedding(for: .english)
        ingest(documents: documents)
    }

    public func ingest(documents: [KnowledgeDocument], maxChunkWords: Int = 90, overlapWords: Int = 18) {
        lock.lock()
        defer { lock.unlock() }

        var newChunks: [RAGChunk] = []
        for doc in documents {
            let splitTexts = chunkText(doc.content, maxWords: maxChunkWords, overlap: overlapWords)
            for (idx, chunkStr) in splitTexts.enumerated() {
                let tokens = tokenize(chunkStr + " " + doc.title + " " + doc.category)
                let tf = termFrequencies(tokens)
                let vec = computeVector(tokens: tokens)
                let chunk = RAGChunk(
                    id: "\(doc.id)-chunk-\(idx)",
                    documentID: doc.id,
                    documentTitle: doc.title,
                    category: doc.category,
                    module: doc.module,
                    sourceName: doc.sourceName,
                    sourceURL: doc.sourceURL,
                    version: doc.version,
                    text: chunkStr,
                    tokenFrequencies: tf,
                    vector: vec
                )
                newChunks.append(chunk)
            }
        }

        // Deduplicate by chunk ID while allowing updates
        var map = Dictionary(uniqueKeysWithValues: chunks.map { ($0.id, $0) })
        for c in newChunks {
            map[c.id] = c
        }
        chunks = Array(map.values).sorted { $0.id < $1.id }
        documentCount = Set(chunks.map { $0.documentID }).count
        rebuildIDF()
    }

    public func search(
        query: String,
        topK: Int = 4,
        moduleFilter: String? = nil,
        categoryFilter: String? = nil
    ) -> [RAGSearchResult] {
        lock.lock()
        let snapshot = chunks
        let idf = idfTable
        lock.unlock()

        let queryTokens = tokenize(query)
        guard !queryTokens.isEmpty else { return [] }
        let queryVec = computeVector(tokens: queryTokens)

        let filtered = snapshot.filter { chunk in
            if let mod = moduleFilter, !mod.isEmpty, mod != "All" {
                if chunk.module.caseInsensitiveCompare(mod) != .orderedSame && chunk.module != "General" {
                    return false
                }
            }
            if let cat = categoryFilter, !cat.isEmpty, cat != "All" {
                if chunk.category.caseInsensitiveCompare(cat) != .orderedSame {
                    return false
                }
            }
            return true
        }

        var results: [RAGSearchResult] = []
        for chunk in filtered {
            // Lexical BM25-inspired TF-IDF dot score
            var lex = 0.0
            for token in Set(queryTokens) {
                if let tf = chunk.tokenFrequencies[token] {
                    let weight = idf[token] ?? 1.0
                    lex += tf * weight
                }
            }
            // Semantic cosine similarity via Accelerate vDSP
            let sem = Double(max(0.0, cosineSimilarity(queryVec, chunk.vector)))
            let combined = (lex * 0.65) + (sem * 0.35)
            if combined > 0.05 {
                results.append(RAGSearchResult(
                    id: chunk.id,
                    chunk: chunk,
                    score: combined,
                    lexicalScore: lex,
                    semanticScore: sem
                ))
            }
        }

        return results.sorted { $0.score > $1.score }.prefix(topK).map { $0 }
    }

    public func buildGroundedContext(for query: String, module: String? = nil, topK: Int = 3) -> (context: String, citations: [String]) {
        let hits = search(query: query, topK: topK, moduleFilter: module)
        guard !hits.isEmpty else { return ("", []) }
        let context = hits.enumerated().map { idx, hit in
            "[\(idx + 1)] \(hit.chunk.documentTitle) (\(hit.chunk.sourceName)):\n\(hit.chunk.text)"
        }.joined(separator: "\n\n")
        let citations = Array(NSOrderedSet(array: hits.map { $0.citation })) as? [String] ?? []
        return (context, citations)
    }

    public func metrics() -> RAGRetrievalMetrics {
        lock.lock()
        defer { lock.unlock() }
        let totalWords = chunks.reduce(0) { $0 + $1.text.split { $0.isWhitespace }.count }
        let avg = chunks.isEmpty ? 0 : Double(totalWords) / Double(chunks.count)
        return RAGRetrievalMetrics(
            totalDocuments: documentCount,
            totalChunks: chunks.count,
            averageChunkTokens: avg,
            embeddingDimension: embeddingDimension,
            usesAppleNLEmbedding: nlEmbedding != nil
        )
    }

    // MARK: - Helpers

    private func chunkText(_ text: String, maxWords: Int, overlap: Int) -> [String] {
        let words = text.split { $0.isWhitespace || $0.isNewline }.map(String.init)
        guard !words.isEmpty else { return [] }
        if words.count <= maxWords { return [words.joined(separator: " ")] }

        var result: [String] = []
        var start = 0
        let step = max(1, maxWords - overlap)
        while start < words.count {
            let end = min(words.count, start + maxWords)
            result.append(words[start..<end].joined(separator: " "))
            if end == words.count { break }
            start += step
        }
        return result
    }

    private func tokenize(_ text: String) -> [String] {
        let stopwords: Set<String> = [
            "the", "a", "an", "and", "or", "of", "to", "in", "on", "for", "with", "is", "are", "was", "were", "be", "by", "as", "at", "that", "this", "it", "from"
        ]
        return text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 && !stopwords.contains($0) }
    }

    private func termFrequencies(_ tokens: [String]) -> [String: Double] {
        guard !tokens.isEmpty else { return [:] }
        var counts: [String: Int] = [:]
        for t in tokens { counts[t, default: 0] += 1 }
        let total = Double(tokens.count)
        return counts.mapValues { (Double($0) / total) * 10.0 }
    }

    private func rebuildIDF() {
        let n = Double(max(chunks.count, 1))
        var df: [String: Int] = [:]
        for c in chunks {
            for token in c.tokenFrequencies.keys {
                df[token, default: 0] += 1
            }
        }
        idfTable = df.mapValues { count in
            log((n + 1.0) / (Double(count) + 1.0)) + 1.0
        }
    }

    /// Computes a normalized 64-dim vector using Apple NLEmbedding when available,
    /// blended with deterministic hashed-feature projection for 100% offline reliability.
    private func computeVector(tokens: [String]) -> [Float] {
        var acc = [Float](repeating: 0, count: embeddingDimension)
        guard !tokens.isEmpty else { return acc }

        for token in tokens {
            if let nlVec = nlEmbedding?.vector(for: token), !nlVec.isEmpty {
                let limit = min(embeddingDimension, nlVec.count)
                for i in 0..<limit {
                    acc[i] += Float(nlVec[i])
                }
            } else {
                // Deterministic signed feature hashing fallback
                var hash: UInt64 = 1469598103934665603
                for b in token.utf8 {
                    hash ^= UInt64(b)
                    hash = hash &* 1099511628211
                }
                let bucket = Int(hash % UInt64(embeddingDimension))
                let sign: Float = ((hash >> 8) & 1) == 0 ? 1.0 : -1.0
                acc[bucket] += sign
            }
        }

        // L2 normalize via Accelerate vDSP
        var sumSq: Float = 0
        vDSP_svesq(acc, 1, &sumSq, vDSP_Length(embeddingDimension))
        let norm = sqrt(sumSq)
        if norm > 1e-6 {
            var invNorm = 1.0 / norm
            vDSP_vsmul(acc, 1, &invNorm, &acc, 1, vDSP_Length(embeddingDimension))
        }
        return acc
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dot: Float = 0
        vDSP_dotpr(a, 1, b, 1, &dot, vDSP_Length(a.count))
        return dot
    }
}
