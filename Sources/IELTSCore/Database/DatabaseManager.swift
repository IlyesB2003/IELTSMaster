import Foundation
import SQLite3

public enum DatabaseError: Error, LocalizedError, Sendable {
    case openFailed(String)
    case executionFailed(String)
    case backupFailed(String)
    case exportFailed(String)

    public var errorDescription: String? {
        switch self {
        case .openFailed(let m): return "Database open failed: \(m)"
        case .executionFailed(let m): return "Database execution failed: \(m)"
        case .backupFailed(let m): return "Database backup failed: \(m)"
        case .exportFailed(let m): return "Data export failed: \(m)"
        }
    }
}

/// Local-first SQLite3 persistence layer with WAL mode, versioned schema migrations,
/// backup/restore, full JSON export, selective deletion, and audio retention cleanup.
public final class DatabaseManager: @unchecked Sendable {
    public let databaseURL: URL
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.ieltsmaster.sqlite", qos: .userInitiated)
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public static var defaultDatabaseURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let dir = appSupport.appendingPathComponent("IELTSMaster", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("ielts_master.sqlite")
    }

    public init(databaseURL: URL = DatabaseManager.defaultDatabaseURL) throws {
        self.databaseURL = databaseURL
        let parent = databaseURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = [.sortedKeys]

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        try open()
        try runMigrations()
    }

    deinit {
        if let db {
            sqlite3_close(db)
        }
    }

    private func open() throws {
        var handle: OpaquePointer?
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        if sqlite3_open_v2(databaseURL.path, &handle, flags, nil) != SQLITE_OK {
            let msg = handle.map { String(cString: sqlite3_errmsg($0)) } ?? "Unknown SQLite error"
            sqlite3_close(handle)
            throw DatabaseError.openFailed(msg)
        }
        self.db = handle
        try execute("PRAGMA journal_mode = WAL;")
        try execute("PRAGMA foreign_keys = ON;")
        try execute("PRAGMA synchronous = NORMAL;")
    }

    private func execute(_ sql: String) throws {
        guard let db else { throw DatabaseError.openFailed("Database handle is closed.") }
        var errMsg: UnsafeMutablePointer<CChar>?
        if sqlite3_exec(db, sql, nil, nil, &errMsg) != SQLITE_OK {
            let msg = errMsg.map { String(cString: $0) } ?? "SQLite error"
            sqlite3_free(errMsg)
            throw DatabaseError.executionFailed(msg)
        }
    }

    // MARK: - Versioned Schema Migrations

    public func currentSchemaVersion() -> Int {
        queue.sync {
            currentSchemaVersionUnlocked()
        }
    }

    private func currentSchemaVersionUnlocked() -> Int {
        guard let db else { return 0 }
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        if sqlite3_prepare_v2(db, "SELECT COALESCE(MAX(version), 0) FROM schema_migrations;", -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                return Int(sqlite3_column_int(stmt, 0))
            }
        }
        return 0
    }

    private func runMigrations() throws {
        try execute("""
        CREATE TABLE IF NOT EXISTS schema_migrations (
            version INTEGER PRIMARY KEY,
            applied_at TEXT NOT NULL
        );
        """)

        let current = currentSchemaVersionUnlocked()
        if current < 1 {
            let v1SQL = """
            CREATE TABLE IF NOT EXISTS kv_records (
                collection TEXT NOT NULL,
                id TEXT NOT NULL,
                updated_at REAL NOT NULL,
                payload TEXT NOT NULL,
                PRIMARY KEY (collection, id)
            );
            CREATE INDEX IF NOT EXISTS idx_kv_collection_updated ON kv_records(collection, updated_at DESC);

            CREATE TABLE IF NOT EXISTS exam_attempts (
                id TEXT PRIMARY KEY,
                exam_id TEXT NOT NULL,
                module TEXT NOT NULL,
                overall_band REAL NOT NULL,
                created_at REAL NOT NULL,
                payload TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_attempts_date ON exam_attempts(created_at DESC);

            CREATE TABLE IF NOT EXISTS mistakes (
                id TEXT PRIMARY KEY,
                category TEXT NOT NULL,
                mastery_status TEXT NOT NULL,
                recurrence_count INTEGER NOT NULL,
                next_revision_at REAL NOT NULL,
                payload TEXT NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_mistakes_category ON mistakes(category);
            CREATE INDEX IF NOT EXISTS idx_mistakes_revision ON mistakes(next_revision_at);

            CREATE TABLE IF NOT EXISTS rag_chunks (
                id TEXT PRIMARY KEY,
                doc_id TEXT NOT NULL,
                category TEXT NOT NULL,
                source_name TEXT NOT NULL,
                content TEXT NOT NULL,
                embedding_json TEXT NOT NULL,
                version INTEGER NOT NULL DEFAULT 1
            );
            CREATE INDEX IF NOT EXISTS idx_rag_category ON rag_chunks(category);

            INSERT INTO schema_migrations (version, applied_at) VALUES (1, datetime('now'));
            """
            try execute(v1SQL)
        }
    }

    // MARK: - Generic Collection Operations

    public func upsert<T: Codable>(_ value: T, id: String, collection: String) throws {
        let data = try encoder.encode(value)
        guard let json = String(data: data, encoding: .utf8) else {
            throw DatabaseError.executionFailed("Failed to encode UTF-8 JSON for \(collection)/\(id)")
        }
        try queue.sync {
            guard let db else { throw DatabaseError.openFailed("Closed") }
            let sql = """
            INSERT INTO kv_records (collection, id, updated_at, payload)
            VALUES (?1, ?2, ?3, ?4)
            ON CONFLICT(collection, id) DO UPDATE SET updated_at = excluded.updated_at, payload = excluded.payload;
            """
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
            let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            sqlite3_bind_text(stmt, 1, collection, -1, transient)
            sqlite3_bind_text(stmt, 2, id, -1, transient)
            sqlite3_bind_double(stmt, 3, Date().timeIntervalSince1970)
            sqlite3_bind_text(stmt, 4, json, -1, transient)
            guard sqlite3_step(stmt) == SQLITE_DONE else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
        }
    }

    public func fetchAll<T: Codable>(_ type: T.Type, collection: String) throws -> [T] {
        try queue.sync {
            guard let db else { throw DatabaseError.openFailed("Closed") }
            let sql = "SELECT payload FROM kv_records WHERE collection = ?1 ORDER BY updated_at DESC;"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
            let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            sqlite3_bind_text(stmt, 1, collection, -1, transient)
            var results: [T] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let cStr = sqlite3_column_text(stmt, 0) {
                    let str = String(cString: cStr)
                    if let data = str.data(using: .utf8), let obj = try? decoder.decode(T.self, from: data) {
                        results.append(obj)
                    }
                }
            }
            return results
        }
    }

    public func fetchOne<T: Codable>(_ type: T.Type, id: String, collection: String) throws -> T? {
        try queue.sync {
            guard let db else { throw DatabaseError.openFailed("Closed") }
            let sql = "SELECT payload FROM kv_records WHERE collection = ?1 AND id = ?2 LIMIT 1;"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
            let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            sqlite3_bind_text(stmt, 1, collection, -1, transient)
            sqlite3_bind_text(stmt, 2, id, -1, transient)
            if sqlite3_step(stmt) == SQLITE_ROW, let cStr = sqlite3_column_text(stmt, 0) {
                let str = String(cString: cStr)
                if let data = str.data(using: .utf8) {
                    return try decoder.decode(T.self, from: data)
                }
            }
            return nil
        }
    }

    public func delete(id: String, collection: String) throws {
        try queue.sync {
            guard let db else { throw DatabaseError.openFailed("Closed") }
            let sql = "DELETE FROM kv_records WHERE collection = ?1 AND id = ?2;"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
            let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            sqlite3_bind_text(stmt, 1, collection, -1, transient)
            sqlite3_bind_text(stmt, 2, id, -1, transient)
            guard sqlite3_step(stmt) == SQLITE_DONE else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
        }
    }

    public func deleteCollection(_ collection: String) throws {
        try queue.sync {
            guard let db else { throw DatabaseError.openFailed("Closed") }
            let sql = "DELETE FROM kv_records WHERE collection = ?1;"
            var stmt: OpaquePointer?
            defer { sqlite3_finalize(stmt) }
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
            let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            sqlite3_bind_text(stmt, 1, collection, -1, transient)
            guard sqlite3_step(stmt) == SQLITE_DONE else {
                throw DatabaseError.executionFailed(String(cString: sqlite3_errmsg(db)))
            }
        }
    }

    // MARK: - Typed Domain Helpers

    public func saveProfile(_ profile: LearnerProfile) throws {
        try upsert(profile, id: profile.id, collection: "learner_profile")
    }

    public func loadProfile() throws -> LearnerProfile {
        if let existing = try fetchOne(LearnerProfile.self, id: "primary-learner", collection: "learner_profile") {
            return existing
        }
        let initial = LearnerProfile()
        try saveProfile(initial)
        return initial
    }

    public func saveAttempt(_ attempt: ExamAttemptRecord) throws {
        try upsert(attempt, id: attempt.id, collection: "exam_attempts")
    }

    public func loadAttempts() throws -> [ExamAttemptRecord] {
        try fetchAll(ExamAttemptRecord.self, collection: "exam_attempts")
            .sorted { $0.date > $1.date }
    }

    public func saveMistake(_ mistake: MistakeEntry) throws {
        try upsert(mistake, id: mistake.id, collection: "mistakes")
    }

    public func loadMistakes() throws -> [MistakeEntry] {
        try fetchAll(MistakeEntry.self, collection: "mistakes")
            .sorted { $0.occurredAt > $1.occurredAt }
    }

    public func saveEssay(_ essay: EssaySubmission) throws {
        try upsert(essay, id: essay.id, collection: "essays")
    }

    public func loadEssays() throws -> [EssaySubmission] {
        try fetchAll(EssaySubmission.self, collection: "essays")
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    public func saveRecording(_ rec: AudioRecordingRecord) throws {
        try upsert(rec, id: rec.id, collection: "audio_recordings")
    }

    public func loadRecordings() throws -> [AudioRecordingRecord] {
        try fetchAll(AudioRecordingRecord.self, collection: "audio_recordings")
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func saveVocabularyItem(_ item: VocabularyItem) throws {
        try upsert(item, id: item.id, collection: "vocabulary")
    }

    public func loadVocabularyItems() throws -> [VocabularyItem] {
        try fetchAll(VocabularyItem.self, collection: "vocabulary")
            .sorted { $0.word.lowercased() < $1.word.lowercased() }
    }

    public func saveGrammarProgress(_ progress: GrammarProgressRecord) throws {
        try upsert(progress, id: progress.id, collection: "grammar_progress")
    }

    public func loadGrammarProgress() throws -> [String: GrammarProgressRecord] {
        let list = try fetchAll(GrammarProgressRecord.self, collection: "grammar_progress")
        return Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
    }

    public func saveStudyPlan(_ plan: StudyPlan) throws {
        try upsert(plan, id: plan.id, collection: "study_plans")
    }

    public func loadLatestStudyPlan() throws -> StudyPlan? {
        try fetchAll(StudyPlan.self, collection: "study_plans")
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }

    public func saveTeacherMessage(_ message: TeacherMessage) throws {
        try upsert(message, id: message.id, collection: "teacher_messages")
    }

    public func loadTeacherMessages() throws -> [TeacherMessage] {
        try fetchAll(TeacherMessage.self, collection: "teacher_messages")
            .sorted { $0.timestamp < $1.timestamp }
    }

    public func saveModelRouting(_ config: ModelRoutingConfiguration) throws {
        try upsert(config, id: "routing", collection: "model_configs")
    }

    public func loadModelRouting() throws -> ModelRoutingConfiguration {
        if let existing = try fetchOne(ModelRoutingConfiguration.self, id: "routing", collection: "model_configs") {
            return existing
        }
        return ModelRoutingConfiguration()
    }

    // MARK: - Backup, Restore, Export, Retention

    public func createBackup(to destinationURL: URL) throws {
        try queue.sync {
            guard let db else { throw DatabaseError.openFailed("Closed") }
            sqlite3_wal_checkpoint_v2(db, nil, SQLITE_CHECKPOINT_TRUNCATE, nil, nil)
            let fm = FileManager.default
            if fm.fileExists(atPath: destinationURL.path) {
                try fm.removeItem(at: destinationURL)
            }
            try fm.copyItem(at: databaseURL, to: destinationURL)
        }
    }

    public func restoreBackup(from sourceURL: URL) throws {
        try queue.sync {
            if let db {
                sqlite3_close(db)
                self.db = nil
            }
            let fm = FileManager.default
            guard fm.fileExists(atPath: sourceURL.path) else {
                throw DatabaseError.backupFailed("Backup file does not exist.")
            }
            if fm.fileExists(atPath: databaseURL.path) {
                try fm.removeItem(at: databaseURL)
            }
            try fm.copyItem(at: sourceURL, to: databaseURL)
            try open()
            try runMigrations()
        }
    }

    public func exportAllDataJSON() throws -> Data {
        struct ExportBundle: Codable {
            let exportedAt: Date
            let schemaVersion: Int
            let profile: LearnerProfile
            let attempts: [ExamAttemptRecord]
            let mistakes: [MistakeEntry]
            let essays: [EssaySubmission]
            let recordings: [AudioRecordingRecord]
            let vocabulary: [VocabularyItem]
            let grammarProgress: [String: GrammarProgressRecord]
            let studyPlan: StudyPlan?
            let teacherMessages: [TeacherMessage]
            let modelRouting: ModelRoutingConfiguration
        }
        let bundle = ExportBundle(
            exportedAt: Date(),
            schemaVersion: currentSchemaVersion(),
            profile: try loadProfile(),
            attempts: try loadAttempts(),
            mistakes: try loadMistakes(),
            essays: try loadEssays(),
            recordings: try loadRecordings(),
            vocabulary: try loadVocabularyItems(),
            grammarProgress: try loadGrammarProgress(),
            studyPlan: try loadLatestStudyPlan(),
            teacherMessages: try loadTeacherMessages(),
            modelRouting: try loadModelRouting()
        )
        let prettyEncoder = JSONEncoder()
        prettyEncoder.dateEncodingStrategy = .iso8601
        prettyEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try prettyEncoder.encode(bundle)
    }

    /// Removes audio recording files and metadata older than `retentionDays`.
    @discardableResult
    public func purgeExpiredAudioRecordings(retentionDays: Int) throws -> Int {
        guard retentionDays > 0 else { return 0 }
        let cutoff = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()
        let recordings = try loadRecordings()
        var deletedCount = 0
        for rec in recordings where rec.createdAt < cutoff {
            try? FileManager.default.removeItem(atPath: rec.filePath)
            try delete(id: rec.id, collection: "audio_recordings")
            deletedCount += 1
        }
        return deletedCount
    }
}
