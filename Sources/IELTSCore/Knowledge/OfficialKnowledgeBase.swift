import Foundation

public struct KnowledgeDocument: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let category: String
    public let module: String
    public let sourceID: String
    public let sourceName: String
    public let sourceURL: String
    public let version: Int
    public let content: String

    public init(
        id: String,
        title: String,
        category: String,
        module: String,
        sourceID: String,
        sourceName: String,
        sourceURL: String,
        version: Int = 1,
        content: String
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.module = module
        self.sourceID = sourceID
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.version = version
        self.content = content
    }
}

/// Verified authoritative IELTS and English language educational knowledge base.
/// Contains strictly public specification summaries and attribution metadata;
/// never redistributes copyrighted Cambridge examination books.
public enum OfficialKnowledgeBase {
    public static let accessDate = "2026-11-25"

    public static let sources: [SourceAttribution] = [
        SourceAttribution(
            id: "src-ielts-org",
            sourceName: "IELTS Official Website (Test Format & Band Descriptors)",
            originalURL: "https://ielts.org",
            accessDate: accessDate,
            copyrightAndLicense: "© British Council, IDP: IELTS Australia, and Cambridge University Press & Assessment. Public test format specifications and public band descriptors referenced for educational guidance only; no copyrighted test papers redistributed.",
            category: "Official Examination Specification",
            verificationStatus: "Verified",
            summary: "Authoritative source for IELTS Academic test structure, computer-delivered timing rules, raw-to-band scoring rules, rounding (.25/.75), and public Writing and Speaking assessment criteria."
        ),
        SourceAttribution(
            id: "src-british-council",
            sourceName: "British Council Take IELTS & LearnEnglish",
            originalURL: "https://takeielts.britishcouncil.org",
            accessDate: accessDate,
            copyrightAndLicense: "© British Council. Referenced for publicly documented exam preparation guidance, grammar frameworks, and computer-delivered test instructions.",
            category: "Examination Guidance & Grammar",
            verificationStatus: "Verified",
            summary: "Official IELTS test partner providing public guidance on Listening, Academic Reading, Academic Writing, Speaking preparation, and structured English grammar pedagogy."
        ),
        SourceAttribution(
            id: "src-idp-ielts",
            sourceName: "IDP IELTS Official Preparation Hub",
            originalURL: "https://ielts.idp.com",
            accessDate: accessDate,
            copyrightAndLicense: "© IDP Education. Public IELTS Academic format documentation and scoring methodology overview referenced.",
            category: "Official Examination Partner",
            verificationStatus: "Verified",
            summary: "Co-owner of IELTS providing verified documentation on computer-delivered Listening review timing, Reading 60-minute rules, and Speaking interview phases."
        ),
        SourceAttribution(
            id: "src-cambridge-english",
            sourceName: "Cambridge English & Cambridge University Press & Assessment",
            originalURL: "https://www.cambridgeenglish.org",
            accessDate: accessDate,
            copyrightAndLicense: "© Cambridge University Press & Assessment. Public IELTS-to-CEFR alignment research referenced; copyrighted Cambridge IELTS books are not copied or redistributed.",
            category: "CEFR Alignment & Assessment Research",
            verificationStatus: "Verified",
            summary: "Research-backed alignment between IELTS 9-band scale and Council of Europe CEFR levels (B1 through C2) noting that the two scales are not strictly 1:1 interchangeable."
        ),
        SourceAttribution(
            id: "src-cefr-coe",
            sourceName: "Council of Europe — Common European Framework of Reference (CEFR)",
            originalURL: "https://www.coe.int/en/web/common-european-framework-reference-languages",
            accessDate: accessDate,
            copyrightAndLicense: "© Council of Europe. Public CEFR Global Scale and Companion Volume descriptors referenced.",
            category: "Proficiency Framework",
            verificationStatus: "Verified",
            summary: "International standard defining A1, A2, B1, B2, C1, and C2 language proficiency levels across reception, production, interaction, and mediation."
        ),
        SourceAttribution(
            id: "src-bbc-learning",
            sourceName: "BBC Learning English",
            originalURL: "https://www.bbc.co.uk/learningenglish",
            accessDate: accessDate,
            copyrightAndLicense: "© BBC. Publicly accessible pronunciation, connected speech, and grammar reference topics cited for study direction.",
            category: "Pronunciation & Grammar Pedagogy",
            verificationStatus: "Verified",
            summary: "Authoritative English pronunciation guidance covering British RP/modern standard phonology, word stress, intonation, connected speech, and grammar."
        ),
        SourceAttribution(
            id: "src-oxford-dict",
            sourceName: "Oxford Learner's Dictionaries (Oxford 3000 / 5000 & OPAL)",
            originalURL: "https://www.oxfordlearnersdictionaries.com",
            accessDate: accessDate,
            copyrightAndLicense: "© Oxford University Press. Referenced for academic vocabulary principles, IPA transcription standards, and collocation pedagogy.",
            category: "Lexicography & Academic Vocabulary",
            verificationStatus: "Verified",
            summary: "Reference standard for learner-friendly definitions, IPA transcriptions, British and American pronunciation variants, and Oxford Phrasal Academic Lexicon principles."
        ),
        SourceAttribution(
            id: "src-cambridge-dict",
            sourceName: "Cambridge Dictionary & English Grammar Today",
            originalURL: "https://dictionary.cambridge.org",
            accessDate: accessDate,
            copyrightAndLicense: "© Cambridge University Press & Assessment. Referenced for academic register, collocations, and usage notes.",
            category: "Lexicography & Usage",
            verificationStatus: "Verified",
            summary: "Authoritative reference for academic collocations, phrasal verbs, British/American spelling consistency, and formal register."
        ),
        SourceAttribution(
            id: "src-manchester-phrasebank",
            sourceName: "University of Manchester — Academic Phrasebank",
            originalURL: "https://www.phrasebank.manchester.ac.uk",
            accessDate: accessDate,
            copyrightAndLicense: "© University of Manchester. Publicly accessible academic writing phraseology patterns referenced for educational orientation.",
            category: "Academic Writing Phraseology",
            verificationStatus: "Verified",
            summary: "Gold-standard bank of neutral, reusable academic discourse stems for introducing work, hedging claims, comparing findings, and describing methodology."
        ),
        SourceAttribution(
            id: "src-awl-coxhead",
            sourceName: "Academic Word List (AWL — Averil Coxhead, Victoria University of Wellington)",
            originalURL: "https://www.wgtn.ac.nz/lals/resources/academicwordlist",
            accessDate: accessDate,
            copyrightAndLicense: "© Victoria University of Wellington. Publicly published 570 academic word families referenced for vocabulary prioritization.",
            category: "Academic Vocabulary Corpus",
            verificationStatus: "Verified",
            summary: "Corpus-derived list of 570 high-frequency cross-disciplinary academic word families essential for Band 7.0–9.0 Reading and Writing."
        ),
        SourceAttribution(
            id: "src-purdue-owl",
            sourceName: "Purdue Online Writing Lab (OWL) — Academic & ESL Writing",
            originalURL: "https://owl.purdue.edu",
            accessDate: accessDate,
            copyrightAndLicense: "© Purdue University. Open educational writing guidance referenced for coherence, thesis construction, and nominalization.",
            category: "Academic Writing & Rhetoric",
            verificationStatus: "Verified",
            summary: "Comprehensive university writing manual covering argumentation, paragraph unity, concision, hedging, and punctuation."
        ),
        SourceAttribution(
            id: "src-ielts-writing-descriptors",
            sourceName: "IELTS Public Writing Band Descriptors (Task 1 & Task 2)",
            originalURL: "https://ielts.org/organisations/ielts-for-organisations/ielts-scoring-in-detail",
            accessDate: accessDate,
            copyrightAndLicense: "© IELTS Partners (British Council, IDP, Cambridge). Public assessment rubric criteria referenced directly.",
            category: "Official Assessment Criteria",
            verificationStatus: "Verified",
            summary: "Exact Band 0–9 public criteria distinguishing Band 7 (good user), Band 8 (very good user), and Band 9 (expert user) across TA/TR, CC, LR, and GRA."
        ),
        SourceAttribution(
            id: "src-ielts-speaking-descriptors",
            sourceName: "IELTS Public Speaking Band Descriptors",
            originalURL: "https://ielts.org/take-a-test/test-types/ielts-academic-test",
            accessDate: accessDate,
            copyrightAndLicense: "© IELTS Partners. Public Speaking rubric criteria referenced directly.",
            category: "Official Assessment Criteria",
            verificationStatus: "Verified",
            summary: "Defines Band 7–9 Fluency & Coherence, Lexical Resource, Grammatical Range & Accuracy, and Pronunciation intelligibility without accent bias."
        ),
        SourceAttribution(
            id: "src-speech-accent-archive",
            sourceName: "George Mason University — Speech Accent Archive",
            originalURL: "https://accent.gmu.edu",
            accessDate: accessDate,
            copyrightAndLicense: "© George Mason University. Public phonological reference for international English accent variation.",
            category: "Pronunciation & Accents",
            verificationStatus: "Verified",
            summary: "Empirical reference on British, Irish, Australian, Canadian, American, and L2 English phonological patterns to build accent comprehension."
        ),
        SourceAttribution(
            id: "src-english-profile",
            sourceName: "English Profile — CEFR Vocabulary & Grammar Profile",
            originalURL: "https://www.englishprofile.org",
            accessDate: accessDate,
            copyrightAndLicense: "© Cambridge University Press & Assessment / English Profile. Public CEFR C1–C2 grammatical and lexical benchmarks referenced.",
            category: "CEFR Benchmarks",
            verificationStatus: "Verified",
            summary: "Maps specific grammatical constructions (inversion, clefts, subtle modality) and lexical collocations to B2, C1, and C2 proficiency levels."
        ),
        SourceAttribution(
            id: "src-teagasc-agri",
            sourceName: "Teagasc — Irish Agriculture & Food Development Authority (Open Research)",
            originalURL: "https://www.teagasc.ie",
            accessDate: accessDate,
            copyrightAndLicense: "© Teagasc. Publicly accessible open-access agricultural research topics referenced for specialized ESP terminology orientation.",
            category: "Specialized Academic English (Agri-Food)",
            verificationStatus: "Verified",
            summary: "Authoritative Irish agri-food and animal science communication reference for grassland systems, ruminant nutrition, and sustainable farming terminology."
        ),
        SourceAttribution(
            id: "src-nature-scitable",
            sourceName: "Nature Scitable — English Communication for Scientists",
            originalURL: "https://www.nature.com/scitable/ebooks/english-communication-for-scientists-14053993/",
            accessDate: accessDate,
            copyrightAndLicense: "© Springer Nature. Publicly readable scientific writing principles referenced for IMRaD structure and clarity.",
            category: "Scientific Communication",
            verificationStatus: "Verified",
            summary: "Practical guide to writing clear research abstracts, figures, scientific papers, and delivering persuasive conference presentations."
        ),
        SourceAttribution(
            id: "src-ucl-phonetics",
            sourceName: "UCL Division of Psychology & Language Sciences — Phonetics Resources",
            originalURL: "https://www.ucl.ac.uk/pals",
            accessDate: accessDate,
            copyrightAndLicense: "© University College London. Public IPA, word stress, and connected speech principles referenced.",
            category: "Phonetics & Intelligibility",
            verificationStatus: "Verified",
            summary: "Academic phonetics guidance on weak forms, assimilation, elision, nuclear stress, and intelligibility-driven pronunciation training."
        )
    ]

    public static let documents: [KnowledgeDocument] = [
        KnowledgeDocument(
            id: "kb-exam-structure",
            title: "IELTS Academic Official Examination Structure (Computer-Delivered)",
            category: "Examination Structure",
            module: "General",
            sourceID: "src-ielts-org",
            sourceName: "IELTS Official Website",
            sourceURL: "https://ielts.org",
            content: """
            IELTS Academic assesses four language skills: Listening, Academic Reading, Academic Writing, and Speaking.
            Total written computer-delivered sitting is approximately 2 hours 45 minutes with no breaks between Listening, Reading, and Writing.
            1. Listening: 4 parts, 40 questions (10 per part), approximately 30 minutes of audio played once only, plus 2 minutes to review answers on screen. Part 1 is an everyday social conversation; Part 2 is an everyday social monologue; Part 3 is an educational or training conversation among up to four speakers; Part 4 is an academic lecture monologue.
            2. Academic Reading: 3 long academic passages, 40 questions, 60 minutes total with no extra transfer time. Passages range from descriptive and factual to discursive and analytical.
            3. Academic Writing: 2 tasks, 60 minutes total. Task 1 requires summarizing, describing, or explaining visual information (graph, bar chart, line chart, pie chart, table, map, process diagram, or combined visual data) in at least 150 words (recommended 20 minutes). Task 2 requires an academic essay (opinion, discussion, advantages/disadvantages, problem/solution, or two-part question) in at least 250 words (recommended 40 minutes). Task 2 contributes twice as much weight to the Writing band score as Task 1.
            4. Speaking: 11 to 14 minutes in three parts. Part 1 (4–5 min) introduction and familiar topics; Part 2 (3–4 min) individual long turn with 1 minute preparation and up to 2 minutes speaking using a task card; Part 3 (4–5 min) two-way abstract discussion connected to Part 2.
            """
        ),
        KnowledgeDocument(
            id: "kb-scoring-rounding",
            title: "IELTS Band Score Calculation and Rounding Rules",
            category: "Scoring Methodology",
            module: "General",
            sourceID: "src-ielts-org",
            sourceName: "IELTS Official Website",
            sourceURL: "https://ielts.org",
            content: """
            IELTS uses a 9-band scale from Band 0 to Band 9 in whole and half bands.
            Listening and Academic Reading each have 40 questions worth 1 mark each with no negative marking.
            Standard Listening benchmarks: 39-40 = 9.0, 37-38 = 8.5, 35-36 = 8.0, 32-34 = 7.5, 30-31 = 7.0, 26-29 = 6.5, 23-25 = 6.0, 18-22 = 5.5, 16-17 = 5.0.
            Standard Academic Reading benchmarks: 39-40 = 9.0, 37-38 = 8.5, 35-36 = 8.0, 33-34 = 7.5, 30-32 = 7.0, 27-29 = 6.5, 23-26 = 6.0, 19-22 = 5.5, 15-18 = 5.0.
            Overall Band Score is the arithmetic mean of Listening, Reading, Writing, and Speaking (equal 25% weight each).
            Official rounding rules: averages ending in .25 round UP to the next half band (.5); averages ending in .75 round UP to the next whole band; averages ending in .125 round down to .0; averages ending in .625 round down to .5.
            """
        ),
        KnowledgeDocument(
            id: "kb-writing-criteria",
            title: "IELTS Academic Writing Public Assessment Criteria",
            category: "Assessment Criteria",
            module: "Writing",
            sourceID: "src-ielts-org",
            sourceName: "IELTS Official Website",
            sourceURL: "https://ielts.org",
            content: """
            IELTS Academic Writing is evaluated equally across four criteria (25% each):
            1. Task Achievement (Task 1) / Task Response (Task 2):
               - Task 1 Band 7+: Presents a clear overview of main trends, differences, or stages; accurately highlights key features with data support without mechanical listing of every figure.
               - Task 2 Band 7+: Addresses all parts of the prompt; presents a clear position throughout the response; extends and supports main ideas without over-generalizing.
            2. Coherence and Cohesion:
               - Band 7+: Logically organizes information and ideas with clear progression; uses a range of cohesive devices appropriately (without overuse or mechanical 'firstly/secondly'); presents a clear central topic within each paragraph.
            3. Lexical Resource:
               - Band 7+: Uses a sufficient range of vocabulary for flexibility and precision; uses less common lexical items with awareness of style and collocation; may produce occasional errors in word choice, spelling, or word formation.
            4. Grammatical Range and Accuracy:
               - Band 7+: Uses a variety of complex structures (subordinate clauses, conditionals, passive voice, relative clauses, participle clauses); produces frequent error-free sentences; has good control of grammar and punctuation with few errors.
            Task 2 carries double the weight of Task 1 in the overall Writing band.
            """
        ),
        KnowledgeDocument(
            id: "kb-speaking-criteria",
            title: "IELTS Speaking Public Assessment Criteria",
            category: "Assessment Criteria",
            module: "Speaking",
            sourceID: "src-ielts-org",
            sourceName: "IELTS Official Website",
            sourceURL: "https://ielts.org",
            content: """
            IELTS Speaking is assessed equally across four criteria (25% each):
            1. Fluency and Coherence: Speaks at length without noticeable effort or loss of coherence; demonstrates willingness to develop topics; uses discourse markers and connectives flexibly; hesitation is content-related rather than language-searching.
            2. Lexical Resource: Discusses a wide variety of topics flexibly; uses idiomatic and less common vocabulary naturally; paraphrases effectively when searching for a precise term.
            3. Grammatical Range and Accuracy: Uses a range of complex structures with flexibility; frequently produces error-free sentences; self-corrects minor slips naturally.
            4. Pronunciation: Uses a range of phonological features including word stress, sentence stress, rhythm, weak forms, linking, and intonation; sustains intelligibility throughout. Non-native accents are NOT penalized as long as speech remains easy to understand.
            """
        ),
        KnowledgeDocument(
            id: "kb-reading-strategies",
            title: "Academic Reading Comprehension Techniques and Distractor Avoidance",
            category: "Examination Strategies",
            module: "Reading",
            sourceID: "src-british-council",
            sourceName: "British Council Take IELTS",
            sourceURL: "https://takeielts.britishcouncil.org",
            content: """
            High-band Academic Reading relies on targeted skimming, scanning, and synonym/paraphrase recognition rather than word-by-word translation.
            - True / False / Not Given: TRUE means the passage directly agrees with the statement; FALSE means the passage directly contradicts the statement; NOT GIVEN means there is insufficient evidence to confirm or contradict. Watch for qualifier distractors (all, always, only, primarily, never).
            - Matching Headings: Read the first and last sentences plus topic shifts to identify the paragraph's main idea rather than matching a single repeated keyword.
            - Summary and Sentence Completion: Respect strict word limits (e.g., NO MORE THAN TWO WORDS AND/OR A NUMBER). Predict the grammatical part of speech (noun, verb, adjective) before scanning the passage.
            - Time management: Spend approximately 17–20 minutes per passage and never leave a question blank because there is no negative marking.
            """
        ),
        KnowledgeDocument(
            id: "kb-listening-strategies",
            title: "IELTS Listening Comprehension Techniques and Distractor Patterns",
            category: "Examination Strategies",
            module: "Listening",
            sourceID: "src-idp-ielts",
            sourceName: "IDP IELTS",
            sourceURL: "https://ielts.idp.com",
            content: """
            In computer-delivered IELTS Listening, audio plays once only. Use preparation pauses before each section to underline keywords and predict expected answer types (dates, prices, postcodes, singular/plural nouns).
            Common IELTS Listening distractors include:
            - Self-corrections ('Actually, let's make that Thursday instead of Tuesday').
            - Speaker disagreement in Part 3 university discussions ('I thought we should survey 50 farms, but Dr. Evans suggested 80').
            - Signposting transitions in Part 4 academic lectures ('However', 'Turning now to', 'By contrast', 'The key exception is').
            Spelling and plural '-s' accuracy are mandatory. Familiarize yourself with British, Australian, American, Canadian, and Irish accents.
            """
        ),
        KnowledgeDocument(
            id: "kb-cefr-alignment",
            title: "IELTS and CEFR Alignment Research Summary",
            category: "Proficiency Framework",
            module: "General",
            sourceID: "src-cambridge-english",
            sourceName: "Cambridge English",
            sourceURL: "https://www.cambridgeenglish.org",
            content: """
            Cambridge English alignment studies map IELTS Academic bands approximately to CEFR levels:
            - Band 4.0 to 4.5: approximately CEFR B1
            - Band 5.5 to 6.5: approximately CEFR B2
            - Band 7.0 to 8.0: approximately CEFR C1
            - Band 8.5 to 9.0: approximately CEFR C2
            Important methodological note: CEFR and IELTS are distinct assessment frameworks and are not strictly interchangeable. Diagnostic estimates carry uncertainty until validated by multiple complete exam modules.
            """
        ),
        KnowledgeDocument(
            id: "kb-pronunciation-intelligibility",
            title: "Pronunciation Intelligibility, Word Stress, and Connected Speech",
            category: "Pronunciation Guidance",
            module: "Speaking",
            sourceID: "src-bbc-learning",
            sourceName: "BBC Learning English",
            sourceURL: "https://www.bbc.co.uk/learningenglish",
            content: """
            Intelligible academic English pronunciation prioritizes four high-impact features over accent imitation:
            1. Word stress: Placing stress on the correct syllable in multisyllabic academic words (e.g., PHOtograph vs phoTOgraphy vs photoGRAPHic; ANalyse vs aNALysis).
            2. Sentence stress and nuclear prominence: Stressing content words (nouns, main verbs, adjectives) while reducing function words (articles, prepositions, auxiliaries) to weak forms with schwa /ə/.
            3. Minimal pairs common for Arabic-speaking learners of English: /p/ vs /b/ (pack/back, simple/symbol), /f/ vs /v/ (ferry/very, fan/van), /ɪ/ vs /iː/ (ship/sheep, live/leave), and consonant clusters without epenthetic vowels.
            4. Intonation and chunking: Using rising intonation for lists/uncertainty and falling intonation for completed statements and wh-questions.
            """
        ),
        KnowledgeDocument(
            id: "kb-band7-to-band9-writing",
            title: "Roadmap from Band 7.0 to Band 8.5–9.0 in Academic Writing",
            category: "Band 9 Mastery",
            module: "Writing",
            sourceID: "src-ielts-writing-descriptors",
            sourceName: "IELTS Public Writing Band Descriptors",
            sourceURL: "https://ielts.org/organisations/ielts-for-organisations/ielts-scoring-in-detail",
            content: """
            Moving from Band 7.0 to Band 8.5–9.0 in IELTS Academic Writing requires four specific upgrades:
            1. Task Response / Achievement: Move from answering all parts clearly (Band 7) to fully developed, nuanced, tightly qualified positions with zero over-generalization (Band 8–9). In Task 1, synthesize overarching patterns and structural contrasts rather than narrating chronologically line by line.
            2. Coherence & Cohesion: Eliminate mechanical sentence-initial linkers ('Firstly', 'Moreover', 'In conclusion'). Instead, use lexical cohesion (summary nouns like 'This divergence', 'Such fiscal trade-offs'), theme-rheme progression, and mid-clause transitions.
            3. Lexical Resource: Replace generic adjectives ('big', 'good', 'important') with precise domain collocations ('prohibitive upfront capital', 'empirical corroboration', 'diminishing marginal returns'). Band 9 exhibits natural, effortless precision with virtually no awkward collocation.
            4. Grammatical Range & Accuracy: Sustain error-free complex syntax throughout: participle clauses, concessive subordination, cleft emphasis, accurate academic hedging ('appears to', 'is likely to', 'may partly explain'), and formal inversion where natural.
            """
        ),
        KnowledgeDocument(
            id: "kb-writing-task1-all-types",
            title: "Complete Guide to All 7 IELTS Writing Task 1 Visual Formats",
            category: "Writing Methodology",
            module: "Writing",
            sourceID: "src-british-council",
            sourceName: "British Council Take IELTS",
            sourceURL: "https://takeielts.britishcouncil.org",
            content: """
            Every IELTS Academic Writing Task 1 response should follow a crisp 4-paragraph architecture (Introduction paraphrase → Overview of 2–3 overarching features without raw figures → Body 1 grouped key details → Body 2 contrasting/secondary details):
            - Line & Bar Charts (over time): Group by trend trajectory (rapid climbers vs steady vs declining); highlight start, peak, crossover, and end points.
            - Pie Charts & Tables (static): Group by largest vs smallest shares; use proportional language ('accounted for just over a third', 'represented a negligible fraction').
            - Process Diagrams: State total number of stages, whether linear or cyclical, input and final output; use Present Simple Passive ('is milled', 'are filtered') and sequencers ('subsequently', 'once cooled').
            - Map Comparisons: Group spatially (north/south/east/west) or by transformation type (demolition, expansion, conversion to pedestrian/green zones); use Past/Present Perfect Passive ('was replaced by', 'has been converted into').
            - Combined Visuals: Synthesize the relationship between the two visuals in the overview, then dedicate one body paragraph to each visual while cross-referencing key links.
            """
        ),
        KnowledgeDocument(
            id: "kb-speaking-band9-part3",
            title: "Band 8.0–9.0 Speaking Part 2 & Part 3 Analytical Frameworks",
            category: "Band 9 Mastery",
            module: "Speaking",
            sourceID: "src-ielts-speaking-descriptors",
            sourceName: "IELTS Public Speaking Band Descriptors",
            sourceURL: "https://ielts.org/take-a-test/test-types/ielts-academic-test",
            content: """
            Band 8.5–9.0 speakers sound calm, coherent, and intellectually engaged rather than memorized:
            - Part 2 (2-minute long turn): Use your 60-second prep to jot 4–6 anchor keywords (not full sentences). Structure naturally: context → vivid detail/story → comparison with past or alternatives → personal significance. Speak smoothly until the examiner signals time is up.
            - Part 3 (abstract discussion): Use the Nuanced Analytical Frame: (1) Direct qualified stance ('It largely depends on...'), (2) Underlying mechanism/reason, (3) Concrete real-world illustration, (4) Counter-perspective or long-term caveat ('Having said that, smaller rural communities face...').
            - Self-correction & hesitation: Content-related pausing ('That's an intriguing question—if I think about it...') is natural at Band 9; language-searching repetition lowers Fluency.
            """
        ),
        KnowledgeDocument(
            id: "kb-reading-band9-traps",
            title: "Advanced Academic Reading Traps & Band 8.5–9.0 Precision",
            category: "Band 9 Mastery",
            module: "Reading",
            sourceID: "src-cambridge-english",
            sourceName: "Cambridge English",
            sourceURL: "https://www.cambridgeenglish.org",
            content: """
            To score 37–40/40 (Band 8.5–9.0) in Academic Reading, master these five high-level traps:
            1. Qualifier shifts: Passage says 'some researchers suspect' while the statement claims 'scientists have proved' → FALSE/NO.
            2. Scope & comparison traps: Statement compares Group A vs Group B ('A is more expensive than B'), but the passage only mentions A's cost → NOT GIVEN.
            3. Word-class traps in Summary Completion: Even if you locate the right sentence, check whether the gap requires a singular noun, plural noun, gerund, or adjective, and respect the exact word limit.
            4. Distanced paraphrasing in Passage 3: Academic Passage 3 relies on conceptual paraphrasing rather than simple synonym swaps (e.g., 'halved per-unit expenditure' = 'reduced individual costs by 50%').
            5. Matching Headings discipline: Never match a heading because one word appears in a single example sentence; read the topic sentence + final synthesis sentence to confirm the paragraph's overarching function.
            """
        ),
        KnowledgeDocument(
            id: "kb-listening-band9-precision",
            title: "Band 8.5–9.0 Listening Precision: Part 3 & Part 4 Mastery",
            category: "Band 9 Mastery",
            module: "Listening",
            sourceID: "src-idp-ielts",
            sourceName: "IDP IELTS",
            sourceURL: "https://ielts.idp.com",
            content: """
            Scoring 37–40/40 in IELTS Listening depends almost entirely on eliminating avoidable drops in Parts 3 and 4:
            - Part 3 (Academic Discussion): Track speaker attribution carefully. One student often proposes an idea, the second student challenges it, and only the final agreed compromise is the answer.
            - Part 4 (Academic Lecture): Read ahead during the 30-second pause to predict the exact part of speech for every blank (noun, adjective, plural). Listen for structural signposts ('Turning to the second mechanism...', 'Crucially, however...', 'What surprised researchers was...').
            - Spelling & Plurals: A missing plural '-s' or misspelled academic word ('environment', 'government', 'accommodation', 'questionnaire') costs a full mark. Use the 2-minute computer-delivered review window specifically to audit plurals, singular verbs, and spelling.
            """
        ),
        KnowledgeDocument(
            id: "kb-arabic-learner-error-guide",
            title: "High-Frequency Error Patterns for Arabic-Speaking IELTS Candidates",
            category: "Bilingual Pedagogy",
            module: "General",
            sourceID: "src-english-profile",
            sourceName: "English Profile",
            sourceURL: "https://www.englishprofile.org",
            content: """
            Targeted diagnosis of recurring L1 Arabic-to-English interference accelerates progression from Band 6.0 to Band 7.5+:
            1. Definite article overuse: Arabic uses 'الـ' before abstract/uncountable nouns ('التعليم مهم'), causing 'The education is important' instead of 'Education is important'.
            2. Double conjunctions: Arabic allows 'رغم أن ... لكن ...', causing 'Although it is costly, but it works'. In English, choose ONLY one ('Although it is costly, it works').
            3. Run-on sentences / comma splices: Arabic frequently chains clauses with 'و' (and); English academic prose requires crisp sentence boundaries, semicolons, or subordination.
            4. Resumptive pronouns in relative clauses: Avoid 'the study which I read it' → 'the study which I read'.
            5. Phonological intelligibility: Focus on aspirated /p/ vs /b/, voiced /v/ vs /f/, short /ɪ/ vs long /iː/, and avoiding extra vowels inside consonant clusters ('statistics', 'strengths').
            """
        ),
        KnowledgeDocument(
            id: "kb-academic-hedging-stance",
            title: "Academic Hedging, Qualification, and Stance (C1–C2)",
            category: "Academic Writing Phraseology",
            module: "Writing",
            sourceID: "src-manchester-phrasebank",
            sourceName: "University of Manchester Academic Phrasebank",
            sourceURL: "https://www.phrasebank.manchester.ac.uk",
            content: """
            Expert academic writers distinguish between empirical certainty and cautious interpretation:
            - Modal hedging: 'may', 'might', 'could', 'appear to', 'tend to'.
            - Lexical hedging: 'arguably', 'plausibly', 'to a considerable extent', 'in many respects'.
            - Syntactic qualification: 'While X holds true in dense urban centres, rural regions often exhibit...'
            - Avoiding weak hedging: Never stack hedges ('It might possibly perhaps tend to seem...'). One clean qualifier per claim produces authoritative Band 9 tone.
            """
        ),
        KnowledgeDocument(
            id: "kb-scientific-imrad-communication",
            title: "Scientific Research Communication & International Career English",
            category: "Scientific Communication",
            module: "General",
            sourceID: "src-nature-scitable",
            sourceName: "Nature Scitable",
            sourceURL: "https://www.nature.com/scitable/ebooks/english-communication-for-scientists-14053993/",
            content: """
            Effective international scientific communication combines IMRaD clarity (Introduction, Methods, Results, and Discussion) with active, concise prose:
            - Lead every paragraph with a clear claim or finding, then support it with quantitative evidence.
            - Keep subjects close to their verbs and prefer strong verbs ('demonstrates', 'mitigates', 'corroborates') over weak verb+noun strings ('makes an improvement in').
            - For international career communication (e.g., Ireland/EU agri-food and biotech roles), tailor cover letters and emails to measurable outcomes, domain precision, and polite directness.
            """
        )
    ]
}
