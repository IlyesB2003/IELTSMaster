import Foundation

/// Comprehensive Academic, IELTS, Collocations, Connectors, Phrasal Verbs,
/// and Scientific/Agricultural vocabulary bank with IPA, Arabic translations,
/// collocations, word families, and SM-2 spaced repetition defaults.
public enum VocabularyBank {
    public static func defaultVocabularyItems() -> [VocabularyItem] {
        [
            VocabularyItem(
                id: "voc-001", word: "mitigate", partOfSpeech: "verb", ipa: "/ˈmɪt.ɪ.ɡeɪt/",
                category: "Academic English", cefrLevel: .c1,
                definition: "To make something harmful, unpleasant, or severe less intense or serious.",
                arabicTranslation: "يخفف / يحد من حدة",
                exampleSentence: "Cover cropping can mitigate topsoil erosion during heavy winter rainfall.",
                collocations: ["mitigate the impact of", "mitigate climate risk", "mitigation strategy"],
                synonyms: ["alleviate", "reduce", "curb"],
                wordFamily: ["mitigate", "mitigation", "mitigating"]
            ),
            VocabularyItem(
                id: "voc-002", word: "substantial", partOfSpeech: "adjective", ipa: "/səbˈstæn.ʃəl/",
                category: "IELTS Writing Task 1", cefrLevel: .b2,
                definition: "Large in amount, value, or importance.",
                arabicTranslation: "كبير / جوهري / ملموس",
                exampleSentence: "There was a substantial increase in renewable electricity generation between 2012 and 2022.",
                collocations: ["substantial increase", "substantial proportion", "substantial evidence"],
                synonyms: ["considerable", "significant", "marked"],
                wordFamily: ["substance", "substantial", "substantially"]
            ),
            VocabularyItem(
                id: "voc-003", word: "fluctuate", partOfSpeech: "verb", ipa: "/ˈflʌk.tʃu.eɪt/",
                category: "IELTS Writing Task 1", cefrLevel: .b2,
                definition: "To rise and fall irregularly in number, level, or amount.",
                arabicTranslation: "يتذبذب / يتقلب",
                exampleSentence: "Global grain prices fluctuated markedly throughout the five-year period.",
                collocations: ["fluctuate wildly", "fluctuate between X and Y", "seasonal fluctuation"],
                synonyms: ["vary", "oscillate"],
                wordFamily: ["fluctuate", "fluctuation", "fluctuating"]
            ),
            VocabularyItem(
                id: "voc-004", word: "empirical", partOfSpeech: "adjective", ipa: "/ɪmˈpɪr.ɪ.kəl/",
                category: "Scientific Research", cefrLevel: .c1,
                definition: "Based on observation, measurement, or experiment rather than pure theory.",
                arabicTranslation: "تجريبي / قائم على الملاحظة والتجربة",
                exampleSentence: "The hypothesis requires empirical validation across multiple commercial herds.",
                collocations: ["empirical evidence", "empirical study", "empirical data"],
                synonyms: ["observational", "experimental"],
                wordFamily: ["empirical", "empirically", "empiricism"]
            ),
            VocabularyItem(
                id: "voc-005", word: "sustainable", partOfSpeech: "adjective", ipa: "/səˈsteɪ.nə.bəl/",
                category: "Environmental & Agricultural", cefrLevel: .b2,
                definition: "Capable of continuing over the long term without depleting natural resources.",
                arabicTranslation: "مستدام",
                exampleSentence: "Ireland's agri-food sector prioritizes sustainable pasture-based livestock systems.",
                collocations: ["sustainable development", "environmentally sustainable", "sustainable yield"],
                synonyms: ["viable", "renewable"],
                wordFamily: ["sustain", "sustainable", "sustainability"]
            ),
            VocabularyItem(
                id: "voc-006", word: "consequently", partOfSpeech: "adverb", ipa: "/ˈkɒn.sɪ.kwənt.li/",
                category: "Academic Connectors", cefrLevel: .b2,
                definition: "As a logical result or effect of what has just been stated.",
                arabicTranslation: "وبالتالي / نتيجةً لذلك",
                exampleSentence: "Antibiotic overuse accelerated resistance; consequently, stricter veterinary regulations were enacted.",
                collocations: ["consequently led to", "and consequently"],
                synonyms: ["therefore", "accordingly", "as a result"],
                wordFamily: ["consequence", "consequent", "consequently"]
            ),
            VocabularyItem(
                id: "voc-007", word: "nevertheless", partOfSpeech: "adverb", ipa: "/ˌnev.ə.ðəˈles/",
                category: "Academic Connectors", cefrLevel: .c1,
                definition: "In spite of that; introducing a contrasting point that does not cancel the previous fact.",
                arabicTranslation: "ومع ذلك / رغم ذلك",
                exampleSentence: "Vertical farming requires high electricity input; nevertheless, it slashes water use by over 90%.",
                collocations: ["nevertheless remain", "but nevertheless"],
                synonyms: ["nonetheless", "however", "yet"],
                wordFamily: ["nevertheless"]
            ),
            VocabularyItem(
                id: "voc-008", word: "allocate", partOfSpeech: "verb", ipa: "/ˈæl.ə.keɪt/",
                category: "Academic English", cefrLevel: .c1,
                definition: "To distribute resources, funds, or time for a specific purpose.",
                arabicTranslation: "يخصص (موارد أو ميزانية)",
                exampleSentence: "Governments should allocate a greater share of funding to preventative healthcare.",
                collocations: ["allocate resources", "allocate funds to", "resource allocation"],
                synonyms: ["assign", "distribute", "earmark"],
                wordFamily: ["allocate", "allocation", "reallocate"]
            ),
            VocabularyItem(
                id: "voc-009", word: "detrimental", partOfSpeech: "adjective", ipa: "/ˌdet.rɪˈmen.təl/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "Tending to cause harm or damage.",
                arabicTranslation: "ضار / مؤذٍ",
                exampleSentence: "Prolonged sleep deprivation has a detrimental effect on cognitive performance.",
                collocations: ["detrimental impact on", "detrimental to health", "profoundly detrimental"],
                synonyms: ["harmful", "damaging", "adverse"],
                wordFamily: ["detriment", "detrimental", "detrimentally"]
            ),
            VocabularyItem(
                id: "voc-010", word: "correlate", partOfSpeech: "verb", ipa: "/ˈkɒr.ə.leɪt/",
                category: "Scientific Research", cefrLevel: .c1,
                definition: "To have a mutual relationship or statistical connection between two variables.",
                arabicTranslation: "يرتبط إحصائياً / يتلازم مع",
                exampleSentence: "Higher dietary fibre intake correlates strongly with improved metabolic health.",
                collocations: ["correlate closely with", "positive correlation", "correlation does not imply causation"],
                synonyms: ["associate", "link"],
                wordFamily: ["correlate", "correlation", "correlated"]
            ),
            VocabularyItem(
                id: "voc-011", word: "bioavailability", partOfSpeech: "noun", ipa: "/ˌbaɪ.əʊ.əˌveɪ.ləˈbɪl.ə.ti/",
                category: "Animal Nutrition & Biotech", cefrLevel: .c2,
                definition: "The proportion of a nutrient or active compound that is absorbed and utilized by an organism.",
                arabicTranslation: "التوافر الحيوي (نسبة امتصاص العنصر الغذائي)",
                exampleSentence: "Chelated trace minerals exhibit higher bioavailability in dairy cattle diets.",
                collocations: ["nutrient bioavailability", "improve bioavailability", "mineral absorption"],
                synonyms: ["biological availability"],
                wordFamily: ["bioavailable", "bioavailability"]
            ),
            VocabularyItem(
                id: "voc-012", word: "fermentation", partOfSpeech: "noun", ipa: "/ˌfɜː.menˈteɪ.ʃən/",
                category: "Animal Nutrition & Biotech", cefrLevel: .c1,
                definition: "A metabolic process in which microorganisms break down carbohydrates anaerobically.",
                arabicTranslation: "التخمير",
                exampleSentence: "Rumen fermentation converts structural plant fibre into volatile fatty acids.",
                collocations: ["rumen fermentation", "anaerobic fermentation", "fermentation profile"],
                synonyms: ["microbial breakdown"],
                wordFamily: ["ferment", "fermentation", "fermented"]
            ),
            VocabularyItem(
                id: "voc-013", word: "eutrophication", partOfSpeech: "noun", ipa: "/juːˌtrɒf.ɪˈkeɪ.ʃən/",
                category: "Environmental & Agricultural", cefrLevel: .c2,
                definition: "Excessive nutrient enrichment in water bodies causing dense algal growth and oxygen depletion.",
                arabicTranslation: "الإثراء الغذائي للمياه (تكاثر الطحالب ونقص الأكسجين)",
                exampleSentence: "Buffer strips along waterways help prevent phosphorus runoff and freshwater eutrophication.",
                collocations: ["freshwater eutrophication", "nutrient runoff", "algal bloom"],
                synonyms: ["nutrient over-enrichment"],
                wordFamily: ["eutrophic", "eutrophication"]
            ),
            VocabularyItem(
                id: "voc-014", word: "account for", partOfSpeech: "phrasal verb", ipa: "/əˈkaʊnt fɔːr/",
                category: "Phrasal Verbs & Data", cefrLevel: .b2,
                definition: "To represent a specific proportion of a total, or to explain the reason for something.",
                arabicTranslation: "يمثل نسبةً من / يفسّر سبباً",
                exampleSentence: "Agriculture accounted for approximately 38% of total national emissions in the dataset.",
                collocations: ["account for X percent", "account for the discrepancy"],
                synonyms: ["comprise", "constitute", "explain"],
                wordFamily: ["account", "accountable", "accountability"]
            ),
            VocabularyItem(
                id: "voc-015", word: "phase out", partOfSpeech: "phrasal verb", ipa: "/feɪz aʊt/",
                category: "Phrasal Verbs & Data", cefrLevel: .b2,
                definition: "To gradually discontinue or withdraw a practice, product, or policy.",
                arabicTranslation: "يتخلص تدريجياً من",
                exampleSentence: "Several European nations plan to phase out coal-fired power plants before 2035.",
                collocations: ["gradually phase out", "phase out subsidies", "phase out single-use plastics"],
                synonyms: ["gradually eliminate", "discontinue"],
                wordFamily: ["phase"]
            ),
            VocabularyItem(
                id: "voc-016", word: "viable", partOfSpeech: "adjective", ipa: "/ˈvaɪ.ə.bəl/",
                category: "Academic English", cefrLevel: .c1,
                definition: "Capable of working successfully; feasible economically, practically, or biologically.",
                arabicTranslation: "قابل للتطبيق / مجدٍ عملياً",
                exampleSentence: "Anaerobic digestion offers an economically viable way to convert farm slurry into energy.",
                collocations: ["economically viable", "viable alternative", "long-term viability"],
                synonyms: ["feasible", "workable", "practical"],
                wordFamily: ["viable", "viability"]
            ),
            VocabularyItem(
                id: "voc-017", word: "disparity", partOfSpeech: "noun", ipa: "/dɪˈspær.ə.ti/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "A noticeable and often unfair difference between two groups or measurements.",
                arabicTranslation: "تفاوت / فجوة",
                exampleSentence: "The chart reveals a widening disparity between urban and rural broadband access.",
                collocations: ["growing disparity", "income disparity", "bridge the disparity"],
                synonyms: ["gap", "inequality", "imbalance"],
                wordFamily: ["disparate", "disparity"]
            ),
            VocabularyItem(
                id: "voc-018", word: "ubiquitous", partOfSpeech: "adjective", ipa: "/juːˈbɪk.wɪ.təs/",
                category: "IELTS Vocabulary", cefrLevel: .c2,
                definition: "Seeming to be present everywhere at the same time.",
                arabicTranslation: "منتشر في كل مكان",
                exampleSentence: "Automated milking sensors have become ubiquitous on modern commercial dairy farms.",
                collocations: ["become ubiquitous", "ubiquitous presence"],
                synonyms: ["pervasive", "omnipresent"],
                wordFamily: ["ubiquitous", "ubiquity"]
            ),
            VocabularyItem(
                id: "voc-019", word: "corroborate", partOfSpeech: "verb", ipa: "/kəˈrɒb.ə.reɪt/",
                category: "Scientific Research", cefrLevel: .c2,
                definition: "To confirm or give independent support to a finding, statement, or theory.",
                arabicTranslation: "يدعم / يؤكد بالأدلة",
                exampleSentence: "Independent field trials corroborated the laboratory findings on seaweed feed additives.",
                collocations: ["corroborate findings", "corroborating evidence"],
                synonyms: ["confirm", "substantiate", "verify"],
                wordFamily: ["corroborate", "corroboration"]
            ),
            VocabularyItem(
                id: "voc-020", word: "resilience", partOfSpeech: "noun", ipa: "/rɪˈzɪl.jəns/",
                category: "Environmental & Agricultural", cefrLevel: .c1,
                definition: "The capacity to recover quickly from shocks, stress, or environmental disruption.",
                arabicTranslation: "المرونة / القدرة على التعافي والصمود",
                exampleSentence: "Multi-species swards improve pasture resilience during summer droughts.",
                collocations: ["climate resilience", "ecological resilience", "build resilience"],
                synonyms: ["adaptability", "robustness"],
                wordFamily: ["resilient", "resilience"]
            ),
            VocabularyItem(
                id: "voc-021", word: "incentivize", partOfSpeech: "verb", ipa: "/ɪnˈsen.tɪ.vaɪz/",
                category: "Professional Communication", cefrLevel: .c1,
                definition: "To motivate or encourage someone to take a particular action through rewards or policy.",
                arabicTranslation: "يحفّز",
                exampleSentence: "Targeted grants can incentivize farmers to adopt precision slurry spreading equipment.",
                collocations: ["financially incentivize", "incentivize adoption", "policy incentive"],
                synonyms: ["encourage", "motivate"],
                wordFamily: ["incentive", "incentivize"]
            ),
            VocabularyItem(
                id: "voc-022", word: "prevalent", partOfSpeech: "adjective", ipa: "/ˈprev.əl.ənt/",
                category: "Academic English", cefrLevel: .c1,
                definition: "Widespread in a particular area or at a particular time.",
                arabicTranslation: "سائد / شائع",
                exampleSentence: "Preventative biosecurity protocols have made the disease far less prevalent.",
                collocations: ["increasingly prevalent", "high prevalence of"],
                synonyms: ["widespread", "common", "predominant"],
                wordFamily: ["prevail", "prevalent", "prevalence"]
            ),
            VocabularyItem(
                id: "voc-023", word: "exacerbate", partOfSpeech: "verb", ipa: "/ɪɡˈzæs.ə.beɪt/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "To make an existing problem, bad situation, or negative feeling worse.",
                arabicTranslation: "يفاقم / يزيد سوءاً",
                exampleSentence: "Unplanned urban sprawl can exacerbate traffic congestion and air pollution.",
                collocations: ["exacerbate inequality", "exacerbate the crisis"],
                synonyms: ["worsen", "aggravate", "intensify"],
                wordFamily: ["exacerbate", "exacerbation"]
            ),
            VocabularyItem(
                id: "voc-024", word: "pragmatic", partOfSpeech: "adjective", ipa: "/præɡˈmæt.ɪk/",
                category: "Professional Communication", cefrLevel: .c1,
                definition: "Dealing with issues sensibly and realistically based on practical considerations.",
                arabicTranslation: "عملي / واقعي",
                exampleSentence: "A pragmatic transition plan balances environmental targets with farm profitability.",
                collocations: ["pragmatic approach", "pragmatic solution"],
                synonyms: ["practical", "realistic"],
                wordFamily: ["pragmatic", "pragmatically", "pragmatism"]
            ),
            // Band 7.5 – 9.0 High-Impact Academic Lexicon Expansion (voc-025 .. voc-060)
            VocabularyItem(
                id: "voc-025", word: "prohibitive", partOfSpeech: "adjective", ipa: "/prəˈhɪb.ɪ.tɪv/",
                category: "IELTS Writing Task 2", cefrLevel: .c2,
                definition: "So high in price or cost as to prevent people or organizations from buying or doing something.",
                arabicTranslation: "باهظ جداً (مانع للتطبيق)",
                exampleSentence: "Prohibitive upfront capital costs often deter smallholders from installing anaerobic digesters.",
                collocations: ["prohibitive cost", "financially prohibitive"],
                synonyms: ["exorbitant", "unaffordable"],
                wordFamily: ["prohibit", "prohibitive", "prohibition"]
            ),
            VocabularyItem(
                id: "voc-026", word: "diminishing returns", partOfSpeech: "noun phrase", ipa: "/dɪˈmɪn.ɪ.ʃɪŋ rɪˈtɜːnz/",
                category: "Economics & Policy", cefrLevel: .c2,
                definition: "A point at which additional investment or effort yields progressively smaller increases in output.",
                arabicTranslation: "تناقص العوائد الحدية",
                exampleSentence: "Widening urban motorways yields diminishing returns as induced demand restores congestion.",
                collocations: ["yield diminishing returns", "point of diminishing returns"],
                synonyms: ["declining marginal benefit"],
                wordFamily: ["diminish", "diminishing"]
            ),
            VocabularyItem(
                id: "voc-027", word: "indispensable", partOfSpeech: "adjective", ipa: "/ˌɪn.dɪˈspen.sə.bəl/",
                category: "Academic English", cefrLevel: .c1,
                definition: "Absolutely necessary; impossible to do without.",
                arabicTranslation: "لا غنى عنه / أساسي للغاية",
                exampleSentence: "Long-term soil monitoring is indispensable for verifying agricultural carbon credits.",
                collocations: ["indispensable tool", "prove indispensable"],
                synonyms: ["essential", "vital", "crucial"],
                wordFamily: ["dispense", "indispensable"]
            ),
            VocabularyItem(
                id: "voc-028", word: "volatile", partOfSpeech: "adjective", ipa: "/ˈvɒl.ə.taɪl/",
                category: "IELTS Writing Task 1", cefrLevel: .c1,
                definition: "Liable to change rapidly and unpredictably, especially for the worse.",
                arabicTranslation: "متقلب / غير مستقر",
                exampleSentence: "Global fertilizer markets remained highly volatile throughout the three-year window.",
                collocations: ["volatile prices", "market volatility", "volatile fatty acids"],
                synonyms: ["unstable", "erratic", "unpredictable"],
                wordFamily: ["volatile", "volatility"]
            ),
            VocabularyItem(
                id: "voc-029", word: "plateau", partOfSpeech: "verb", ipa: "/ˈplæt.əʊ/",
                category: "IELTS Writing Task 1", cefrLevel: .c1,
                definition: "To reach a state of little or no change after a period of activity or growth.",
                arabicTranslation: "يستقر عند مستوى ثابت (بعد صعود)",
                exampleSentence: "Solar adoption climbed sharply until 2021 before plateauing at approximately 42%.",
                collocations: ["plateau at X%", "reach a plateau"],
                synonyms: ["level off", "stabilize"],
                wordFamily: ["plateau", "plateaued"]
            ),
            VocabularyItem(
                id: "voc-030", word: "outstrip", partOfSpeech: "verb", ipa: "/ˌaʊtˈstrɪp/",
                category: "IELTS Writing Task 1", cefrLevel: .c2,
                definition: "To move faster than or exceed another figure or rate significantly.",
                arabicTranslation: "يفوق / يتجاوز بسرعة أكبر",
                exampleSentence: "Urban housing demand outstripped new construction by a factor of two.",
                collocations: ["outstrip supply", "far outstrip"],
                synonyms: ["exceed", "surpass", "outpace"],
                wordFamily: ["outstrip", "outstripped"]
            ),
            VocabularyItem(
                id: "voc-031", word: "marginal", partOfSpeech: "adjective", ipa: "/ˈmɑː.dʒɪ.nəl/",
                category: "IELTS Writing Task 1", cefrLevel: .c1,
                definition: "Very small in amount, proportion, or significance.",
                arabicTranslation: "هامشي / طفيف جداً",
                exampleSentence: "Coal accounted for only a marginal share (3%) of Sweden's 2024 power mix.",
                collocations: ["marginal increase", "marginal share", "marginally higher"],
                synonyms: ["negligible", "slight", "minimal"],
                wordFamily: ["margin", "marginal", "marginally"]
            ),
            VocabularyItem(
                id: "voc-032", word: "divergent", partOfSpeech: "adjective", ipa: "/daɪˈvɜː.dʒənt/",
                category: "Academic English", cefrLevel: .c2,
                definition: "Tending to be different or develop in opposite directions.",
                arabicTranslation: "متباين / متشعب في اتجاهين مختلفين",
                exampleSentence: "The chart reveals sharply divergent trajectories between northern and southern regions.",
                collocations: ["divergent trends", "divergent views", "clear divergence"],
                synonyms: ["contrasting", "conflicting"],
                wordFamily: ["diverge", "divergent", "divergence"]
            ),
            VocabularyItem(
                id: "voc-033", word: "caveat", partOfSpeech: "noun", ipa: "/ˈkæv.i.æt/",
                category: "Scientific Research", cefrLevel: .c2,
                definition: "A warning or limiting condition that must be kept in mind when interpreting a claim.",
                arabicTranslation: "تحفظ / شرط أو قيد منهجي",
                exampleSentence: "An important methodological caveat is that participating farms volunteered for the trial.",
                collocations: ["important caveat", "with the caveat that"],
                synonyms: ["qualification", "proviso", "limitation"],
                wordFamily: ["caveat"]
            ),
            VocabularyItem(
                id: "voc-034", word: "confounding", partOfSpeech: "adjective", ipa: "/kənˈfaʊn.dɪŋ/",
                category: "Scientific Research", cefrLevel: .c2,
                definition: "Describing an extraneous variable that distorts the apparent relationship between cause and effect.",
                arabicTranslation: "مُربك / متغير دخيل يؤثر على النتائج",
                exampleSentence: "Researchers controlled for confounding seasonal factors such as rainfall and forage maturity.",
                collocations: ["confounding variable", "confounding factor"],
                synonyms: ["distorting", "interfering"],
                wordFamily: ["confound", "confounding"]
            ),
            VocabularyItem(
                id: "voc-035", word: "unprecedented", partOfSpeech: "adjective", ipa: "/ʌnˈpres.ɪ.den.tɪd/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "Never done, experienced, or known before.",
                arabicTranslation: "غير مسبوق",
                exampleSentence: "Coastal cities face unprecedented heat and storm-surge pressures.",
                collocations: ["unprecedented scale", "unprecedented rate"],
                synonyms: ["unparalleled", "unmatched"],
                wordFamily: ["precedent", "unprecedented"]
            ),
            VocabularyItem(
                id: "voc-036", word: "dichotomy", partOfSpeech: "noun", ipa: "/daɪˈkɒt.ə.mi/",
                category: "IELTS Writing Task 2", cefrLevel: .c2,
                definition: "A division or sharp contrast between two things represented as entirely opposed.",
                arabicTranslation: "ثنائية متقابلة / انقسام حاد",
                exampleSentence: "Framing farm profitability and climate stewardship as opposites creates a false dichotomy.",
                collocations: ["false dichotomy", "sharp dichotomy between"],
                synonyms: ["polarity", "division"],
                wordFamily: ["dichotomy", "dichotomous"]
            ),
            VocabularyItem(
                id: "voc-037", word: "catalyst", partOfSpeech: "noun", ipa: "/ˈkæt.əl.ɪst/",
                category: "Academic English", cefrLevel: .c1,
                definition: "A person, policy, or event that precipitates rapid and significant change.",
                arabicTranslation: "محفّز / عامل مُسرّع للتغيير",
                exampleSentence: "High-speed rural broadband acted as a catalyst for regional business revitalization.",
                collocations: ["act as a catalyst for", "economic catalyst"],
                synonyms: ["impetus", "stimulus", "trigger"],
                wordFamily: ["catalyst", "catalyze"]
            ),
            VocabularyItem(
                id: "voc-038", word: "curb", partOfSpeech: "verb", ipa: "/kɜːb/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "To restrain, limit, or keep something harmful under control.",
                arabicTranslation: "يكبح / يحدّ من",
                exampleSentence: "Congestion charges can curb peak-hour private car journeys in historic centres.",
                collocations: ["curb emissions", "curb inflation", "curb overuse"],
                synonyms: ["restrain", "check", "limit"],
                wordFamily: ["curb"]
            ),
            VocabularyItem(
                id: "voc-039", word: "stewardship", partOfSpeech: "noun", ipa: "/ˈstjuː.əd.ʃɪp/",
                category: "Environmental & Agricultural", cefrLevel: .c1,
                definition: "The responsible management and protection of resources, land, or medicines entrusted to one's care.",
                arabicTranslation: "الإشراف المسؤول / حسن الإدارة والحماية",
                exampleSentence: "Antimicrobial stewardship programmes preserve antibiotic efficacy for both humans and livestock.",
                collocations: ["environmental stewardship", "antimicrobial stewardship", "land stewardship"],
                synonyms: ["custodianship", "responsible management"],
                wordFamily: ["steward", "stewardship"]
            ),
            VocabularyItem(
                id: "voc-040", word: "equitable", partOfSpeech: "adjective", ipa: "/ˈek.wɪ.tə.bəl/",
                category: "Economics & Policy", cefrLevel: .c1,
                definition: "Fair, impartial, and just in the distribution of costs, rights, or opportunities.",
                arabicTranslation: "عادل / منصف",
                exampleSentence: "Public trust rises when climate transition costs are distributed in an equitable manner.",
                collocations: ["equitable distribution", "equitable access", "socially equitable"],
                synonyms: ["fair", "just", "impartial"],
                wordFamily: ["equity", "equitable", "equitably"]
            ),
            VocabularyItem(
                id: "voc-041", word: "longitudinal", partOfSpeech: "adjective", ipa: "/ˌlɒn.dʒɪˈtjuː.dɪ.nəl/",
                category: "Scientific Research", cefrLevel: .c2,
                definition: "Involving repeated observations of the same subjects or variables over an extended period.",
                arabicTranslation: "طولي (دراسة ممتدة عبر الزمن)",
                exampleSentence: "A ten-year longitudinal study tracked soil carbon accumulation under rotational grazing.",
                collocations: ["longitudinal study", "longitudinal dataset"],
                synonyms: ["long-term observational"],
                wordFamily: ["longitudinal", "longitudinally"]
            ),
            VocabularyItem(
                id: "voc-042", word: "sequestration", partOfSpeech: "noun", ipa: "/ˌsiː.kwesˈtreɪ.ʃən/",
                category: "Environmental & Agricultural", cefrLevel: .c2,
                definition: "The long-term capture and storage of atmospheric carbon dioxide in soils, peatlands, or forests.",
                arabicTranslation: "عزل / احتجاز الكربون",
                exampleSentence: "Peatland rewetting enhances carbon sequestration while attenuating downstream flood peaks.",
                collocations: ["carbon sequestration", "soil carbon sequestration"],
                synonyms: ["capture and storage"],
                wordFamily: ["sequester", "sequestration"]
            ),
            VocabularyItem(
                id: "voc-043", word: "synergy", partOfSpeech: "noun", ipa: "/ˈsɪn.ə.dʒi/",
                category: "Academic English", cefrLevel: .c1,
                definition: "The combined effect of two or more elements working together that exceeds the sum of their individual effects.",
                arabicTranslation: "تآزر / تكامل مثمر",
                exampleSentence: "Combining clover swards with precision slurry application creates a clear environmental synergy.",
                collocations: ["create synergy between", "synergistic effect"],
                synonyms: ["combined benefit", "collaboration"],
                wordFamily: ["synergy", "synergistic"]
            ),
            VocabularyItem(
                id: "voc-044", word: "notwithstanding", partOfSpeech: "preposition", ipa: "/ˌnɒt.wɪðˈstæn.dɪŋ/",
                category: "Academic Connectors", cefrLevel: .c2,
                definition: "In spite of; formal academic equivalent of 'despite'.",
                arabicTranslation: "على الرغم من (أسلوب أكاديمي رفيع)",
                exampleSentence: "Notwithstanding high initial costs, geothermal district heating proved economical within seven years.",
                collocations: ["notwithstanding these limitations", "notwithstanding the challenges"],
                synonyms: ["despite", "in spite of"],
                wordFamily: ["notwithstanding"]
            ),
            VocabularyItem(
                id: "voc-045", word: "albeit", partOfSpeech: "conjunction", ipa: "/ɔːlˈbiː.ɪt/",
                category: "Academic Connectors", cefrLevel: .c1,
                definition: "Although; used to introduce a brief qualifying phrase rather than a full clause.",
                arabicTranslation: "وإن كان / ولو (للتقييد المختصر)",
                exampleSentence: "Regional rail ridership recovered steadily, albeit at a slower pace than metropolitan metro lines.",
                collocations: ["albeit slowly", "albeit at higher cost"],
                synonyms: ["though", "even if"],
                wordFamily: ["albeit"]
            ),
            VocabularyItem(
                id: "voc-046", word: "stem from", partOfSpeech: "phrasal verb", ipa: "/stem frɒm/",
                category: "Phrasal Verbs & Data", cefrLevel: .c1,
                definition: "To originate in or be caused directly by something.",
                arabicTranslation: "ينبع من / ينجم عن",
                exampleSentence: "Many post-harvest grain losses stem from inadequate moisture control during storage.",
                collocations: ["stem primarily from", "stem directly from"],
                synonyms: ["originate from", "arise from"],
                wordFamily: ["stem"]
            ),
            VocabularyItem(
                id: "voc-047", word: "offset", partOfSpeech: "verb", ipa: "/ˌɒfˈset/",
                category: "Economics & Policy", cefrLevel: .c1,
                definition: "To counterbalance or compensate for an undesirable effect or cost.",
                arabicTranslation: "يعوّض / يوازن (تكلفة أو أثراً)",
                exampleSentence: "Lower synthetic fertilizer bills largely offset the initial seed cost of multi-species pastures.",
                collocations: ["offset the cost of", "partially offset", "carbon offset"],
                synonyms: ["counterbalance", "compensate for"],
                wordFamily: ["offset"]
            ),
            VocabularyItem(
                id: "voc-048", word: "undermine", partOfSpeech: "verb", ipa: "/ˌʌn.dəˈmaɪn/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "To gradually weaken or erode the effectiveness, authority, or stability of something.",
                arabicTranslation: "يقوّض / يُضعف تدريجياً",
                exampleSentence: "Routine antibiotic misuse undermines both human medicine and veterinary biosecurity.",
                collocations: ["undermine public trust", "undermine efforts to"],
                synonyms: ["erode", "weaken", "compromise"],
                wordFamily: ["undermine", "undermining"]
            ),
            VocabularyItem(
                id: "voc-049", word: "trajectory", partOfSpeech: "noun", ipa: "/trəˈdʒek.tər.i/",
                category: "IELTS Writing Task 1", cefrLevel: .c1,
                definition: "The path or directional trend followed by a metric, policy, or development over time.",
                arabicTranslation: "مسار / اتجاه تطوري",
                exampleSentence: "Spain's renewable share followed a steep upward trajectory after 2018.",
                collocations: ["upward trajectory", "growth trajectory", "alter the trajectory"],
                synonyms: ["course", "trend", "path"],
                wordFamily: ["trajectory"]
            ),
            VocabularyItem(
                id: "voc-050", word: "interoperability", partOfSpeech: "noun", ipa: "/ˌɪn.tərˌɒp.ər.əˈbɪl.ə.ti/",
                category: "Technology & Data", cefrLevel: .c2,
                definition: "The ability of different computer systems, databases, or organizations to exchange and use data seamlessly.",
                arabicTranslation: "قابلية التشغيل البيني وتبادل البيانات",
                exampleSentence: "Open metadata standards improved data interoperability across European research laboratories.",
                collocations: ["data interoperability", "lack of interoperability"],
                synonyms: ["cross-system compatibility"],
                wordFamily: ["interoperate", "interoperable", "interoperability"]
            ),
            VocabularyItem(
                id: "voc-051", word: "feed conversion ratio", partOfSpeech: "noun phrase", ipa: "/fiːd kənˈvɜː.ʒən ˈreɪ.ʃi.əʊ/",
                category: "Animal Nutrition & Biotech", cefrLevel: .c2,
                definition: "The mass of feed input required per unit of animal weight gain or milk/egg output; lower values indicate higher efficiency.",
                arabicTranslation: "معامل التحويل الغذائي",
                exampleSentence: "Precision amino-acid formulation improved the herd's feed conversion ratio by 7%.",
                collocations: ["improve feed conversion ratio", "optimal FCR"],
                synonyms: ["feed efficiency metric"],
                wordFamily: ["convert", "conversion"]
            ),
            VocabularyItem(
                id: "voc-052", word: "palatability", partOfSpeech: "noun", ipa: "/ˌpæl.ə.təˈbɪl.ə.ti/",
                category: "Animal Nutrition & Biotech", cefrLevel: .c2,
                definition: "The degree to which a feed or food is pleasant and readily consumed.",
                arabicTranslation: "الاستساغة (إقبال الحيوان على العلف)",
                exampleSentence: "High-dose macroalgae additives can reduce ration palatability unless properly formulated.",
                collocations: ["ration palatability", "maintain palatability"],
                synonyms: ["acceptability", "taste appeal"],
                wordFamily: ["palatable", "palatability"]
            ),
            VocabularyItem(
                id: "voc-053", word: "repercussion", partOfSpeech: "noun", ipa: "/ˌriː.pəˈkʌʃ.ən/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "An unintended, often unwelcome consequence occurring sometime after an event or policy.",
                arabicTranslation: "تداعٍ / عاقبة غير مقصودة",
                exampleSentence: "Removing rural hedgerows had severe ecological repercussions for native pollinators.",
                collocations: ["far-reaching repercussions", "economic repercussions"],
                synonyms: ["consequence", "ramification", "fallout"],
                wordFamily: ["repercussion"]
            ),
            VocabularyItem(
                id: "voc-054", word: "ramification", partOfSpeech: "noun", ipa: "/ˌræm.ɪ.fɪˈkeɪ.ʃən/",
                category: "Academic English", cefrLevel: .c2,
                definition: "A complex or unwelcome secondary result of an action or decision.",
                arabicTranslation: "تبعة / تشعّب معقّد",
                exampleSentence: "Policymakers must assess the long-term social ramifications of algorithmic admissions.",
                collocations: ["broader ramifications", "ethical ramifications"],
                synonyms: ["implication", "consequence"],
                wordFamily: ["ramification"]
            ),
            VocabularyItem(
                id: "voc-055", word: "consensus", partOfSpeech: "noun", ipa: "/kənˈsen.səs/",
                category: "Scientific Research", cefrLevel: .c1,
                definition: "General agreement among a group of experts or stakeholders.",
                arabicTranslation: "إجماع / توافق عام",
                exampleSentence: "There is broad scientific consensus that early preventative biosecurity reduces outbreak severity.",
                collocations: ["broad consensus", "scientific consensus", "reach consensus"],
                synonyms: ["agreement", "accord"],
                wordFamily: ["consensus"]
            ),
            VocabularyItem(
                id: "voc-056", word: "scrutinize", partOfSpeech: "verb", ipa: "/ˈskruː.tɪ.naɪz/",
                category: "Scientific Research", cefrLevel: .c1,
                definition: "To examine or inspect closely and critically.",
                arabicTranslation: "يدقّق / يفحص بعناية نقدية",
                exampleSentence: "Independent peer reviewers scrutinize experimental controls before publication.",
                collocations: ["closely scrutinize", "under public scrutiny"],
                synonyms: ["examine closely", "audit", "inspect"],
                wordFamily: ["scrutinize", "scrutiny"]
            ),
            VocabularyItem(
                id: "voc-057", word: "foster", partOfSpeech: "verb", ipa: "/ˈfɒs.tər/",
                category: "Academic English", cefrLevel: .c1,
                definition: "To encourage or promote the development of something desirable.",
                arabicTranslation: "يعزّز / يرعى نموّ",
                exampleSentence: "Open research repositories foster cross-border collaboration among early-career scientists.",
                collocations: ["foster innovation", "foster public trust", "foster collaboration"],
                synonyms: ["promote", "cultivate", "encourage"],
                wordFamily: ["foster"]
            ),
            VocabularyItem(
                id: "voc-058", word: "alleviate", partOfSpeech: "verb", ipa: "/əˈliː.vi.eɪt/",
                category: "IELTS Writing Task 2", cefrLevel: .c1,
                definition: "To make suffering, shortage, or a severe problem less intense.",
                arabicTranslation: "يخفف (من حدة مشكلة أو معاناة)",
                exampleSentence: "Expanding high-frequency commuter rail can alleviate chronic metropolitan congestion.",
                collocations: ["alleviate poverty", "alleviate congestion", "alleviate pressure"],
                synonyms: ["ease", "mitigate", "relieve"],
                wordFamily: ["alleviate", "alleviation"]
            ),
            VocabularyItem(
                id: "voc-059", word: "contentious", partOfSpeech: "adjective", ipa: "/kənˈten.ʃəs/",
                category: "IELTS Writing Task 2", cefrLevel: .c2,
                definition: "Causing or likely to cause heated argument or public disagreement.",
                arabicTranslation: "مثير للجدل",
                exampleSentence: "Carbon pricing on agricultural inputs remains a contentious issue across Europe.",
                collocations: ["highly contentious", "contentious debate"],
                synonyms: ["controversial", "disputed", "divisive"],
                wordFamily: ["contend", "contention", "contentious"]
            ),
            VocabularyItem(
                id: "voc-060", word: "paradigm", partOfSpeech: "noun", ipa: "/ˈpær.ə.daɪm/",
                category: "Academic English", cefrLevel: .c2,
                definition: "A dominant theoretical framework or standard model guiding a discipline.",
                arabicTranslation: "نموذج إرشادي / إطار فكري سائد",
                exampleSentence: "Adaptive governance represents a major paradigm shift away from static command-and-control rules.",
                collocations: ["paradigm shift", "dominant paradigm"],
                synonyms: ["framework", "model", "archetype"],
                wordFamily: ["paradigm", "paradigmatic"]
            )
        ]
    }
}
