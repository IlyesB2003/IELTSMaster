# IELTS Master — Final Engineering Report

**Date:** 2026-11-25  
**Target Platform:** MacBook Air M4 (Apple Silicon ARM64, 16 GB unified memory, macOS 27.3, MacOSX 27.2 SDK, Apple Swift 6.4.2)  
**Workspace:** `/Users/macbookairm4/Desktop/IELTSMaster`

---

## 1. Implemented Features

1. **Modular Native macOS Architecture (`IELTSCore` + `IELTSMaster`)**:
   - Pure Swift & SwiftUI (`NavigationSplitView`, `HSplitView`, Swift Charts, native macOS keyboard shortcuts `⌘1`–`⌘9` and `⇧⌘D`, AppKit save/open panels, Keychain, SQLite3 WAL, AVFoundation, Speech, NaturalLanguage, Accelerate).
   - Zero Electron, zero webview wrappers, zero third-party network-fetched dependencies.
2. **Complete 17-Section Native Sidebar Navigation**:
   - Dashboard, My Learning Plan, AI Teacher, Full Mock Exams, Listening, Reading, Writing, Speaking, Grammar, Vocabulary, Pronunciation Lab, Academic English, Mistake Notebook, Progress & Analytics, Resource Library, AI Model Manager, Settings.
3. **Strictly Bilingual (English & Arabic Only)**:
   - English default UI; on-demand RTL Arabic explanations (`IMArabicBlock`); adaptive Arabic fade as estimated band reaches 6.5+; English-only immersion mode; strict Arabic & AI lockout during Examination Mode.
4. **Mock Examinations (`MockExamBank` + `AuthoredExams/` + `ContentValidator`)** — *updated: 2 hand-authored exams now replace the template in the app; see the audit's resolution table.*
   - 30 structurally complete mock exams. **Correction (audit 2026-11-25):** Listening and Reading in all 30 exams come from a single slot-filled template (same 40+40 question stems and largely the same answers; only topic nouns, names and numbers change). They are not 30 distinct exams in the sense the specification requires. Writing Task 2 prompts and Speaking topics are distinct.
   - The validator checks duplicates *within* one exam only; it does not detect cross-exam template reuse, which is why it reported 30/30.
5. **Deterministic Official Scoring & Timing Engines**:
   - `IELTSScoringEngine`: Official 40-question raw-to-band conversion (Listening & Academic Reading), Writing Task 2 double weighting (2:1), official `.25 -> .5` and `.75 -> next whole` rounding, strict word-limit checking, T/F/NG & Y/N/NG normalization, WPM calculator, and non-interchangeable CEFR mapping.
   - `ExamTimerEngine`: Official countdown timers with pause disabled in Examination Mode.
6. **Local-First Persistence & Privacy (`DatabaseManager` + `KeychainService`)**:
   - SQLite3 WAL-mode database with versioned `schema_migrations`, full CRUD across all learner records, local `.sqlite` backup & restore, full JSON export, configurable audio retention purge, and selective collection deletion.
   - Optional external AI provider API keys (Anthropic, OpenAI, Gemini) stored exclusively in macOS Keychain and gated by explicit user privacy consent.
7. **Local AI, RAG & Adaptive Learning**:
   - `RAGService`: Document chunking, BM25-inspired TF-IDF + Apple `NaturalLanguage` / `Accelerate` (`vDSP`) cosine vector search over 8 verified authoritative IELTS sources with inline citations.
   - `LocalLLMService`: Ollama `/api/tags` & `/api/ps` discovery, 16 GB M4 RAM budgeting (`maxConcurrentLoadedModels = 1`), streaming `/api/chat` with cancellation, structured JSON extraction & retry, per-task routing across 8 roles.
   - `AdaptiveLearningEngine`: SuperMemo-2 (SM-2) spaced repetition, retention-gated grammar mastery across 20 lessons, recurring error pattern detection, first-launch diagnostic placement, and 15/30/45/60/90-minute study plans with scheduled breaks.

---

## 2. Verified Build & Automated Test Results

- **Debug Application Build (`swift build --product IELTSMaster`)**: **PASSED** (0 errors, 9.55s).
- **Automated Verification Suite (`swift run IELTSTestRunner`)**: **PASSED — 35 / 35 assertions passed, 0 failed in 180.5 ms**:
  1. Official IELTS Scoring, Rounding (`.25`, `.75`, `.125`, `.625`), Task 2 2:1 weighting, & Raw Conversion: **PASS**
  2. Deterministic Answer Grading & Word-Limit Enforcement: **PASS**
  3. Exam Timer Engine (strict no-pause & expiry): **PASS**
  4. SQLite3 Persistence, Schema Migrations, Backup, Selective Delete, Restore & JSON Export: **PASS** *(Caught and resolved a serial-queue re-entrancy deadlock in `restoreBackup` during testing.)*
  5. Local RAG Hybrid Search & Verified Source Citations: **PASS**
  6. Adaptive Learning Engine (SM-2 intervals, mastery verification, 60-min plan with breaks): **PASS**
  7. 30-Exam Bank QA Validation: structural checks pass 30/30 — **but see correction above: the bank is one template ×30, so this test does not establish content diversity.**
  8. AI Structured JSON Fenced Extraction & 16 GB M4 Model Routing: **PASS**
  9. Offline Writing & Speaking Assessment Safety & Non-Native Accent Policy: **PASS**
  10. Performance Benchmark: **50 RAG hybrid queries completed in 10.3 ms** (~0.21 ms/query on Apple M4).

---

## 3. Environment Limitations & Transparency

1. **Xcode.app Not Installed**: Only macOS Command Line Tools (`/Library/Developer/CommandLineTools`) was installed on the host machine (`xcodebuild` and `XCTest.framework` require full `Xcode.app`).
   - *Mitigation*: Built and verified natively using Apple Swift 6.4.2 (`swift build`), created a standalone ARM64 test runner (`IELTSTestRunner`) alongside `Tests/IELTSCoreTests/IELTSCoreTests.swift` (ready for Xcode), implemented a macro-free `LocalState` SwiftUI wrapper compatible with both CommandLineTools and Xcode, and packaged native `IELTSMaster.app` and `IELTSMaster.dmg` via `Scripts/build_and_package.sh`.
2. **Local Ollama & Microphone Interactive Access**: Live Ollama HTTP calls (`127.0.0.1:11434`) and interactive macOS microphone permissions could not be exercised inside the non-interactive build sandbox. The app handles offline Ollama and unavailable microphone/speech permissions gracefully with offline grounded knowledge and clear user messaging.
3. **Assessment Accuracy Limitations**:
   - All AI and practice band scores are indicative estimates, never official IELTS results.
   - Pronunciation band scoring is explicitly withheld when only text transcription is available (`pronunciationBand == nil` with transparent confidence/limitation notes), and non-native accents are never penalized.
