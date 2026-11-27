import Foundation

/// Complete 20-topic Grammar curriculum progressing from foundational English
/// to Band 7.5–9.0 academic grammatical range and accuracy, with bilingual Arabic explanations.
public enum GrammarCurriculum {
    public static let lessons: [GrammarLesson] = [
        GrammarLesson(
            id: "gram-01-sentence-structure",
            order: 1,
            title: "Sentence Structure & Clause Foundations",
            cefrRange: "A2–B1",
            summary: "Master English SVO word order, independent clauses, and eliminating fragments and comma splices.",
            detailedRules: [
                "Every independent clause requires a subject and a finite verb (Subject + Verb + Object/Complement).",
                "Never join two independent clauses with only a comma (comma splice). Use a period, semicolon, or coordinating conjunction.",
                "Place time and place adverbials cleanly at the end or beginning of a clause without splitting verb and direct object."
            ],
            examples: [
                "Incorrect: The pasture yield increased, farmers reduced winter feed costs.",
                "Correct: The pasture yield increased, so farmers reduced winter feed costs."
            ],
            commonIELTSTraps: [
                "Writing comma splices in Task 2 body paragraphs lowers Grammatical Range and Accuracy below Band 6."
            ],
            arabicExplanation: "كل جملة مستقلة في الإنجليزية تحتاج إلى فاعل وفعل أساسي. تجنّب ربط جملتين كاملتين بفاصلة فقط (Comma Splice)؛ استخدم نقطة أو فاصلة منقوطة أو أداة ربط مثل so أو therefore.",
            exercises: [
                GrammarExercise(
                    id: "g1-e1",
                    prompt: "Choose the grammatically accurate academic sentence:",
                    options: [
                        "Soil moisture fell sharply, crop yields declined across the region.",
                        "Soil moisture fell sharply; consequently, crop yields declined across the region.",
                        "Because soil moisture fell sharply, therefore crop yields declined."
                    ],
                    correctIndex: 1,
                    explanation: "A semicolon + conjunctive adverb ('consequently') correctly joins two independent clauses without a comma splice or double conjunction.",
                    arabicExplanation: "الفاصلة المنقوطة متبوعة بكلمة consequently تربط الجملتين بشكل أكاديمي صحيح دون خطأ الفاصلة أو تكرار أدوات الربط."
                ),
                GrammarExercise(
                    id: "g1-e2",
                    prompt: "Which sentence avoids a fragment error?",
                    options: [
                        "Although renewable energy investment grew rapidly in Ireland.",
                        "Renewable energy investment, which grew rapidly in Ireland.",
                        "Although renewable energy investment grew rapidly in Ireland, grid capacity lagged behind."
                    ],
                    correctIndex: 2,
                    explanation: "A subordinate clause beginning with 'Although' must be attached to an independent main clause.",
                    arabicExplanation: "الجملة التابعة التي تبدأ بـ Although لا تكفي وحدها؛ يجب أن تتبعها جملة رئيسية مكتملة."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-02-parts-of-speech",
            order: 2,
            title: "Parts of Speech & Word Forms",
            cefrRange: "A2–B2",
            prerequisites: ["gram-01-sentence-structure"],
            summary: "Distinguish nouns, verbs, adjectives, and adverbs accurately in academic nominalization.",
            detailedRules: [
                "Adjectives modify nouns (e.g., 'a significant rise'); adverbs modify verbs, adjectives, or whole clauses ('rose significantly').",
                "Academic English favors precise word-form transitions: 'analyse' (v) -> 'analysis' (n) -> 'analytical' (adj) -> 'analytically' (adv)."
            ],
            examples: [
                "Milk output increased substantially (adverb) / There was a substantial (adjective) increase in milk output."
            ],
            commonIELTSTraps: [
                "Using an adjective where an adverb is required in Writing Task 1 ('increased significant' instead of 'increased significantly')."
            ],
            arabicExplanation: "الصفة تصف الاسم (substantial increase)، بينما الظرف يصف الفعل أو الصفة (increased substantially). الخلط بينهما شائع جداً في مهمة الكتابة الأولى.",
            exercises: [
                GrammarExercise(
                    id: "g2-e1",
                    prompt: "Between 2015 and 2024, dairy exports expanded ___.",
                    options: ["considerable", "considerably", "consideration"],
                    correctIndex: 1,
                    explanation: "An adverb ('considerably') is required to modify the verb 'expanded'.",
                    arabicExplanation: "نحتاج هنا إلى ظرف (considerably) لأنه يصف الفعل expanded."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-03-articles",
            order: 3,
            title: "Articles (a, an, the, zero article)",
            cefrRange: "B1–C1",
            prerequisites: ["gram-02-parts-of-speech"],
            summary: "Control definite, indefinite, and zero articles with countable, uncountable, and plural academic nouns.",
            detailedRules: [
                "Use zero article for general plural and uncountable nouns ('Research shows that antibiotics require careful stewardship').",
                "Use 'the' when the noun is specific, previously mentioned, unique, or post-modified by an 'of' phrase ('the proportion of urban residents').",
                "Singular countable nouns almost always require a determiner (a/an/the/this/their)."
            ],
            examples: [
                "The efficiency of anaerobic digesters depends on temperature stability."
            ],
            commonIELTSTraps: [
                "Arabic speakers frequently add 'the' before general uncountable nouns ('the education is important' -> 'Education is important')."
            ],
            arabicExplanation: "في العربية نستخدم (الـ) مع الأسماء العامة مثل (التعليم مهم)، أما في الإنجليزية فنحذف the عند الحديث بشكل عام عن الأسماء غير المعدودة أو الجمع (Education is important).",
            exercises: [
                GrammarExercise(
                    id: "g3-e1",
                    prompt: "___ sustainable agriculture plays a vital role in food security.",
                    options: ["The", "A", "No article (Ø)"],
                    correctIndex: 2,
                    explanation: "General uncountable concepts ('sustainable agriculture') take the zero article.",
                    arabicExplanation: "المفهوم العام غير المعدود لا يأخذ أداة تعريف في الإنجليزية."
                ),
                GrammarExercise(
                    id: "g3-e2",
                    prompt: "___ percentage of households using solar power doubled in 2023.",
                    options: ["The", "A", "No article (Ø)"],
                    correctIndex: 0,
                    explanation: "Specific proportions defined by an 'of' phrase require the definite article 'The'.",
                    arabicExplanation: "النسبة المحددة بعبارة of تحتاج إلى أداة التعريف The."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-04-pronouns",
            order: 4,
            title: "Pronouns & Cohesive Reference",
            cefrRange: "B1–B2",
            summary: "Use personal, demonstrative, reflexive, and indefinite pronouns clearly to strengthen Cohesion.",
            detailedRules: [
                "Ensure every pronoun ('it', 'they', 'this', 'those') has an unambiguous antecedent.",
                "Use 'this + summary noun' ('This trend', 'This policy') to link sentences cleanly in Task 2 essays."
            ],
            examples: [
                "Water reserves declined by 18%. This shortage prompted stricter irrigation quotas."
            ],
            commonIELTSTraps: [
                "Vague standalone 'this' or 'it' without a clear referent lowers Coherence and Cohesion."
            ],
            arabicExplanation: "استخدام this متبوعاً باسم ملخّص (مثل This trend أو This approach) يمنع الغموض ويرفع درجة الترابط النصي في الكتابة الأكاديمية.",
            exercises: [
                GrammarExercise(
                    id: "g4-e1",
                    prompt: "Antibiotic resistance is rising globally. ___ poses a severe threat to public health.",
                    options: ["This phenomenon", "Them", "These"],
                    correctIndex: 0,
                    explanation: "'This phenomenon' cleanly refers back to the singular clause idea and improves cohesion.",
                    arabicExplanation: "عبارة This phenomenon تشير بوضوح إلى الظاهرة السابقة بصيغة مفردة."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-05-prepositions",
            order: 5,
            title: "Academic Prepositions & Collocations",
            cefrRange: "B1–C1",
            summary: "Use exact prepositions with verbs, adjectives, nouns, and Task 1 data trends.",
            detailedRules: [
                "Data trends: rise BY 10% (amount of change), rise TO 45% (final value), rise FROM 20% TO 30%.",
                "Fixed academic pairings: 'impact ON', 'increase IN', 'depend ON', 'result IN', 'contribute TO', 'responsible FOR', 'despite' (no 'of')."
            ],
            examples: [
                "Methane emissions fell by 12%, dropping from 50 to 44 million tonnes."
            ],
            commonIELTSTraps: [
                "Writing 'discuss about', 'despite of', or confusing 'increase by' with 'increase to'."
            ],
            arabicExplanation: "انتبه للفارق الدقيق في وصف الرسوم البيانية: rose BY تعني مقدار الزيادة، بينما rose TO تعني القيمة النهائية. ولا نضع about بعد discuss.",
            exercises: [
                GrammarExercise(
                    id: "g5-e1",
                    prompt: "Annual wheat production rose ___ 15%, reaching 4.6 million tonnes.",
                    options: ["to", "by", "at"],
                    correctIndex: 1,
                    explanation: "'By' expresses the margin/amount of change (15%).",
                    arabicExplanation: "نستخدم by للتعبير عن مقدار الزيادة أو النقصان."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-06-subject-verb-agreement",
            order: 6,
            title: "Subject-Verb Agreement",
            cefrRange: "B1–C1",
            prerequisites: ["gram-01-sentence-structure"],
            summary: "Match verb number accurately across complex noun phrases, quantifiers, and collective subjects.",
            detailedRules: [
                "Ignore prepositional phrases between subject and verb: 'The quality of the soil samples WAS (not were) high.'",
                "'Each', 'every', 'neither', 'the number of' take singular verbs; 'a number of' takes a plural verb.",
                "Uncountable academic nouns (research, evidence, data in singular usage, equipment, information) take singular verbs."
            ],
            examples: [
                "The number of postgraduate applicants has risen, whereas a number of fellowships remain unfilled."
            ],
            commonIELTSTraps: [
                "Matching the verb to the nearest noun inside an 'of' phrase instead of the head noun."
            ],
            arabicExplanation: "يطابق الفعل الفاعل الرئيسي وليس الاسم القريب الموجود بعد حرف الجر of. كذلك عبارة The number of تأخذ فعلاً مفرداً، بينما A number of تأخذ فعلاً جمعاً.",
            exercises: [
                GrammarExercise(
                    id: "g6-e1",
                    prompt: "The nutritional profile of grass-fed dairy products ___ extensively studied.",
                    options: ["have been", "has been", "are"],
                    correctIndex: 1,
                    explanation: "The head noun is singular ('profile'), so the verb must be singular ('has been').",
                    arabicExplanation: "الفاعل الرئيسي هو profile (مفرد)، لذا نستخدم has been."
                ),
                GrammarExercise(
                    id: "g6-e2",
                    prompt: "Each of the experimental plots ___ monitored daily.",
                    options: ["were", "was", "are"],
                    correctIndex: 1,
                    explanation: "'Each of the + plural noun' always takes a singular verb.",
                    arabicExplanation: "عبارة Each of the يتبعها فعل مفرد دائماً (was)."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-07-simple-tenses",
            order: 7,
            title: "Present, Past, and Future Tenses",
            cefrRange: "A2–B2",
            summary: "Select tense accurately for general facts, completed historical data, and future projections.",
            detailedRules: [
                "Use Present Simple for general truths, processes, and timeless charts.",
                "Use Past Simple for finished historical periods (e.g., 1995–2015 in Task 1).",
                "Use Future structures ('is projected to', 'is expected to', 'will') for forecast data."
            ],
            examples: [
                "By 2035, urban water consumption is projected to exceed 800 million cubic metres."
            ],
            commonIELTSTraps: [
                "Shifting randomly between past and present tense when describing a single historical graph."
            ],
            arabicExplanation: "اختر الزمن بناءً على تواريخ الرسم البياني: الماضي البسيط للتواريخ المنتهية، والمضارع البسيط للحقائق والعمليات، وعبارات التوقع مثل is projected to للمستقبل.",
            exercises: [
                GrammarExercise(
                    id: "g7-e1",
                    prompt: "According to the 2035 forecast, solar output ___ surpass coal generation.",
                    options: ["surpassed", "is projected to", "has surpassed"],
                    correctIndex: 1,
                    explanation: "Future forecasts require future/projection forms such as 'is projected to'.",
                    arabicExplanation: "توقعات عام 2035 المستقبلية تتطلب صيغة التوقع is projected to."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-08-perfect-continuous",
            order: 8,
            title: "Perfect & Continuous Aspects",
            cefrRange: "B1–C1",
            prerequisites: ["gram-07-simple-tenses"],
            summary: "Use Present Perfect, Past Perfect, and Continuous forms for duration, change over time, and sequencing.",
            detailedRules: [
                "Present Perfect ('has increased since 2010') links a past start to the present.",
                "Past Perfect ('had already declined before 2005') clarifies an earlier past event before another past reference point.",
                "Avoid continuous forms with stative verbs ('know', 'belong', 'consist of')."
            ],
            examples: [
                "Precision irrigation has reduced freshwater waste by nearly 30% since its introduction."
            ],
            commonIELTSTraps: [
                "Using Present Simple with 'since' ('She works here since 2022' -> 'She has worked here since 2022')."
            ],
            arabicExplanation: "مع كلمة since لحدث بدأ في الماضي وما زال مستمراً نستخدم المضارع التام (has/have + التصريف الثالث) وليس المضارع البسيط.",
            exercises: [
                GrammarExercise(
                    id: "g8-e1",
                    prompt: "By the time the subsidy ended in 2020, adoption rates ___ 65%.",
                    options: ["reached", "had reached", "have reached"],
                    correctIndex: 1,
                    explanation: "Past Perfect ('had reached') shows completion prior to another past point (2020).",
                    arabicExplanation: "الماضي التام يوضح أن الحدث اكتمل قبل نقطة زمنية أخرى في الماضي."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-09-modal-verbs",
            order: 9,
            title: "Modal Verbs & Academic Hedging",
            cefrRange: "B1–C1",
            summary: "Use modals ('may', 'might', 'could', 'should', 'must') to express cautious academic claims and obligation.",
            detailedRules: [
                "Academic writing avoids absolute over-generalizations by hedging with 'may', 'might', 'could', or 'can'.",
                "Past deduction uses 'modal + have + past participle' ('might have contributed')."
            ],
            examples: [
                "Dietary supplementation may mitigate enteric methane production in ruminants."
            ],
            commonIELTSTraps: [
                "Adding 'to' after a core modal ('must to reduce' -> 'must reduce')."
            ],
            arabicExplanation: "الأفعال الناقصة مثل may و might ضرورية للتحفظ الأكاديمي (Hedging) لتجنب التعميم المفرط، ويأتي بعدها الفعل في المصدر دون to.",
            exercises: [
                GrammarExercise(
                    id: "g9-e1",
                    prompt: "Policymakers ___ incentivize regenerative grazing to protect soil carbon.",
                    options: ["should to", "should", "must to"],
                    correctIndex: 1,
                    explanation: "Core modal verbs are followed directly by the bare infinitive.",
                    arabicExplanation: "الفعل الناقص should يتبعه الفعل في المصدر مباشرة بدون to."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-10-passive-voice",
            order: 10,
            title: "Passive Voice for Process Diagrams & Science",
            cefrRange: "B1–C1",
            prerequisites: ["gram-07-simple-tenses"],
            summary: "Construct accurate passive forms for Task 1 process diagrams and formal scientific methodology.",
            detailedRules: [
                "Form: appropriate tense of 'be' + past participle ('is heated', 'are filtered', 'was analysed').",
                "Use passive when the process or outcome is more important than the human agent."
            ],
            examples: [
                "Once harvested, the grain is cleaned, dried to 14% moisture, and stored in ventilated silos."
            ],
            commonIELTSTraps: [
                "Using passive with intransitive verbs like 'occur', 'happen', 'rise', or 'fall' ('was happened' is always wrong)."
            ],
            arabicExplanation: "المبني للمجهول أساسي جداً في وصف العمليات (Task 1 Process) والكتابة العلمية، لكنه لا يُستخدم أبداً مع الأفعال اللازمة مثل happen أو occur أو rise.",
            exercises: [
                GrammarExercise(
                    id: "g10-e1",
                    prompt: "After fermentation, the biogas ___ purified to remove hydrogen sulphide.",
                    options: ["is", "was been", "has"],
                    correctIndex: 0,
                    explanation: "Present Simple passive ('is purified') describes a standard recurring process.",
                    arabicExplanation: "نستخدم المضارع البسيط المبني للمجهول (is + التصريف الثالث) لوصف مراحل عملية متكررة."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-11-conditionals",
            order: 11,
            title: "Conditionals (Zero, 1st, 2nd, 3rd, Mixed & Inverted)",
            cefrRange: "B1–C2",
            prerequisites: ["gram-08-perfect-continuous", "gram-09-modal-verbs"],
            summary: "Express real policies, hypothetical scenarios, and past counterfactuals with Band 7.5+ grammatical range.",
            detailedRules: [
                "First conditional (real future): If + Present Simple, will/may + base verb.",
                "Second conditional (hypothetical present/future): If + Past Simple, would/could + base verb.",
                "Third conditional (hypothetical past): If + Past Perfect, would have + past participle.",
                "Formal inversion (Band 8+): 'Were governments to subsidize..., emissions would fall.'"
            ],
            examples: [
                "If the trial had included a larger herd, the statistical power would have been stronger."
            ],
            commonIELTSTraps: [
                "Putting 'would' inside the 'if'-clause ('If governments would invest...')."
            ],
            arabicExplanation: "لا تضع will أو would داخل جملة if. استخدم الشرط الثاني للفرضيات الحاضرة، والشرط الثالث للندم أو الفرضيات الماضية.",
            exercises: [
                GrammarExercise(
                    id: "g11-e1",
                    prompt: "If universities ___ more funding to applied research, rural innovation would accelerate.",
                    options: ["allocated", "would allocate", "allocate"],
                    correctIndex: 0,
                    explanation: "The second conditional uses Past Simple in the if-clause paired with 'would + base verb'.",
                    arabicExplanation: "في الشرط الثاني نستخدم الماضي البسيط في جملة الشرط مع would في جواب الشرط."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-12-relative-clauses",
            order: 12,
            title: "Defining & Non-Defining Relative Clauses",
            cefrRange: "B1–C1",
            summary: "Embed precise information using 'which', 'that', 'who', 'whose', 'where', and reduced relative clauses.",
            detailedRules: [
                "Defining clauses carry essential meaning and use no commas ('The crops that tolerate drought...').",
                "Non-defining clauses add extra info, require commas, and NEVER use 'that' ('Ireland, which has a temperate climate, supports...').",
                "Sentential 'which' with a comma can comment on an entire previous clause."
            ],
            examples: [
                "Nitrogen runoff declined by 22%, which significantly improved river biodiversity."
            ],
            commonIELTSTraps: [
                "Using 'that' after a comma in a non-defining clause, or repeating an object pronoun ('the study which I read it')."
            ],
            arabicExplanation: "لا تستخدم that بعد الفاصلة في جمل الوصل غير المحددة؛ استخدم which للأشياء و who للأشخاص، ولا تكرر الضمير المفعول به داخل الجملة.",
            exercises: [
                GrammarExercise(
                    id: "g12-e1",
                    prompt: "Soil organic matter, ___ retains moisture during dry spells, declined in intensively tilled fields.",
                    options: ["that", "which", "what"],
                    correctIndex: 1,
                    explanation: "Non-defining relative clauses enclosed in commas require 'which', never 'that'.",
                    arabicExplanation: "الجملة المعترضة بين فاصلتين تستخدم which ولا يجوز استخدام that فيها."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-13-reported-speech",
            order: 13,
            title: "Reported Speech & Academic Reporting Verbs",
            cefrRange: "B2–C1",
            summary: "Synthesize arguments and research findings using accurate reporting verbs and backshifting.",
            detailedRules: [
                "Use precise reporting verbs: 'argue that', 'demonstrate that', 'contend that', 'suggest that', 'warn against'.",
                "Keep present tense when reporting still-valid scientific findings ('The authors demonstrate that...')."
            ],
            examples: [
                "Critics contend that rapid urbanization strains municipal water infrastructure."
            ],
            commonIELTSTraps: [
                "Overusing 'say' and 'tell' in Task 2 essays or using 'suggest' with 'to + infinitive' ('suggested to invest' -> 'suggested investing')."
            ],
            arabicExplanation: "في الكتابة الأكاديمية استبدل say بأفعال دقيقة مثل argue و demonstrate و contend، وتذكر أن suggest يتبعها فعل ينتهي بـ ing أو that.",
            exercises: [
                GrammarExercise(
                    id: "g13-e1",
                    prompt: "The committee recommended ___ water tariffs for high-volume industrial users.",
                    options: ["to raise", "raising", "raise"],
                    correctIndex: 1,
                    explanation: "'Recommend' takes a gerund ('raising') or a 'that'-clause.",
                    arabicExplanation: "الفعل recommend يتبعه مصدر ينتهي بـ ing أو جملة تبدأ بـ that."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-14-gerunds-infinitives",
            order: 14,
            title: "Gerunds & Infinitives",
            cefrRange: "B1–C1",
            summary: "Control verb patterns, prepositions + gerund, and infinitives of purpose in academic prose.",
            detailedRules: [
                "Always use a gerund (-ing) after prepositions ('by improving', 'in reducing', 'without compromising').",
                "Use 'to + infinitive' to express purpose ('to identify trends', not 'for identify trends').",
                "Gerunds function smoothly as academic sentence subjects ('Investing in public transit reduces congestion')."
            ],
            examples: [
                "Researchers sequenced the samples to identify probiotic strains capable of improving gut health."
            ],
            commonIELTSTraps: [
                "Writing 'for + base verb' instead of 'to + base verb' for purpose."
            ],
            arabicExplanation: "بعد أي حرف جر يأتي الفعل مضافاً له ing (مثل by reducing). أما للتعبير عن الغرض فنستخدم to + المصدر (to identify) وليس for + المصدر.",
            exercises: [
                GrammarExercise(
                    id: "g14-e1",
                    prompt: "The laboratory modified the assay ___ detect trace contaminants earlier.",
                    options: ["for", "to", "in order"],
                    correctIndex: 1,
                    explanation: "Use 'to + infinitive' (or 'in order to') to express purpose.",
                    arabicExplanation: "نستخدم to قبل الفعل للتعبير عن الغرض."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-15-complex-sentences",
            order: 15,
            title: "Complex Sentences & Subordination",
            cefrRange: "B2–C1",
            prerequisites: ["gram-01-sentence-structure"],
            summary: "Combine contrasting, causal, and concessive ideas using subordinating conjunctions.",
            detailedRules: [
                "Concession: 'Although / Even though / Whereas + clause' vs 'Despite / In spite of + noun phrase/gerund'.",
                "Cause and effect: 'Because / Since / As + clause' vs 'Due to / Owing to + noun phrase'."
            ],
            examples: [
                "Whereas urban rail patronage rose steadily, rural bus usage contracted over the same decade."
            ],
            commonIELTSTraps: [
                "Using both 'Although' and 'but' in the same sentence ('Although it is costly, but it works')."
            ],
            arabicExplanation: "في العربية نقول (رغم أن ... لكن ...)، أما في الإنجليزية فلا يجوز الجمع بين Although و but في جملة واحدة؛ اختر واحدة منهما فقط.",
            exercises: [
                GrammarExercise(
                    id: "g15-e1",
                    prompt: "___ high initial installation costs, geothermal heating lowers long-term energy bills.",
                    options: ["Although", "Despite", "However"],
                    correctIndex: 1,
                    explanation: "'Despite' is followed by a noun phrase ('high initial installation costs').",
                    arabicExplanation: "لأن ما بعدها عبارة اسمية وليست جملة كاملة، نستخدم Despite."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-16-compound-sentences",
            order: 16,
            title: "Compound Sentences & Parallelism",
            cefrRange: "B1–C1",
            summary: "Build balanced multi-clause arguments with parallel grammatical structure.",
            detailedRules: [
                "Use FANBOYS (for, and, nor, but, or, yet, so) with a comma before the conjunction when joining two full independent clauses.",
                "Maintain parallel forms in lists and paired comparisons ('not only improves yield but also conserves water')."
            ],
            examples: [
                "Rotational grazing not only restores soil biodiversity but also stabilizes farm income."
            ],
            commonIELTSTraps: [
                "Breaking parallelism in thesis statements ('to reduce waste, saving money, and energy efficiency')."
            ],
            arabicExplanation: "التوازي النحوي (Parallelism) يعني توحيد الصيغة النحوية للعناصر المترابطة داخل الجملة، وهو علامة واضحة على الكتابة الأكاديمية المتقدمة.",
            exercises: [
                GrammarExercise(
                    id: "g16-e1",
                    prompt: "The program aims to modernize irrigation, lower fertilizer runoff, and ___.",
                    options: ["training local agronomists", "train local agronomists", "trained local agronomists"],
                    correctIndex: 1,
                    explanation: "All three items must share the parallel bare infinitive form ('modernize', 'lower', 'train').",
                    arabicExplanation: "يجب أن تتطابق الصيغة الفعلية للعناصر الثلاثة (مصدر مجرد: train)."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-17-conjunctions-cohesion",
            order: 17,
            title: "Academic Conjunctions & Cohesive Devices",
            cefrRange: "B2–C2",
            summary: "Transition seamlessly between arguments without mechanical overuse of memorized linkers.",
            detailedRules: [
                "Distinguish subordinating conjunctions ('whereas'), coordinating conjunctions ('yet'), and conjunctive adverbs ('nevertheless', 'consequently').",
                "Vary linker position (mid-sentence 'however' enclosed in commas) for natural Band 8 cohesion."
            ],
            examples: [
                "Automation eliminates certain routine roles; it creates, however, demand for technical maintenance specialists."
            ],
            commonIELTSTraps: [
                "Starting every sentence with 'Furthermore', 'Moreover', or 'On the other hand' mechanically."
            ],
            arabicExplanation: "تجنب الإفراط الآلي في أدوات الربط في بداية كل جملة؛ التنويع ووضع however في منتصف الجملة بين فاصلتين يمنح النص سلاسة أكاديمية أعلى.",
            exercises: [
                GrammarExercise(
                    id: "g17-e1",
                    prompt: "The pilot scheme reduced plastic waste; ___, rural participation remained modest.",
                    options: ["nevertheless", "despite", "although"],
                    correctIndex: 0,
                    explanation: "After a semicolon and before a comma, a conjunctive adverb ('nevertheless') is grammatically required.",
                    arabicExplanation: "بعد الفاصلة المنقوطة وقبل الفاصلة نحتاج إلى ظرف ربط مثل nevertheless."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-18-punctuation",
            order: 18,
            title: "Academic Punctuation",
            cefrRange: "B2–C1",
            summary: "Use commas, semicolons, colons, and apostrophes accurately to clarify dense academic sentences.",
            detailedRules: [
                "Use a comma after introductory subordinate clauses and adverbials.",
                "Use a colon to introduce a formal explanation, list, or synthesis after an independent clause.",
                "Distinguish 'its' (possessive) from 'it's' (contraction—avoid contractions in formal IELTS Academic Writing)."
            ],
            examples: [
                "Two factors govern silage quality: harvest moisture content and rapid anaerobic sealing."
            ],
            commonIELTSTraps: [
                "Using contractions ('don't', 'can't') in Academic Writing Task 2."
            ],
            arabicExplanation: "تجنّب الاختصارات مثل don't و it's في الكتابة الأكاديمية، واستخدم النقطتين (:) لتقديم قائمة أو تفسير بعد جملة كاملة.",
            exercises: [
                GrammarExercise(
                    id: "g18-e1",
                    prompt: "Which sentence uses punctuation accurately in formal academic style?",
                    options: [
                        "The vaccine proved effective; its cold-chain storage remained expensive.",
                        "The vaccine proved effective, it's cold-chain storage remained expensive.",
                        "The vaccine proved effective: because its storage was expensive."
                    ],
                    correctIndex: 0,
                    explanation: "Uses a semicolon between independent clauses and possessive 'its' without an apostrophe.",
                    arabicExplanation: "الفاصلة المنقوطة تربط الجملتين بشكل صحيح و its للملكية لا تأخذ فاصلة عليا."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-19-academic-construction",
            order: 19,
            title: "Academic Nominalization & Concision",
            cefrRange: "C1–C2",
            prerequisites: ["gram-02-parts-of-speech", "gram-15-complex-sentences"],
            summary: "Elevate informal spoken phrasing into concise, objective academic noun phrases.",
            detailedRules: [
                "Nominalization packs verb/clause ideas into precise noun phrases ('Because people use more cars' -> 'Rising private vehicle reliance').",
                "Maintain objective tone by avoiding personal fillers ('I think that in my personal opinion...')."
            ],
            examples: [
                "Informal: When farmers add too much nitrogen, rivers get polluted.",
                "Academic: Excessive nitrogen application accelerates freshwater eutrophication."
            ],
            commonIELTSTraps: [
                "Over-nominalizing to the point of obscurity; balance crisp noun phrases with active verbs."
            ],
            arabicExplanation: "الاسمية الأكاديمية (Nominalization) تحول الجمل الشفهية الطويلة إلى عبارات اسمية مركّزة وموضوعية ترفع تقييم المفردات والتراكيب.",
            exercises: [
                GrammarExercise(
                    id: "g19-e1",
                    prompt: "Which revision is the most concise academic nominalization of 'Because cities grew fast, housing became expensive'?",
                    options: [
                        "Rapid urban expansion drove up housing costs.",
                        "Because of cities growing very fast, houses are now costly.",
                        "Cities grew fast and so people paid more money."
                    ],
                    correctIndex: 0,
                    explanation: "'Rapid urban expansion' concisely nominalizes the cause while keeping a strong active verb ('drove up').",
                    arabicExplanation: "عبارة Rapid urban expansion تلخّص السبب بدقة أكاديمية عالية مع فعل نشط واضح."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-20-advanced-structures",
            order: 20,
            title: "Advanced Structures: Participle Clauses, Inversion & Clefts",
            cefrRange: "C1–C2",
            prerequisites: ["gram-11-conditionals", "gram-12-relative-clauses"],
            summary: "Deploy participle clauses, negative inversion, and cleft sentences naturally for Band 8.0–9.0 Grammatical Range.",
            detailedRules: [
                "Participle clauses must share the same subject as the main clause ('Having analysed the samples, the team published...').",
                "Negative adverbial inversion ('Not only did exports rise, but domestic quality also improved').",
                "It-clefts emphasize a key causal factor ('It is policy consistency, rather than short-term subsidies, that drives adoption')."
            ],
            examples: [
                "Not only does precision nutrition improve feed conversion efficiency, but it also lowers nitrogen excretion."
            ],
            commonIELTSTraps: [
                "Dangling participles where the subject of the participle differs from the main clause subject."
            ],
            arabicExplanation: "في الجمل التي تبدأ بـ Not only نستخدم قلب الفاعل والفعل المساعد (Not only does...)، وفي جمل اسم الفاعل يجب أن يكون الفاعل موحداً بين شطري الجملة.",
            exercises: [
                GrammarExercise(
                    id: "g20-e1",
                    prompt: "Not only ___ carbon sequestration, but cover crops also prevent winter soil erosion.",
                    options: ["they enhance", "do they enhance", "enhance they"],
                    correctIndex: 1,
                    explanation: "Negative/restrictive adverbials at the start of a sentence trigger auxiliary-subject inversion ('do they enhance').",
                    arabicExplanation: "وجود Not only في بداية الجملة يتطلب قلب الفعل المساعد قبل الفاعل (do they enhance)."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-21-cleft-emphasis",
            order: 21,
            title: "Cleft Sentences & Rhetorical Emphasis (Band 8–9)",
            cefrRange: "C1–C2",
            prerequisites: ["gram-12-relative-clauses"],
            summary: "Focus reader attention on the decisive cause or argument using It-clefts and Wh-clefts.",
            detailedRules: [
                "It-cleft: 'It is + emphasized element + that/who + rest of clause' ('It is policy consistency, rather than short-term grants, that drives adoption').",
                "Wh-cleft (pseudo-cleft): 'What + clause + is + focused idea' ('What distinguishes Band 9 writing is effortless lexical precision')."
            ],
            examples: [
                "It is the lack of cold-chain storage, rather than low farm productivity, that causes most post-harvest losses."
            ],
            commonIELTSTraps: [
                "Overusing clefts in every paragraph; deploy 1–2 strategically in thesis statements or key rebuttals."
            ],
            arabicExplanation: "الجمل المشطورة (It is ... that / What ... is) أداة أكاديمية راقية لإبراز السبب الحقيقي أو النقطة المحورية في مقالات المستوى 8 و9.",
            exercises: [
                GrammarExercise(
                    id: "g21-e1",
                    prompt: "___ distinguishes effective regulation from rigid bureaucracy is its ability to adapt to new evidence.",
                    options: ["That", "What", "Which"],
                    correctIndex: 1,
                    explanation: "A Wh-cleft opens with 'What' (= 'The thing that') as the subject of 'is'.",
                    arabicExplanation: "في الجملة المشطورة بـ What نبدأ بـ What بمعنى (الشيء الذي)."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-22-subjunctive-mandatives",
            order: 22,
            title: "Formal Subjunctive & Academic Recommendations",
            cefrRange: "C1–C2",
            summary: "Express formal policy recommendations cleanly using mandative subjunctive structures.",
            detailedRules: [
                "After verbs/adjectives of recommendation or urgency ('recommend', 'insist', 'propose', 'it is essential/imperative that'), use the bare infinitive ('that every farm adopt', 'that funding be allocated').",
                "In British academic English, 'should + base verb' is an equally accepted alternative ('that funding should be allocated')."
            ],
            examples: [
                "The panel recommended that municipal authorities publish real-time water quality audits."
            ],
            commonIELTSTraps: [
                "Confusing mandative 'suggest that X be' with incorrect 'suggest to be'."
            ],
            arabicExplanation: "بعد أفعال التوصية مثل recommend و insist و imperative that يُستخدم الفعل في المصدر المجرد (مثل be أو adopt) أو should + المصدر في الإنجليزية الأكاديمية الرسمية.",
            exercises: [
                GrammarExercise(
                    id: "g22-e1",
                    prompt: "It is imperative that public transit funding ___ ring-fenced for at least a decade.",
                    options: ["is being", "be", "was"],
                    correctIndex: 1,
                    explanation: "The formal mandative subjunctive uses bare 'be' after 'It is imperative that...'.",
                    arabicExplanation: "بعد عبارة It is imperative that نستخدم صيغة المصدر المجرد be في الأسلوب الأكاديمي الرسمي."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-23-ellipsis-substitution",
            order: 23,
            title: "Ellipsis, Substitution & Band 9 Cohesion",
            cefrRange: "C1–C2",
            prerequisites: ["gram-04-pronouns"],
            summary: "Eliminate clumsy repetition using 'that of', 'those of', 'do so', and 'such' for seamless Band 9 cohesion.",
            detailedRules: [
                "Use 'that of' (singular) and 'those of' (plural) in Task 1 comparisons ('Ireland's wind share exceeded that of Belgium').",
                "Use 'do so' to substitute for a previously stated verb phrase ('Cities must upgrade pipes; failing to do so wastes treated water')."
            ],
            examples: [
                "Nitrogen runoff in clover-integrated pastures was half that of conventionally fertilized plots."
            ],
            commonIELTSTraps: [
                "Comparing an attribute directly to a country ('Ireland's emissions were lower than Germany' → 'lower than those of Germany')."
            ],
            arabicExplanation: "استخدام that of للمفرد و those of للجمع و do so يمنع تكرار الأسماء والأفعال في المقارنات ويرفع درجة الترابط النصي إلى المستوى 8.5–9.",
            exercises: [
                GrammarExercise(
                    id: "g23-e1",
                    prompt: "The literacy rates in northern provinces surpassed ___ in coastal districts by 12 percentage points.",
                    options: ["that", "those", "them"],
                    correctIndex: 1,
                    explanation: "'Rates' is plural, so 'those' is required to avoid repeating 'the literacy rates'.",
                    arabicExplanation: "بما أن كلمة rates جمع، نستخدم those للإشارة إليها دون تكرارها."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-24-participial-phrases",
            order: 24,
            title: "Reduced Relative & Participial Clauses",
            cefrRange: "C1–C2",
            prerequisites: ["gram-10-passive-voice", "gram-12-relative-clauses"],
            summary: "Condense wordy clauses into crisp active (-ing) and passive (-ed) participial modifiers.",
            detailedRules: [
                "Active reduction: 'Farmers who adopt rotational grazing' → 'Farmers adopting rotational grazing'.",
                "Passive reduction: 'Samples which were collected in autumn' → 'Samples collected in autumn'.",
                "Perfect participle for earlier cause: 'Having secured funding, the institute launched a five-year trial.'"
            ],
            examples: [
                "Backed by longitudinal field data, the proposal gained cross-party support."
            ],
            commonIELTSTraps: [
                "Dangling modifier: 'Walking through the lab, the microscope broke' (the microscope was not walking!)."
            ],
            arabicExplanation: "اختصار جمل الوصل باسم الفاعل (-ing) للمبني للمعلوم واسم المفعول (-ed) للمبني للمجهول يجعل الجمل الأكاديمية مكثفة وسلسة جداً.",
            exercises: [
                GrammarExercise(
                    id: "g24-e1",
                    prompt: "___ across forty commercial farms, the dataset confirmed a 22% drop in enteric methane.",
                    options: ["Collecting", "Collected", "Having collect"],
                    correctIndex: 1,
                    explanation: "The dataset was collected (passive meaning), so the past participle 'Collected' is required.",
                    arabicExplanation: "البيانات تم جمعها (مبني للمجهول)، لذا نستخدم اسم المفعول Collected."
                )
            ]
        ),
        GrammarLesson(
            id: "gram-25-academic-hedging-stance",
            order: 25,
            title: "Hedging, Qualification & Nuanced Band 9 Stance",
            cefrRange: "C1–C2",
            prerequisites: ["gram-09-modal-verbs"],
            summary: "Express precise degrees of certainty and avoid sweeping generalizations in Task 2 and Speaking Part 3.",
            detailedRules: [
                "Replace absolute claims ('Technology always destroys jobs') with qualified claims ('Automation tends to displace routine tasks while creating specialized roles').",
                "Combine one hedging verb/adverb with concrete evidence ('Evidence strongly suggests that...', 'is likely to', 'may partly explain')."
            ],
            examples: [
                "While remote work appears to boost regional spending, its long-term impact on urban office districts remains contested."
            ],
            commonIELTSTraps: [
                "Hedging so heavily that your position disappears in an Opinion essay; keep your stance clear while qualifying the scope."
            ],
            arabicExplanation: "التحفظ الأكاديمي الذكي (Hedging) يمنع التعميم المطلق غير العلمي، مع الحفاظ على وضوح موقفك الأساسي في المقال.",
            exercises: [
                GrammarExercise(
                    id: "g25-e1",
                    prompt: "Which sentence demonstrates accurate Band 9 academic hedging?",
                    options: [
                        "Social media definitely ruins every teenager's concentration forever.",
                        "Frequent smartphone notifications appear to fragment sustained attention among adolescents.",
                        "Maybe perhaps notifications might possibly somewhat affect focus."
                    ],
                    correctIndex: 1,
                    explanation: "Uses one clean hedging verb ('appear to') paired with precise academic vocabulary.",
                    arabicExplanation: "الجملة الثانية تستخدم أداة تحفظ واحدة دقيقة (appear to) بدون تعميم مفرط وبدون تكديس كلمات تردد."
                )
            ]
        )
    ]
}
