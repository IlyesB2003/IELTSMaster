# IELTS Master — Technical Architecture

## 1. Module Layout

```
IELTSMaster/
├── Package.swift
├── Sources/
│   ├── IELTSCore/                    # Reusable, testable domain & engine library
│   │   ├── Models/                   # DomainModels.swift, AIModels.swift
│   │   ├── Scoring/                  # IELTSScoringEngine.swift, ExamTimerEngine.swift
│   │   ├── Database/                 # DatabaseManager.swift (SQLite3 WAL + migrations)
│   │   ├── Knowledge/                # OfficialKnowledgeBase.swift, RAGService.swift
│   │   ├── Curriculum/               # MockExamBank.swift + AuthoredExams/ (hand-written exams), ContentValidator.swift,
│   │   │                             # GrammarCurriculum.swift (20 topics), VocabularyBank.swift,
│   │   │                             # AcademicEnglishContent.swift, WritingModelSamples.swift
│   │   ├── Adaptive/                 # AdaptiveLearningEngine.swift (SM-2, Mastery, Plans)
│   │   ├── AI/                       # LocalLLMService.swift, AITeacherService.swift,
│   │   │                             # AssessmentService.swift, KeychainService.swift
│   │   └── Audio/                    # AudioEngineService.swift (AVFoundation + Speech)
│   ├── IELTSMaster/                  # Native macOS SwiftUI Application
│   │   ├── DesignSystem/             # DesignTokens.swift (Typography, Spacing, Flat Surfaces, RTL)
│   │   ├── State/                    # AppState.swift (@MainActor coordinator)
│   │   ├── Views/                    # All 17 sidebar sections + DiagnosticPlacementView
│   │   └── main.swift                # App entry point & native macOS menu shortcuts
│   └── IELTSTestRunner/              # Standalone ARM64 test runner executable
├── Tests/IELTSCoreTests/             # XCTest suite (for Xcode IDE execution)
├── Scripts/build_and_package.sh      # Release .app bundle + codesign + .dmg builder
└── Docs/                             # Architecture, Attribution, and Engineering Report
```

## 2. Apple Silicon (M4 / 16 GB Unified Memory) Optimization

- **Zero External Runtime Overhead**: Pure native Swift + Apple system frameworks (`Accelerate`, `NaturalLanguage`, `AVFoundation`, `Charts`, `SQLite3`, `Security`).
- **Vector Math Acceleration**: `RAGService` uses `Accelerate` (`vDSP_svesq`, `vDSP_vsmul`, `vDSP_dotpr`) for L2 normalization and cosine similarity.
- **16 GB Memory Budgeting**: `LocalLLMService` inspects `/api/tags` and `/api/ps`, estimates loaded RAM (`disk_size * 1.25`), caps concurrent loaded models at 1 by default (`keep_alive: "2m"`), and prioritizes 4–9.5 GB models (7B–9B quantized) over >12 GB models.
- **Deterministic Code First**: Timers, raw-to-band conversion, `.25`/`.75` rounding, word counting, WPM calculation, SM-2 intervals, and objective grading are 100% deterministic Swift code — never delegated to LLMs.

## 3. Privacy & Local-First Persistence

- Primary SQLite3 database stored locally in `~/Library/Application Support/IELTSMaster/ielts_master.sqlite` (WAL mode, versioned `schema_migrations`).
- Recordings stored locally in `~/Library/Application Support/IELTSMaster/Recordings/` with configurable retention purge (`audioRetentionDays`).
- Optional external AI API keys stored exclusively in macOS Keychain (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`), and external requests are blocked unless `externalAIConsentGranted == true`.
