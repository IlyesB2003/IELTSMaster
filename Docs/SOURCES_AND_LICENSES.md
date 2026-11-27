# Authoritative Sources, Attribution & Dependency Licenses

## 1. Verified Educational Sources

All externally referenced IELTS specifications and pedagogical standards are attributed below and inside the in-app **Resource Library**:

| Source Name | Original URL | Access Date | Category | Verification | License / Copyright Notice |
|---|---|---|---|---|---|
| IELTS Official Website | https://ielts.org | 2026-11-25 | Official Examination Specification | Verified | © British Council, IDP: IELTS Australia, Cambridge University Press & Assessment. Public format & band descriptor rules referenced; no copyrighted test papers redistributed. |
| British Council Take IELTS & LearnEnglish | https://takeielts.britishcouncil.org | 2026-11-25 | Examination Guidance & Grammar | Verified | © British Council. Publicly accessible guidance referenced. |
| IDP IELTS Official Preparation Hub | https://ielts.idp.com | 2026-11-25 | Official Examination Partner | Verified | © IDP Education. Public computer-delivered test format documentation referenced. |
| Cambridge English | https://www.cambridgeenglish.org | 2026-11-25 | CEFR Alignment & Assessment Research | Verified | © Cambridge University Press & Assessment. Public IELTS-CEFR alignment research referenced; Cambridge IELTS books are NOT copied or redistributed. |
| Council of Europe (CEFR) | https://www.coe.int/en/web/common-european-framework-reference-languages | 2026-11-25 | Proficiency Framework | Verified | © Council of Europe. Public CEFR Global Scale descriptors referenced. |
| BBC Learning English | https://www.bbc.co.uk/learningenglish | 2026-11-25 | Pronunciation & Grammar Pedagogy | Verified | © BBC. Public pronunciation and grammar topics referenced. |
| Oxford Learner's Dictionaries | https://www.oxfordlearnersdictionaries.com | 2026-11-25 | Lexicography & Academic Vocabulary | Verified | © Oxford University Press. IPA and collocation pedagogy referenced. |
| Cambridge Dictionary | https://dictionary.cambridge.org | 2026-11-25 | Lexicography & Usage | Verified | © Cambridge University Press & Assessment. Formal academic usage principles referenced. |

## 2. Original Practice Content Provenance

All 30 mock examinations in `MockExamBank.swift`, all 20 grammar lessons in `GrammarCurriculum.swift`, all vocabulary entries in `VocabularyBank.swift`, and all Band 4–9 illustrative writing essays in `WritingModelSamples.swift` are original educational works created specifically for IELTS Master and explicitly flagged `isOfficialIELTSMaterial = false`.

## 3. Software Dependencies & Licenses

IELTS Master intentionally uses **zero third-party Swift package dependencies**, relying solely on Apple macOS SDK system frameworks (`SwiftUI`, `AppKit`, `Foundation`, `AVFoundation`, `Speech`, `NaturalLanguage`, `Accelerate`, `Charts`, `Security`, `UniformTypeIdentifiers`) and macOS system `libsqlite3` (Public Domain).
