import Foundation

/// A focused lesson on one IELTS task skill: what it tests, a method, a worked example and the traps.
/// Written for this app (original teaching content), grounded in the public IELTS task descriptions.
public struct StrategyLesson: Identifiable, Hashable, Sendable, Codable {
    public let id: String
    public let skillTags: [String]
    public let module: String
    public let title: String
    public let arabicTitle: String
    public let whatItTests: String
    public let steps: [String]
    public let workedExample: String
    public let traps: [String]
    public let arabicSummary: String
}

public enum StrategyLessons {

    public static func lesson(for skillTag: String) -> StrategyLesson? {
        all.first { $0.skillTags.contains(skillTag) }
    }

    public static let all: [StrategyLesson] = [
        StrategyLesson(
            id: "lesson-tfng", skillTags: ["tfng"], module: "Reading",
            title: "True / False / Not Given", arabicTitle: "صحيح / خطأ / غير مذكور",
            whatItTests: "Whether you can compare a statement with the passage precisely: does the text say the same thing (TRUE), the opposite (FALSE), or nothing about it (NOT GIVEN)?",
            steps: [
                "Underline the key words in the statement, especially names, numbers and limiting words (all, only, first, always, most).",
                "Scan for the names or numbers to find the right place. Questions follow the order of the passage.",
                "Read that sentence and the one before and after it carefully.",
                "Ask: does the passage say this? → TRUE. Does it say the opposite? → FALSE. Is the information simply not there? → NOT GIVEN.",
                "Judge only by the passage, never by what you know about the topic."
            ],
            workedExample: "Passage: \"Most hedges date from the enclosure movement.\" Statement: \"All hedges were planted during the enclosure movement.\" → FALSE: 'most' contradicts 'all'. Statement: \"Enclosure hedges were mainly hawthorn.\" If the passage only says hawthorn was planted, without 'mainly', check carefully; if it gives no proportion, the answer is NOT GIVEN.",
            traps: [
                "Choosing FALSE when the text is simply silent. FALSE needs a contradiction; silence is NOT GIVEN.",
                "Ignoring one limiting word (some / all, usually / always) that changes the answer.",
                "Matching words instead of meaning: the same word can appear in the passage with a different claim."
            ],
            arabicSummary: "صحيح: النص يقول المعنى نفسه. خطأ: النص يقول العكس صراحة. غير مذكور: النص لا يتحدث عن هذه المعلومة إطلاقاً. أكبر خطأ شائع هو اختيار «خطأ» عندما يكون النص صامتاً. انتبه للكلمات المقيِّدة مثل all وsome وonly وalways، واعتمد على النص فقط لا على معلوماتك العامة."
        ),
        StrategyLesson(
            id: "lesson-ynng", skillTags: ["ynng"], module: "Reading",
            title: "Yes / No / Not Given", arabicTitle: "نعم / لا / غير مذكور",
            whatItTests: "Whether you can identify the writer's opinions and claims, not just facts. YES = the writer agrees; NO = the writer disagrees; NOT GIVEN = the writer gives no view.",
            steps: [
                "Look for opinion language: in my view, I would argue, undoubtedly, should, it seems, this is a mistake.",
                "Separate the writer's voice from views the writer reports (\"some researchers argue…\"). Reported views are not the writer's own.",
                "Decide whether the writer's own position matches the statement, opposes it, or is absent."
            ],
            workedExample: "Passage: \"Behaviourists preferred to describe what animals did.\" Statement: \"Behaviourists were right to avoid discussing feelings.\" → NOT GIVEN: the writer describes their approach but never judges it.",
            traps: [
                "Treating a description as agreement. Describing a view is not supporting it.",
                "Taking a reported opinion (\"critics claim…\") as the writer's opinion."
            ],
            arabicSummary: "هذا النوع يختبر رأي الكاتب نفسه لا الحقائق. ابحث عن عبارات الرأي مثل in my view وshould وundoubtedly. احذر: عندما ينقل الكاتب رأي غيره («يرى بعض الباحثين») فهذا ليس رأيه. ووصف الكاتب لموقف ما لا يعني أنه يوافق عليه."
        ),
        StrategyLesson(
            id: "lesson-headings", skillTags: ["matching_headings", "main_idea"], module: "Reading",
            title: "Matching headings and main ideas", arabicTitle: "مطابقة العناوين والفكرة الرئيسية",
            whatItTests: "Whether you can find the main idea of a whole paragraph, not a detail inside it.",
            steps: [
                "Read the headings first and note how each one differs from the others.",
                "For each paragraph, read the first two sentences and the last sentence, then skim the middle.",
                "Say the paragraph's point in five words of your own, then find the heading that matches that point.",
                "Do the easiest paragraphs first; fewer headings remain for the hard ones."
            ],
            workedExample: "A paragraph describes shopkeepers fearing lost customers, then studies showing cyclists spend as much over a month. Main idea: the fears were mistaken. Heading: \"Objections from businesses that proved largely unfounded\", not \"Why the benefits of cycling are hard to measure\", which only matches a detail.",
            traps: [
                "Choosing a heading because it repeats a word from the paragraph.",
                "Matching a heading to one example rather than to the paragraph as a whole."
            ],
            arabicSummary: "العنوان الصحيح يلخّص الفقرة كلها لا تفصيلة فيها. اقرأ أول جملتين وآخر جملة، ولخّص الفكرة بكلماتك في خمس كلمات، ثم اختر العنوان المطابق. لا تنخدع بالعنوان الذي يكرر كلمة من الفقرة."
        ),
        StrategyLesson(
            id: "lesson-scanning", skillTags: ["scanning", "matching_information"], module: "Reading",
            title: "Scanning and locating information", arabicTitle: "البحث السريع وتحديد مكان المعلومة",
            whatItTests: "Whether you can find where a specific piece of information is, quickly, even when it is paraphrased.",
            steps: [
                "Turn each item into what you are looking for: an example? a reason? a description? a reference to a date?",
                "Predict the words the passage might use instead (paraphrase): 'alterations to a ship' → 'cut openings in the hold'.",
                "Move your eyes quickly down the text looking for those ideas, not for exact words.",
                "Remember: in 'which paragraph contains…' tasks the order is random, and a paragraph can be used more than once."
            ],
            workedExample: "Item: \"an example of meat being used for something other than food\". Scan for a non-food use and find: \"boiled down to produce tallow, a fat used for candles and soap\".",
            traps: [
                "Reading every word slowly. Scanning means searching, not reading.",
                "Looking only for the exact words of the question."
            ],
            arabicSummary: "حوّل السؤال إلى نوع المعلومة المطلوبة (مثال، سبب، وصف)، وتوقّع الكلمات البديلة التي قد يستخدمها النص، ثم مرّر عينيك بسرعة بحثاً عن الفكرة لا عن الكلمة نفسها. في هذا النوع لا تأتي الأسئلة بترتيب النص."
        ),
        StrategyLesson(
            id: "lesson-features", skillTags: ["matching_features"], module: "Reading",
            title: "Matching features (people and groups)", arabicTitle: "مطابقة الخصائص بالأشخاص والجهات",
            whatItTests: "Whether you can connect claims or actions to the right person, group or date.",
            steps: [
                "Circle every name or group in the passage first; they are easy to scan for.",
                "Read what each person said or did, and summarise it in a few words.",
                "Match the statements to your summaries by meaning. Some options may be unused or used twice."
            ],
            workedExample: "Statement: \"recommended that money be moved into more basic research\". The ALPAC committee 'recommended that funding be reduced and redirected towards basic research' → ALPAC.",
            traps: [
                "Picking the person whose name is closest to the matching words, rather than the person who actually made the claim.",
                "Confusing who reported an idea with who held it."
            ],
            arabicSummary: "ضع دائرة حول كل اسم في النص، ولخّص ما قاله أو فعله كل شخص، ثم طابق العبارات بالمعنى. قد لا تُستخدم بعض الخيارات، وقد يُستخدم خيار أكثر من مرة."
        ),
        StrategyLesson(
            id: "lesson-endings", skillTags: ["sentence_endings"], module: "Reading",
            title: "Matching sentence endings", arabicTitle: "مطابقة نهايات الجمل",
            whatItTests: "Whether you understand cause, effect and logic in the passage, and can complete a sentence so it is both grammatical and true.",
            steps: [
                "Read the sentence beginning and predict the kind of ending: a reason? a result? a condition?",
                "Remove endings that don't fit grammatically.",
                "Find the beginning's idea in the passage (questions follow passage order) and choose the ending the text supports."
            ],
            workedExample: "\"Customers tend to prefer a single serpentine queue…\" The passage gives fairness as their reason → \"because it is seen as fairer\", not \"because it reduces total waiting time\", which the passage never says.",
            traps: [
                "Choosing an ending that is true in general but not stated in the passage.",
                "Joining two ideas that both appear in the passage but are not linked there."
            ],
            arabicSummary: "توقّع نوع النهاية المطلوبة (سبب، نتيجة، شرط)، واستبعد النهايات التي لا تتناسب نحوياً، ثم اختر النهاية التي يدعمها النص تحديداً. لا تختر نهاية صحيحة عموماً لكنها غير مذكورة في النص."
        ),
        StrategyLesson(
            id: "lesson-completion", skillTags: ["sentence_completion", "summary_completion", "note_completion", "flowchart", "short_answer"], module: "Reading & Listening",
            title: "Completion tasks and short answers", arabicTitle: "مهام الإكمال والإجابات القصيرة",
            whatItTests: "Whether you can find an exact word or number and write it correctly within the word limit.",
            steps: [
                "Read the instruction: ONE WORD ONLY, NO MORE THAN TWO WORDS, AND/OR A NUMBER. Breaking the limit makes the answer wrong.",
                "Predict the type of word for each gap: noun, verb, adjective, number, plural?",
                "Find the place in the text (completion questions usually follow the text order) and copy the word exactly.",
                "Check spelling and grammar: the completed sentence must read correctly.",
                "When a word list is given, the answer usually paraphrases the text, so match meaning."
            ],
            workedExample: "\"Soil under a hedge can store more ______ than soil in an arable field.\" Gap needs a noun; text: \"can store considerably more carbon\" → carbon. Writing 'considerably more carbon' breaks a one- or two-word limit.",
            traps: [
                "Writing more words than allowed.",
                "Spelling mistakes: a misspelled answer is marked wrong.",
                "Changing the word form (store / storage) so the sentence no longer works."
            ],
            arabicSummary: "اقرأ حدّ الكلمات المسموح أولاً، فتجاوزه يجعل الإجابة خاطئة. توقّع نوع الكلمة الناقصة (اسم، فعل، رقم، جمع)، وانسخها من النص بتهجئتها الصحيحة. تأكد أن الجملة بعد الإكمال سليمة نحوياً."
        ),
        StrategyLesson(
            id: "lesson-mcq", skillTags: ["multiple_choice", "writer_purpose", "inference"], module: "Reading & Listening",
            title: "Multiple choice, inference and writer's purpose", arabicTitle: "الاختيار من متعدد والاستنتاج وهدف الكاتب",
            whatItTests: "Whether you can choose the option the text actually supports, including what it implies and why the writer included something.",
            steps: [
                "Read the question stem without the options and find the answer in the text yourself first.",
                "Then compare your answer with the options; choose the one that matches by meaning.",
                "Check every wrong option: each should be contradicted, not mentioned, or only partly true.",
                "For 'why does the writer mention X?', look at the sentence around X: is it an example, a contrast, evidence?"
            ],
            workedExample: "\"Why does the writer mention a dog and a big cat?\" The text says observers 'find it hard to avoid the impression' of boredom → to show why the idea seems natural, not to give scientific examples.",
            traps: [
                "Choosing an option with exact words from the text but a different meaning.",
                "Choosing an option that is true in the real world but not in the text.",
                "Options that are only half right: one part matches, the other does not."
            ],
            arabicSummary: "اقرأ السؤال دون الخيارات وابحث عن الإجابة في النص بنفسك، ثم قارنها بالخيارات. كل خيار خاطئ إما متناقض مع النص أو غير مذكور أو صحيح جزئياً فقط. في أسئلة «لماذا ذكر الكاتب…» انظر إلى وظيفة الجملة: مثال أم مقارنة أم دليل."
        ),
        StrategyLesson(
            id: "lesson-paraphrase", skillTags: ["paraphrasing", "comprehension"], module: "Reading & Listening",
            title: "Recognising paraphrase", arabicTitle: "التعرّف على إعادة الصياغة",
            whatItTests: "Almost every IELTS question rewords the text. You need to recognise the same idea in different words.",
            steps: [
                "Expect synonyms (decline → fall), word-form changes (decide → decision) and structure changes (active → passive).",
                "Focus on meaning: who did what, when, how much.",
                "Build your own paraphrase list in the Vocabulary section from each practice set."
            ],
            workedExample: "Question: \"one profitable voyage convinced them\". Text: \"the financial success of the voyage persuaded investors\". profitable = financial success; convinced = persuaded.",
            traps: ["Rejecting the right answer because none of its words appear in the text."],
            arabicSummary: "معظم أسئلة الآيلتس تعيد صياغة النص بكلمات أخرى: مرادفات، تغيير صيغة الكلمة، أو تغيير بناء الجملة. ركّز على المعنى (من فعل ماذا ومتى وكم)، ودوّن أزواج المرادفات التي تصادفها."
        ),
        StrategyLesson(
            id: "lesson-distractors", skillTags: ["distractor_correction", "detail"], module: "Listening",
            title: "Distractors, corrections and details", arabicTitle: "المشتتات والتصحيحات والتفاصيل",
            whatItTests: "Speakers often say a wrong answer first and then correct it. You must write the final, confirmed information.",
            steps: [
                "Read the questions before the audio and predict the answer type.",
                "Listen for correction signals: actually, sorry, no wait, I mean, it used to be, but now, that's changed.",
                "Write the first option lightly in your head, then replace it if a correction follows.",
                "Watch for things that are 'provided' or 'not needed': they are distractors for 'bring' questions."
            ],
            workedExample: "\"It's forty-two Cotton Street — oh, sorry, no. I moved last month. It's seventeen Kestrel Road.\" → Kestrel. \"The rent was forty until April, but now it's forty-eight.\" → 48.",
            traps: [
                "Writing the first number or name you hear.",
                "Writing something that is provided for you when the question asks what to bring."
            ],
            arabicSummary: "في الاستماع كثيراً ما يذكر المتحدث معلومة خاطئة ثم يصححها. انتبه لكلمات التصحيح مثل actually وsorry وI mean وit used to be. اكتب المعلومة النهائية المؤكدة لا أول ما تسمعه."
        ),
        StrategyLesson(
            id: "lesson-spelling-numbers", skillTags: ["spelling", "numbers", "dates"], module: "Listening",
            title: "Spelling, numbers and dates", arabicTitle: "التهجئة والأرقام والتواريخ",
            whatItTests: "Accurate copying of names, numbers, prices and dates. A tiny error makes the answer wrong.",
            steps: [
                "Practise the alphabet aloud, especially A/E/I, G/J, B/V/P and double letters ('double R').",
                "Learn number pairs that sound alike: thirteen / thirty, fifteen / fifty (stress: thirTEEN vs THIRty).",
                "Dates: accept 14, 14th or the 14th; but don't add words beyond the limit.",
                "Prices: write the number only when the £ or $ sign is already printed."
            ],
            workedExample: "\"F-E-double R-A-R-O\" → Ferraro. \"Fifteen pounds\" → 15 (the £ is already on the form).",
            traps: ["Missing a double letter.", "Confusing -teen and -ty numbers.", "Writing the currency word when the symbol is already given."],
            arabicSummary: "تدرّب على نطق الحروف الإنجليزية خاصة الحروف المتشابهة والحروف المضاعفة (double R). ميّز بين thirteen وthirty بمكان النبرة. اكتب الأرقام بدقة ولا تضف كلمات تتجاوز الحد المسموح."
        ),
        StrategyLesson(
            id: "lesson-listening-matching", skillTags: ["matching", "matching_opinions"], module: "Listening",
            title: "Listening matching and opinions", arabicTitle: "المطابقة والآراء في الاستماع",
            whatItTests: "Linking places, people or sources to features or opinions while speakers discuss them, often with hesitation and changes of mind.",
            steps: [
                "Before the audio, read the list of options and think of synonyms for each.",
                "Items are heard in order; options are not.",
                "In discussions, wait for agreement: one speaker's first idea may be rejected by the other.",
                "Listen for opinion signals: 'the problem is', 'that's perfect for', 'I struggled with'."
            ],
            workedExample: "\"The headline result is impressive, but they only used twelve animals.\" → 'based on too few animals', not 'good for background'.",
            traps: ["Matching the first idea mentioned, before the speakers change their minds.", "Choosing an option because a word from it is spoken."],
            arabicSummary: "اقرأ الخيارات قبل الاستماع وفكّر في مرادفاتها. الأسئلة تأتي بالترتيب أما الخيارات فلا. في النقاش انتظر الاتفاق النهائي، فقد يرفض أحد المتحدثين فكرة الآخر."
        )
    ]
}
