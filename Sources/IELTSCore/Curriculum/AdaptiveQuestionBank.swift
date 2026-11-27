import Foundation

/// A single diagnostic / adaptive quiz question with domain, skill tag,
/// bilingual explanation, and teaching lesson link.
public struct AdaptiveQuizItem: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let domain: String       // "Grammar", "Vocabulary", "Reading", "Listening"
    public let skillCategory: String // e.g. "Subject-Verb Agreement", "Conditionals", "Academic Collocations"
    public let prompt: String
    public let audioScript: String? // Present for Listening items
    public let options: [String]
    public let correctIndex: Int
    public let explanation: String
    public let arabicExplanation: String
    public let teachingTip: String

    public init(
        id: String,
        domain: String,
        skillCategory: String,
        prompt: String,
        audioScript: String? = nil,
        options: [String],
        correctIndex: Int,
        explanation: String,
        arabicExplanation: String,
        teachingTip: String
    ) {
        self.id = id
        self.domain = domain
        self.skillCategory = skillCategory
        self.prompt = prompt
        self.audioScript = audioScript
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
        self.arabicExplanation = arabicExplanation
        self.teachingTip = teachingTip
    }
}

public struct SkillWeaknessReport: Identifiable, Hashable, Sendable {
    public let id: String
    public let skillCategory: String
    public let domain: String
    public let correct: Int
    public let total: Int
    public let sampleTip: String

    public var accuracy: Double {
        total > 0 ? Double(correct) / Double(total) : 0
    }
}

/// Large non-repeating adaptive question bank (40+ distinct handcrafted diagnostic items
/// plus dynamic extraction from the 30-exam bank) so every retake delivers fresh questions.
public enum AdaptiveQuestionBank {

    public static let corePool: [AdaptiveQuizItem] = [
        // MARK: Grammar (14 distinct items)
        AdaptiveQuizItem(
            id: "aq-g01", domain: "Grammar", skillCategory: "Subject-Verb Agreement",
            prompt: "Each of the laboratory soil samples ___ analysed twice before publication.",
            options: ["were", "was", "have been", "are"], correctIndex: 1,
            explanation: "'Each of the + plural noun' always takes a singular verb ('was').",
            arabicExplanation: "عبارة 'Each of the' يتبعها دائماً فعل مفرد (was) حتى لو كان الاسم بعدها جمعاً.",
            teachingTip: "Ignore the plural noun after 'of'; match the verb to 'Each'."
        ),
        AdaptiveQuizItem(
            id: "aq-g02", domain: "Grammar", skillCategory: "Subject-Verb Agreement",
            prompt: "The number of postgraduate applicants in biotechnology ___ risen sharply since 2021.",
            options: ["have", "has", "were", "are"], correctIndex: 1,
            explanation: "'The number of' refers to a single figure and takes a singular verb ('has').",
            arabicExplanation: "عبارة 'The number of' تشير إلى رقم واحد فتأخذ فعلاً مفرداً (has)، بعكس 'A number of' التي تأخذ جمعاً.",
            teachingTip: "Remember: 'The number of' = singular; 'A number of' = plural."
        ),
        AdaptiveQuizItem(
            id: "aq-g03", domain: "Grammar", skillCategory: "Conditionals",
            prompt: "If the trial had included a randomized control group, the findings ___ far more reliable.",
            options: ["would be", "will be", "would have been", "had been"], correctIndex: 2,
            explanation: "Third conditional (If + Past Perfect, would have + past participle) expresses a hypothetical past result.",
            arabicExplanation: "في الشرط الثالث (ماضٍ افتراضي) نستخدم had + التصريف الثالث مع would have + التصريف الثالث.",
            teachingTip: "Never put 'would' inside the if-clause; pair 'had + V3' with 'would have + V3'."
        ),
        AdaptiveQuizItem(
            id: "aq-g04", domain: "Grammar", skillCategory: "Conditionals",
            prompt: "Were governments ___ regenerative grazing, soil carbon storage would expand rapidly.",
            options: ["subsidize", "to subsidize", "subsidizing", "subsidized"], correctIndex: 1,
            explanation: "Formal inverted second conditional uses 'Were + subject + to-infinitive'.",
            arabicExplanation: "صيغة الشرط الثاني المعكوسة الأكاديمية (المستوى 8+) تستخدم Were + الفاعل + to + المصدر.",
            teachingTip: "Using one accurate inverted conditional ('Were governments to...') boosts Grammatical Range."
        ),
        AdaptiveQuizItem(
            id: "aq-g05", domain: "Grammar", skillCategory: "Complex Sentences & Concession",
            prompt: "___ high initial installation costs, solar irrigation lowers long-term operating expenses.",
            options: ["Although", "Despite", "However", "Whereas"], correctIndex: 1,
            explanation: "'Despite' is a preposition followed by a noun phrase ('high initial installation costs').",
            arabicExplanation: "نستخدم Despite قبل العبارات الاسمية، بينما نستخدم Although قبل جملة كاملة فيها فاعل وفعل.",
            teachingTip: "Check what follows the gap: noun phrase → Despite / In spite of; full clause → Although / Even though."
        ),
        AdaptiveQuizItem(
            id: "aq-g06", domain: "Grammar", skillCategory: "Complex Sentences & Concession",
            prompt: "Choose the sentence with NO comma splice or double conjunction error:",
            options: [
                "Although wind output grew, but grid capacity lagged behind.",
                "Wind output grew rapidly, grid capacity lagged behind.",
                "Wind output grew rapidly; nevertheless, grid capacity lagged behind.",
                "Because wind output grew rapidly, so grid capacity lagged."
            ],
            correctIndex: 2,
            explanation: "A semicolon + conjunctive adverb ('nevertheless') + comma joins two independent clauses accurately.",
            arabicExplanation: "لا تجمع بين Although و but في جملة واحدة، ولا تربط جملتين كاملتين بفاصلة فقط؛ الفاصلة المنقوطة مع nevertheless صحيحة تماماً.",
            teachingTip: "Never pair 'Although' with 'but' or 'Because' with 'so' in English."
        ),
        AdaptiveQuizItem(
            id: "aq-g07", domain: "Grammar", skillCategory: "Articles",
            prompt: "___ sustainable agriculture plays an indispensable role in national food security.",
            options: ["The", "A", "An", "No article (Ø)"], correctIndex: 3,
            explanation: "General uncountable concepts ('sustainable agriculture') take the zero article in English.",
            arabicExplanation: "في الإنجليزية لا نضع أداة تعريف (the) قبل المفاهيم العامة غير المعدودة، بعكس اللغة العربية.",
            teachingTip: "Only add 'the' before uncountable nouns when they are made specific (e.g., 'the agriculture of southern Ireland')."
        ),
        AdaptiveQuizItem(
            id: "aq-g08", domain: "Grammar", skillCategory: "Articles",
            prompt: "___ proportion of households adopting heat pumps doubled between 2019 and 2024.",
            options: ["The", "A", "No article (Ø)", "Some"], correctIndex: 0,
            explanation: "A specific proportion defined by an 'of' phrase requires the definite article 'The'.",
            arabicExplanation: "النسبة المحددة بعبارة of تحتاج دائماً إلى أداة التعريف The.",
            teachingTip: "Task 1 gold rule: almost always write 'The percentage of...' / 'The proportion of...'."
        ),
        AdaptiveQuizItem(
            id: "aq-g09", domain: "Grammar", skillCategory: "Relative Clauses",
            prompt: "Soil organic matter, ___ retains moisture during dry summers, declined in heavily tilled plots.",
            options: ["that", "which", "what", "who"], correctIndex: 1,
            explanation: "Non-defining relative clauses enclosed in commas require 'which', never 'that'.",
            arabicExplanation: "الجملة المعترضة بين فاصلتين تستخدم which للأشياء ولا يجوز استخدام that بعد الفاصلة أبداً.",
            teachingTip: "Comma + that is always incorrect in standard academic English."
        ),
        AdaptiveQuizItem(
            id: "aq-g10", domain: "Grammar", skillCategory: "Prepositions & Data Language",
            prompt: "Annual dairy exports rose ___ 14%, reaching a record total of 6.4 billion euros.",
            options: ["to", "by", "at", "into"], correctIndex: 1,
            explanation: "Use 'rise BY' for the margin of increase and 'rise TO' for the final figure.",
            arabicExplanation: "نستخدم rose BY لمقدار الزيادة (14%)، بينما نستخدم rose TO للقيمة النهائية.",
            teachingTip: "Master 'by' (change amount) vs 'to' (destination value) for Band 7+ Task 1."
        ),
        AdaptiveQuizItem(
            id: "aq-g11", domain: "Grammar", skillCategory: "Passive Voice",
            prompt: "After anaerobic fermentation, the biogas ___ purified to remove hydrogen sulphide.",
            options: ["is", "was been", "has", "being"], correctIndex: 0,
            explanation: "Present Simple passive ('is purified') describes a standard scientific or industrial process.",
            arabicExplanation: "وصف مراحل العمليات المتكررة يستخدم المضارع البسيط المبني للمجهول (is/are + التصريف الثالث).",
            teachingTip: "Use Present Simple Passive for Task 1 Process Diagrams."
        ),
        AdaptiveQuizItem(
            id: "aq-g12", domain: "Grammar", skillCategory: "Gerunds & Infinitives",
            prompt: "The research team modified the assay ___ detect trace contaminants earlier.",
            options: ["for", "to", "in order", "so that"], correctIndex: 1,
            explanation: "Use 'to + base verb' (infinitive of purpose), not 'for + base verb'.",
            arabicExplanation: "للتعبير عن الغرض نستخدم to + المصدر (to detect) وليس for + المصدر.",
            teachingTip: "Never write 'for + base verb' to express purpose; use 'to + verb' or 'for + -ing'."
        ),
        AdaptiveQuizItem(
            id: "aq-g13", domain: "Grammar", skillCategory: "Perfect & Continuous Tenses",
            prompt: "Dr. Gallagher ___ ruminant nutrition in Cork since 2018.",
            options: ["researches", "has researched", "researched", "is research"], correctIndex: 1,
            explanation: "Present Perfect ('has researched') connects an activity beginning in 2018 to the present.",
            arabicExplanation: "وجود كلمة since مع حدث مستمر حتى الآن يتطلب زمن المضارع التام (has/have + التصريف الثالث).",
            teachingTip: "Pair 'since + past year' with Present Perfect or Present Perfect Continuous."
        ),
        AdaptiveQuizItem(
            id: "aq-g14", domain: "Grammar", skillCategory: "Advanced Inversion & Parallelism",
            prompt: "Not only ___ carbon sequestration, but cover crops also prevent winter topsoil runoff.",
            options: ["they enhance", "do they enhance", "enhance they", "they do enhance"], correctIndex: 1,
            explanation: "Negative/restrictive adverbials at the beginning of a sentence trigger auxiliary-subject inversion.",
            arabicExplanation: "عندما تبدأ الجملة بـ Not only نقلب الفعل المساعد قبل الفاعل (do they enhance).",
            teachingTip: "Pattern: Not only + auxiliary + subject + verb, but + subject + also + verb."
        ),

        // MARK: Vocabulary (10 distinct items)
        AdaptiveQuizItem(
            id: "aq-v01", domain: "Vocabulary", skillCategory: "Academic Verbs",
            prompt: "Riparian buffer strips help ___ phosphorus runoff into freshwater rivers.",
            options: ["mitigate", "exacerbate", "fluctuate", "speculate"], correctIndex: 0,
            explanation: "'Mitigate' means to reduce the severity or harmful impact of something.",
            arabicExplanation: "كلمة mitigate تعني يخفف أو يقلل من حدة الضرر، وهي من أهم أفعال IELTS الأكاديمية.",
            teachingTip: "Collocate 'mitigate' with risk, impact, climate change, or runoff."
        ),
        AdaptiveQuizItem(
            id: "aq-v02", domain: "Vocabulary", skillCategory: "Scientific Terminology",
            prompt: "'Empirical evidence' refers specifically to evidence derived from:",
            options: ["personal intuition", "observation and experiment", "historical folklore", "legal opinion"], correctIndex: 1,
            explanation: "'Empirical' means verifiable by observation or experiment rather than pure theory.",
            arabicExplanation: "كلمة empirical تعني تجريبي أو مبني على الملاحظة والقياس الفعلي.",
            teachingTip: "Pair 'empirical' with evidence, data, validation, or study."
        ),
        AdaptiveQuizItem(
            id: "aq-v03", domain: "Vocabulary", skillCategory: "Task 1 Data Lexis",
            prompt: "Global wheat prices ___ erratically between 2019 and 2023 without settling on a single trend.",
            options: ["plateaued", "fluctuated", "plummeted", "stagnated"], correctIndex: 1,
            explanation: "'Fluctuate' describes repeated irregular rises and falls.",
            arabicExplanation: "كلمة fluctuated تعني تذبذبت صعوداً وهبوطاً بشكل غير منتظم.",
            teachingTip: "Use 'fluctuated' for up-and-down movement; 'plateaued' for flattening after growth."
        ),
        AdaptiveQuizItem(
            id: "aq-v04", domain: "Vocabulary", skillCategory: "Academic Collocations",
            prompt: "Unplanned urban sprawl can ___ traffic congestion and air pollution.",
            options: ["alleviate", "corroborate", "exacerbate", "allocate"], correctIndex: 2,
            explanation: "'Exacerbate' means to make an existing problem worse.",
            arabicExplanation: "كلمة exacerbate تعني يفاقم أو يزيد المشكلة سوءاً.",
            teachingTip: "Strong Task 2 contrast pair: mitigate (reduce harm) vs exacerbate (worsen harm)."
        ),
        AdaptiveQuizItem(
            id: "aq-v05", domain: "Vocabulary", skillCategory: "Academic Verbs",
            prompt: "Independent field trials ___ the laboratory findings on seaweed feed additives.",
            options: ["corroborated", "contradictedly", "evaporated", "fabricated"], correctIndex: 0,
            explanation: "'Corroborate' means to confirm or give independent support to a finding.",
            arabicExplanation: "كلمة corroborated تعني أيّدت أو أكّدت النتائج بأدلة مستقلة.",
            teachingTip: "Great Band 8 academic verb for synthesizing two studies."
        ),
        AdaptiveQuizItem(
            id: "aq-v06", domain: "Vocabulary", skillCategory: "Phrasal Verbs & Proportions",
            prompt: "Agriculture ___ roughly 37% of national emissions in the annual inventory.",
            options: ["accounted for", "phased out", "brought about", "carried out"], correctIndex: 0,
            explanation: "'Account for' means to constitute or represent a specified proportion of a total.",
            arabicExplanation: "عبارة accounted for تعني شكّلت أو مثّلت نسبة كذا من الإجمالي.",
            teachingTip: "Essential Task 1 verb for pie charts and tables."
        ),
        AdaptiveQuizItem(
            id: "aq-v07", domain: "Vocabulary", skillCategory: "Academic Adjectives",
            prompt: "Prolonged sleep deprivation has a ___ effect on working memory and vigilance.",
            options: ["pragmatic", "detrimental", "viable", "ubiquitous"], correctIndex: 1,
            explanation: "'Detrimental' means harmful or damaging in formal academic register.",
            arabicExplanation: "كلمة detrimental تعني ضار أو مؤذٍ بأسلوب أكاديمي رسمي (بديل ممتاز لـ bad).",
            teachingTip: "Replace 'very bad effect' with 'a detrimental impact on'."
        ),
        AdaptiveQuizItem(
            id: "aq-v08", domain: "Vocabulary", skillCategory: "Academic Connectors",
            prompt: "Vertical farms consume significant electricity; ___, they cut freshwater usage by over 90%.",
            options: ["consequently", "nevertheless", "moreover", "similarly"], correctIndex: 1,
            explanation: "'Nevertheless' introduces a contrasting fact that stands in spite of the previous point.",
            arabicExplanation: "كلمة nevertheless تعني ومع ذلك، وتربط بين فكرتين متقابلتين.",
            teachingTip: "Use semicolon + nevertheless + comma to link contrasting clauses."
        ),
        AdaptiveQuizItem(
            id: "aq-v09", domain: "Vocabulary", skillCategory: "Academic Adjectives",
            prompt: "Anaerobic digestion provides an economically ___ pathway to convert farm slurry into biogas.",
            options: ["viable", "vulnerable", "volatile", "vague"], correctIndex: 0,
            explanation: "'Viable' means practically and economically feasible.",
            arabicExplanation: "كلمة viable تعني قابل للتطبيق ومجدٍ عملياً واقتصادياً.",
            teachingTip: "Collocate: 'economically viable', 'a viable alternative'."
        ),
        AdaptiveQuizItem(
            id: "aq-v10", domain: "Vocabulary", skillCategory: "Academic Nouns",
            prompt: "The census highlights a widening ___ between metropolitan and rural broadband speeds.",
            options: ["disparity", "resilience", "stewardship", "bioavailability"], correctIndex: 0,
            explanation: "'Disparity' refers to a noticeable gap or inequality between two groups.",
            arabicExplanation: "كلمة disparity تعني تفاوتاً أو فجوة واضحة بين فئتين.",
            teachingTip: "Collocate: 'widening disparity', 'bridge the disparity'."
        ),

        // MARK: Academic Reading Comprehension (8 distinct items)
        AdaptiveQuizItem(
            id: "aq-r01", domain: "Reading", skillCategory: "True / False / Not Given",
            prompt: "Excerpt: 'Although upfront costs deterred smaller farms during year one, lower waste fees allowed most participants to break even within 36 months.'\nStatement: Most smaller farms went bankrupt in year one.",
            options: ["TRUE", "FALSE", "NOT GIVEN"], correctIndex: 1,
            explanation: "The passage says upfront costs deterred some smaller farms, but most participants broke even within 36 months—contradicting 'went bankrupt'.",
            arabicExplanation: "النص يذكر أن معظم المشاركين وصلوا لنقطة التعادل المالي خلال 36 شهراً، وهذا يناقض ادعاء الإفلاس فتكون الإجابة FALSE.",
            teachingTip: "FALSE = direct contradiction; NOT GIVEN = no evidence either way."
        ),
        AdaptiveQuizItem(
            id: "aq-r02", domain: "Reading", skillCategory: "True / False / Not Given",
            prompt: "Excerpt: 'Adaptive governance revises technical standards every three years as empirical datasets mature, outperforming rigid statutes.'\nStatement: Adaptive governance was first invented in Canada in 1984.",
            options: ["TRUE", "FALSE", "NOT GIVEN"], correctIndex: 2,
            explanation: "No origin country or year is mentioned in the excerpt.",
            arabicExplanation: "لم يذكر النص البلد أو السنة التي نشأ فيها هذا النموذج، لذا الإجابة NOT GIVEN.",
            teachingTip: "Never use outside background knowledge in IELTS Reading; rely strictly on the text."
        ),
        AdaptiveQuizItem(
            id: "aq-r03", domain: "Reading", skillCategory: "Paraphrasing & Inference",
            prompt: "Excerpt: 'When new motorway lanes open, faster travel temporarily attracts latent motorists until gridlock re-emerges.'\nWhat does this phenomenon imply?",
            options: [
                "Widening urban roads permanently eliminates traffic jams.",
                "Extra road capacity tends to generate additional driving demand.",
                "Motorists prefer rail over new motorways."
            ],
            correctIndex: 1,
            explanation: "'Attracts latent motorists until gridlock re-emerges' paraphrases induced demand.",
            arabicExplanation: "العبارة تشير بوضوح إلى أن توسيع الطرق يجذب سائقين إضافيين فتعود الازدحامات مجدداً.",
            teachingTip: "Look for synonyms: 'attracts latent motorists' = 'generates additional driving demand'."
        ),
        AdaptiveQuizItem(
            id: "aq-r04", domain: "Reading", skillCategory: "Matching Headings",
            prompt: "Paragraph: 'Municipal agencies, universities, and private labs often archive metrics in incompatible file formats, delaying regional meta-analyses. Open metadata standards are now bridging this gap.'\nBest heading:",
            options: [
                "i. Overcoming barriers to shared scientific data",
                "ii. Why private laboratories outperform universities",
                "iii. Funding cuts in municipal transport"
            ],
            correctIndex: 0,
            explanation: "The central idea is incompatible data formats and how open metadata standards resolve them.",
            arabicExplanation: "الفكرة المحورية للفقرة هي معالجة عدم توافق صيغ البيانات عبر معايير مفتوحة.",
            teachingTip: "Match the main idea of the whole paragraph, not a single repeated word."
        ),
        AdaptiveQuizItem(
            id: "aq-r05", domain: "Reading", skillCategory: "Author Tone & Caveats",
            prompt: "Excerpt: 'While early pasture trials recorded a 24% methane drop, voluntary enrolment may have introduced selection bias; randomized multi-season trials remain essential.'\nThe author's attitude is:",
            options: ["Dismissive and hostile", "Cautiously optimistic and evidence-based", "Uncritically enthusiastic"], correctIndex: 1,
            explanation: "The author acknowledges strong initial numbers while noting methodological caveats.",
            arabicExplanation: "الكاتب متفائل بحذر علمي؛ يذكر النتيجة الإيجابية مع التنبيه لضرورة تجارب عشوائية أوسع.",
            teachingTip: "Words like 'while', 'may have', and 'remain essential' signal balanced academic caution."
        ),
        AdaptiveQuizItem(
            id: "aq-r06", domain: "Reading", skillCategory: "Scanning & Detail",
            prompt: "Excerpt: 'Participatory usability testing adds roughly four weeks to initial schedules, yet prevents costly post-launch retrofits and reduced manual overrides within six months.'\nHow long does participatory testing add to initial schedules?",
            options: ["Six months", "Four weeks", "Two years"], correctIndex: 1,
            explanation: "Four weeks is added to initial schedules; six months refers to manual override reduction.",
            arabicExplanation: "أربعة أسابيع هي المدة المضافة للجدول الأولي، أما ستة أشهر فتتعلق بانخفاض التدخل اليدوي (مشتت زمني).",
            teachingTip: "Watch for nearby numbers referring to different actions."
        ),
        AdaptiveQuizItem(
            id: "aq-r07", domain: "Reading", skillCategory: "Paraphrasing & Inference",
            prompt: "Excerpt: 'Cooperative equipment sharing in Cork halved per-unit diagnostic expenses for smallholders.'\nWhich option accurately paraphrases this?",
            options: [
                "Diagnostic costs dropped by roughly 50% through joint ownership.",
                "Smallholders paid twice as much for equipment in Cork.",
                "Only large corporations benefited from diagnostics."
            ],
            correctIndex: 0,
            explanation: "'Halved' equals a 50% reduction, and 'cooperative sharing' equals joint ownership.",
            arabicExplanation: "كلمة halved تعني انخفضت إلى النصف (50%) بفضل التشارك التعاوني.",
            teachingTip: "IELTS Reading loves numeric paraphrases: halved = 50% lower, tripled = threefold rise."
        ),
        AdaptiveQuizItem(
            id: "aq-r08", domain: "Reading", skillCategory: "Yes / No / Not Given",
            prompt: "Excerpt: 'Technical excellence alone cannot sustain public legitimacy unless transition costs are distributed equitably.'\nWriter's claim: Superior engineering by itself guarantees public support.",
            options: ["YES", "NO", "NOT GIVEN"], correctIndex: 1,
            explanation: "The writer explicitly denies that technical excellence alone sustains public legitimacy.",
            arabicExplanation: "الكاتب ينفي صراحة أن التفوق التقني وحده يكفي لكسب الشرعية الشعبية، فتكون الإجابة NO.",
            teachingTip: "YES/NO/NOT GIVEN tests the writer's views and claims."
        ),

        // MARK: Listening Comprehension & Distractors (8 distinct items)
        AdaptiveQuizItem(
            id: "aq-l01", domain: "Listening", skillCategory: "Listening Distractors",
            prompt: "Listen to the clip: What is the CONFIRMED day for the research seminar?",
            audioScript: "Hello, I originally booked the agricultural research seminar for Tuesday morning, actually sorry, the director moved it to Thursday at nine thirty.",
            options: ["Tuesday", "Wednesday", "Thursday", "Friday"], correctIndex: 2,
            explanation: "The speaker self-corrects from Tuesday to Thursday.",
            arabicExplanation: "المتحدث صحّح الموعد من الثلاثاء إلى الخميس؛ انتبه دائماً لعبارات التصحيح مثل 'actually sorry'.",
            teachingTip: "Never stop listening after the first date or number; IELTS frequently inserts self-corrections."
        ),
        AdaptiveQuizItem(
            id: "aq-l02", domain: "Listening", skillCategory: "Listening Distractors",
            prompt: "Listen to the clip: How many field sites did the two students FINALLY agree to survey?",
            audioScript: "Liam: I wanted to sample thirty farms, which seemed manageable. Maya: Thirty gives weak statistical power—let's survey sixty farms across three counties instead. Liam: Fair point, sixty it is.",
            options: ["30 farms", "45 farms", "60 farms", "90 farms"], correctIndex: 2,
            explanation: "Liam initially suggested 30, but they finally agreed on 60 farms.",
            arabicExplanation: "اقترح ليام 30 في البداية لكنهما اتفقا في النهاية على 60 مزرعة.",
            teachingTip: "In Part 3 discussions, listen for the final consensus ('Fair point, sixty it is')."
        ),
        AdaptiveQuizItem(
            id: "aq-l03", domain: "Listening", skillCategory: "Listening Numbers & Fees",
            prompt: "Listen to the clip: What is the discounted student workshop fee?",
            audioScript: "The standard registration fee is one hundred and eighty euros, though postgraduate students with a valid university card pay one hundred and fifteen euros including lunch.",
            options: ["115 euros", "150 euros", "180 euros", "215 euros"], correctIndex: 0,
            explanation: "180 is the standard fee; 115 euros is the postgraduate student fee.",
            arabicExplanation: "180 يورو هو السعر العادي، بينما السعر المخفّض للطلاب هو 115 يورو.",
            teachingTip: "Distinguish '-teen' (fifteen: 15) from '-ty' (fifty: 50) carefully."
        ),
        AdaptiveQuizItem(
            id: "aq-l04", domain: "Listening", skillCategory: "Listening Map & Location",
            prompt: "Listen to the clip: Where should visitors park today?",
            audioScript: "Welcome to the research station. Please note that the east gate car park is closed for resurfacing today, so all visitors should use the north car park beside the weather station.",
            options: ["East gate car park", "North car park", "South auditorium", "West greenhouse"], correctIndex: 1,
            explanation: "East gate is closed; visitors must use the north car park.",
            arabicExplanation: "البوابة الشرقية مغلقة للصيانة، لذا يجب استخدام موقف الشمال (north car park).",
            teachingTip: "Listen for negation/closure words ('closed for resurfacing') that eliminate the first option."
        ),
        AdaptiveQuizItem(
            id: "aq-l05", domain: "Listening", skillCategory: "Listening Academic Signposting",
            prompt: "Listen to the lecture clip: According to the lecturer, what matters JUST AS MUCH as engineering hardware?",
            audioScript: "While automated sensors clearly improved precision, cooperative sharing models in Cork lowered costs by half, proving that institutional design matters just as much as engineering hardware.",
            options: ["Institutional design", "Weather satellites", "Private marketing", "Import tariffs"], correctIndex: 0,
            explanation: "The lecturer concludes that institutional design matters just as much as engineering hardware.",
            arabicExplanation: "المحاضر يختم بأن التصميم المؤسسي (institutional design) لا يقل أهمية عن الأجهزة الهندسية.",
            teachingTip: "Listen closely to concluding verbs like 'proving that...' and 'demonstrating that...'."
        ),
        AdaptiveQuizItem(
            id: "aq-l06", domain: "Listening", skillCategory: "Listening Detail",
            prompt: "Listen to the clip: What is the photography rule inside the public galleries?",
            audioScript: "Visitors are welcome to take photographs in all public galleries, provided that camera flash is turned off to protect sensitive historical specimens.",
            options: ["Completely prohibited", "Allowed without flash", "Allowed only with a tripod", "Restricted to staff"], correctIndex: 1,
            explanation: "Photography is allowed provided flash is turned off.",
            arabicExplanation: "التصوير مسموح بشرط إيقاف الفلاش لحماية العينات.",
            teachingTip: "Condition markers ('provided that', 'as long as') carry the exact answer."
        ),
        AdaptiveQuizItem(
            id: "aq-l07", domain: "Listening", skillCategory: "Listening Detail",
            prompt: "Listen to the clip: Which document must the students submit by Friday?",
            audioScript: "Before we run the pilot survey in October, we have to submit our ethics form by Friday afternoon so the committee can approve our consent sheet.",
            options: ["Final thesis", "Ethics form", "Travel budget", "Lab invoice"], correctIndex: 1,
            explanation: "They must submit the ethics form by Friday.",
            arabicExplanation: "المستند المطلوب تسليمه يوم الجمعة هو نموذج الأخلاقيات (ethics form).",
            teachingTip: "Track sequence words ('Before...', 'by Friday') in Part 3 flowchart questions."
        ),
        AdaptiveQuizItem(
            id: "aq-l08", domain: "Listening", skillCategory: "Listening Distractors",
            prompt: "Listen to the clip: Which device must participants bring to the workshop?",
            audioScript: "Caller: Should I bring my tablet for the data session? Coordinator: A tablet is fine for reading notes, but you will actually need a laptop to run the statistical sheets.",
            options: ["A smartphone", "A tablet", "A laptop", "A printed binder"], correctIndex: 2,
            explanation: "The coordinator clarifies that a laptop is required for the statistical sheets.",
            arabicExplanation: "المنسّق أوضح أن الجهاز اللوحي يكفي للقراءة فقط، لكنك تحتاج إلى حاسوب محمول (laptop) للتحليل الإحصائي.",
            teachingTip: "'...is fine for X, but you will actually need Y' is a classic IELTS Part 1 pivot."
        )
    ]

    /// Selects a fresh, non-repeating balanced diagnostic/practice set (default 10 questions:
    /// 4 Grammar, 2 Vocabulary, 2 Reading, 2 Listening) avoiding `seenIDs`.
    /// When all items in a domain have been seen, resets that domain cleanly so the user can always continue.
    public static func drawFreshSet(excluding seenIDs: Set<String>, countPerDomain: (grammar: Int, vocab: Int, reading: Int, listening: Int) = (4, 2, 2, 2)) -> (items: [AdaptiveQuizItem], didWrapPool: Bool) {
        var wrapped = false

        func pick(domain: String, count: Int) -> [AdaptiveQuizItem] {
            let allInDomain = corePool.filter { $0.domain == domain }
            let unseen = allInDomain.filter { !seenIDs.contains($0.id) }.shuffled()
            if unseen.count >= count {
                return Array(unseen.prefix(count))
            }
            wrapped = true
            let remainder = allInDomain.filter { !unseen.contains($0) }.shuffled()
            return Array((unseen + remainder).prefix(count))
        }

        let g = pick(domain: "Grammar", count: countPerDomain.grammar)
        let v = pick(domain: "Vocabulary", count: countPerDomain.vocab)
        let r = pick(domain: "Reading", count: countPerDomain.reading)
        let l = pick(domain: "Listening", count: countPerDomain.listening)

        return (g + v + r + l, wrapped)
    }

    /// Computes per-skill accuracy breakdown from a completed quiz so the UI can highlight
    /// exact weaknesses and launch targeted teaching sessions.
    public static func analyzeWeaknesses(items: [AdaptiveQuizItem], selectedAnswers: [String: Int]) -> [SkillWeaknessReport] {
        let grouped = Dictionary(grouping: items, by: \.skillCategory)
        return grouped.map { skill, group in
            let correct = group.filter { selectedAnswers[$0.id] == $0.correctIndex }.count
            return SkillWeaknessReport(
                id: skill,
                skillCategory: skill,
                domain: group.first?.domain ?? "General",
                correct: correct,
                total: group.count,
                sampleTip: group.first?.teachingTip ?? ""
            )
        }
        .sorted { lhs, rhs in
            if lhs.accuracy != rhs.accuracy { return lhs.accuracy < rhs.accuracy }
            return lhs.total > rhs.total
        }
    }
}
