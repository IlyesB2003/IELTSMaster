# IELTS Master — Implementation Checklist

Status key: **Verified** = compiled and tested on the Mac (or checked by script against source) · **Written** = code in place, not yet compiled since the change · **Open** = not done.

Last updated: 2026-11-25 (evening session). Resume from the first **Open** item in "Next up".

## Session 3 (2026-11-25, late): redesign + adaptive practice (Written, not compiled)

- New: Smart Practice (`PracticeViews.swift`): unseen-first practice sets, weakness targeting, instant feedback, evidence highlighting, per-skill results. AI-generated passages with strict validation (`IELTSCore/AI/PracticeGenerator.swift`).
- New: Skills Coach (`SkillsCoachView.swift`) + `IELTSCore/Curriculum/StrategyLessons.swift` (12 lessons, EN + AR).
- New: skill tracking and exposure memory (`IELTSCore/Adaptive/SkillTracking.swift`, `Curriculum/PracticeSetBuilder.swift`), persisted in SQLite collections `skill_events`, `exposure_state`, `generated_reading`.
- Redesigned: design system, sidebar, Today dashboard, mock exam hub (attempt counts, retakes, recommendation). Minimum window 820×560.
- New icon on the macOS grid (transparent corners): `Scripts/generate_brand_logo.py`.
- `Scripts/dev.sh`: build → tests → package → 8-second launch check; logs in `.devlogs/`.
- Known: the previously packaged app quit immediately at launch on 2026-11-25; cause unknown (crash log not accessible). dev.sh captures launch output.

## Next up (in order)

1. **Open — run on the Mac:** `swift build && swift run IELTSTestRunner`. Fix any compile errors from this session's changes (files listed under "Changed this session").
2. **Open — Mock Exam 3**, then 4, 5… one at a time in `Sources/IELTSCore/Curriculum/AuthoredExams/AuthoredExamNN.swift`, added to `AuthoredExams.all`. Each needs:
   - 4 Listening parts, 10 questions each; scripts ideally 600–900 words per part (exams 1–2 run 425–575 words, so they're short).
   - 3 Reading passages of ≥ 600 words (target 750–900), 13/13/14 questions, mixed task types, 4-option MCQs.
   - Evidence quotes copied verbatim from the passage or script.
   - Topics and task types that differ from earlier exams.
   - Check: `python3 check_exam.py AuthoredExamNN.swift` (evidence + word counts), then the test runner (cross-exam check).
3. **Open — Listening audio length.** TTS at ~150 wpm gives ~12–15 min for exams 1–2, versus ~30 min in the real test. Lengthen the scripts or add the official pauses and reading time between sections.
4. **Open — Map/plan labelling and diagram labelling** need an image or vector-map renderer before those Listening/Reading task types can be authored.
5. **Open — Full-mock Speaking:** record Parts 1–3 with the microphone inside the full mock (reuse `SpeakingView` recording + `evaluateSpeaking`) so a four-module overall band can be estimated.

## Changed this session (Written, not compiled)

- `IELTSCore/Curriculum/ContentValidator.swift`: cross-exam similarity, passage length, MCQ option count, `crossExamDuplicateCount`.
- `IELTSCore/Scoring/IELTSScoringEngine.swift`: `gradeObjectiveModule` returns `(rawScore, totalQuestions, bandScore: Double?, incorrectQuestions)`.
- `IELTSCore/Curriculum/MockExamBank.swift`: `allExams` = authored exams; `legacyTemplateExams`; `AuthoredExams`; `MockExam.withValidation`.
- `IELTSCore/Curriculum/AuthoredExams/`: `AuthoredExamKit.swift`, `AuthoredExam01.swift`, `AuthoredExam02.swift` (new).
- `IELTSMaster/Views/ReadingView.swift`, `ListeningView.swift`: optional band.
- `IELTSMaster/Views/FullMockExamsView.swift`: rubric-based Writing, no Speaking band from typed notes, async submit.
- `IELTSMaster/Views/DashboardView.swift`: exam count from data.
- `IELTSTestRunner/main.swift`, `Tests/IELTSCoreTests/IELTSCoreTests.swift`: bank, legacy-rejection, partial-band tests.

## Module status

| Area | Status | Notes |
|---|---|---|
| Native app shell, 17-item sidebar, light/dark | Verified (earlier session) | Built with Swift 6.4.2 CLT; no Xcode.app installed |
| SQLite persistence, backup/restore, export | Verified (earlier session) | |
| Scoring: rounding, raw→band, Task 2 weighting | Verified (earlier session) | Partial-set change: Written |
| Exam timers | Verified (earlier session) | |
| Mock exam bank | Written | 2 authored exams pass script checks; target is 30 |
| Cross-exam validator | Written | |
| Listening module (TTS playback, transcript) | Verified build (earlier) | Audio length short, see Next up #3 |
| Reading module | Verified build (earlier) | |
| Writing evaluator (LLM + offline fallback) | Verified build (earlier) | Offline rubric is a heuristic estimate |
| Speaking (mic, transcription, metrics) | Verified build (earlier) | Pronunciation band withheld without audio analysis |
| Full mock exam | Written | Speaking not scored inside the full mock yet |
| Ollama discovery, routing, streaming | Verified build (earlier) | Live Ollama never exercised |
| RAG over verified sources | Verified (earlier) | |
| Adaptive engine (SM-2, mastery) | Verified (earlier) | |
| Pronunciation lab | Verified build (earlier) | |
| .app / .dmg packaging | Verified (earlier) | Rebuild after this session's changes |
