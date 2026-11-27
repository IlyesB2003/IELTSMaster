import Foundation

/// Specialized Academic English & Research Communication curriculum,
/// including general academic modules and optional Agricultural Sciences,
/// Animal Nutrition, Biotechnology, and Ireland-ready professional communication tracks.
public enum AcademicEnglishContent {
    public static let units: [AcademicEnglishUnit] = [
        AcademicEnglishUnit(
            id: "acad-01-abstracts",
            title: "Writing & Critiquing Research Abstracts",
            category: "Research Abstracts",
            isSpecializedAgriBio: false,
            overview: "Structure a 150–250 word IMRaD abstract (Background, Objective, Methods, Results, Conclusion) with dense academic precision.",
            keyConventions: [
                "Use Past Simple for completed methods and findings; Present Simple for established facts and conclusions.",
                "Quantify primary findings with exact units and statistical significance rather than vague adjectives.",
                "Eliminate citations and undefined abbreviations inside the abstract."
            ],
            modelExcerpt: "Background: Enteric methane accounts for a major share of ruminant greenhouse gas emissions. Objective: This 12-week randomized trial evaluated the effect of red seaweed supplementation (0.5% dry matter) on methane yield and milk solids in pasture-fed dairy cows. Methods: Forty-eight multiparous Holstein-Friesian cows were assigned to control or supplemented diets. Results: Supplemented cows exhibited a 24% reduction in daily methane output (p < 0.01) with no statistically significant decline in milk yield. Conclusion: Low-dose macroalgae supplementation represents a promising mitigation tool, warranting multi-season validation.",
            keyPhrases: [
                "This study investigated the relationship between...",
                "A statistically significant reduction was observed in...",
                "These findings suggest that... warrants further investigation."
            ],
            arabicNotes: "الملخص البحثي الأكاديمي يتبع بنية IMRaD: الخلفية، الهدف، المنهجية، النتائج الرقمية الدقيقة، ثم الاستنتاج. استخدم الماضي البسيط للمنهجية والنتائج، والمضارع البسيط للاستنتاجات العامة.",
            practiceTask: "Draft a 160-word structured abstract summarizing an experiment or policy intervention in your field, including exact numerical outcomes."
        ),
        AcademicEnglishUnit(
            id: "acad-02-scientific-articles",
            title: "Reading & Synthesizing Scientific Articles",
            category: "Scientific Articles",
            isSpecializedAgriBio: false,
            overview: "Master three-pass reading of peer-reviewed papers: skimming structure, interpreting figures/tables, and evaluating methodology.",
            keyConventions: [
                "Separate empirical results from author interpretation in the Discussion section.",
                "Identify sample size, control groups, confounding variables, and stated limitations.",
                "Paraphrase findings cleanly using reporting verbs ('demonstrate', 'indicate', 'challenge') without patchwriting."
            ],
            modelExcerpt: "While Smith et al. (2023) observed rapid soil carbon gains under no-till management, their 18-month sampling depth was restricted to the top 15 cm, limiting conclusions regarding deeper subsoil sequestration.",
            keyPhrases: [
                "In contrast to earlier findings...",
                "A key methodological limitation of this study is...",
                "Taken together, these studies corroborate..."
            ],
            arabicNotes: "القراءة النقدية للأوراق العلمية تميز بين النتائج الفعلية وتفسير الباحثين، وتنتبه دائماً لحجم العينة والقيود المنهجية.",
            practiceTask: "Write a 120-word critical synthesis comparing two opposing explanations for a scientific or environmental trend."
        ),
        AcademicEnglishUnit(
            id: "acad-03-presentations",
            title: "Academic Presentations & University Lectures",
            category: "Academic Presentations",
            isSpecializedAgriBio: false,
            overview: "Deliver clear, signposted talks and follow fast-paced university lectures in English-speaking institutions.",
            keyConventions: [
                "Signpost transitions explicitly ('Turning now to methodology...', 'To summarize the key implication...').",
                "Pause 1–2 seconds before key numerical conclusions to give listeners processing time.",
                "Handle Q&A diplomatically when a question lies outside your dataset."
            ],
            modelExcerpt: "Good morning everyone. Today I will outline how precision pasture measurement improves both feed efficiency and nitrogen stewardship. I will begin with the baseline challenge, move to our field data, and conclude with practical implications for commercial farms.",
            keyPhrases: [
                "That raises an important point; while our trial did not directly measure X, existing literature indicates...",
                "As illustrated in the second figure, the divergence becomes pronounced after week six."
            ],
            arabicNotes: "العرض الأكاديمي الناجح يعتمد على إشارات الانتقال الواضحة (Signposting) والتوقف القصير قبل النتائج المهمة، مع التعامل المهني الهادئ مع أسئلة الجمهور.",
            practiceTask: "Record a 2-minute spoken overview of a research topic in Speaking or Pronunciation Lab using at least three signposting transitions."
        ),
        AcademicEnglishUnit(
            id: "acad-04-professional-emails",
            title: "International Professional & Academic Emails (Ireland / EU)",
            category: "Professional Emails",
            isSpecializedAgriBio: false,
            overview: "Write concise, polite, direct correspondence for research supervisors, employers, and international teams in Ireland and Europe.",
            keyConventions: [
                "Use an informative subject line (e.g., 'Application Inquiry: Animal Nutrition Research Role — [Name]').",
                "Open clearly with purpose in sentence one; keep paragraphs short (2–4 lines).",
                "Close politely with a clear next step ('Kind regards,' or 'Best regards,' — standard in Ireland and the UK)."
            ],
            modelExcerpt: "Dear Dr. O'Sullivan,\n\nI am writing to express my interest in the Animal Nutritionist position advertised by your research group. With a background in agricultural sciences and applied ruminant nutrition, I am particularly drawn to your work on low-emission pasture systems.\n\nI have attached my CV for your consideration and would welcome the opportunity to discuss how my analytical and field-trial experience could support your team.\n\nKind regards,",
            keyPhrases: [
                "I am writing to inquire about...",
                "Please find attached...",
                "I would welcome the opportunity to discuss..."
            ],
            arabicNotes: "المراسلات المهنية في أيرلندا والمملكة المتحدة تتسم بالوضوح والإيجاز والأدب المهني. استخدم Kind regards في الختام، وحدد هدف الرسالة في أول جملة.",
            practiceTask: "Draft a 150-word email to a research institute in Ireland proposing a collaboration or inquiring about a postgraduate/industry position."
        ),
        AcademicEnglishUnit(
            id: "acad-05-data-interpretation",
            title: "Data Interpretation & Scientific Report Writing",
            category: "Data Interpretation",
            isSpecializedAgriBio: false,
            overview: "Translate tables, multi-series charts, and experimental datasets into accurate academic prose (directly reinforcing IELTS Writing Task 1).",
            keyConventions: [
                "Lead with the overarching pattern before citing granular figures.",
                "Use exact comparative structures ('twice as high as', 'narrowed by 14 percentage points', 'plateaued at').",
                "Avoid inferring causation from correlational charts alone."
            ],
            modelExcerpt: "Across all four monitoring sites, nitrate leaching peaked during late autumn, with conventionally fertilized plots recording concentrations nearly double those of clover-integrated swards.",
            keyPhrases: [
                "Broadly speaking, the data reveals a clear divergence between...",
                "Whereas Group A plateaued after week four, Group B continued to climb steadily."
            ],
            arabicNotes: "تفسير البيانات الأكاديمي يبدأ بالاتجاه العام (Overview) قبل الأرقام التفصيلية، ويتجنب الخلط بين الارتباط الإحصائي والسببية.",
            practiceTask: "Write a 150-word data commentary describing a 10-year comparison of two agricultural or environmental metrics."
        ),
        AcademicEnglishUnit(
            id: "acad-06-agri-animal-nutrition",
            title: "Applied Track: Animal Nutrition, Biotechnology & Environmental Sustainability",
            category: "Agricultural & Animal Sciences",
            isSpecializedAgriBio: true,
            overview: "Optional specialized academic English module tailored to agricultural sciences, animal nutrition, biotechnology, and sustainable livestock systems.",
            keyConventions: [
                "Master high-frequency discipline terms: dry matter intake (DMI), feed conversion ratio (FCR), enteric methane, rumen microbiome, precision formulation, bioavailability.",
                "Frame sustainability arguments objectively, weighing food security, animal welfare, economic viability, and greenhouse gas intensity.",
                "Practice explaining technical concepts clearly to both specialist and non-specialist IELTS/interview audiences."
            ],
            modelExcerpt: "Optimizing crude protein levels in ruminant rations improves nitrogen use efficiency while reducing ammonia volatilization. Coupled with genomic selection and precision pasture budgeting, these nutritional strategies enable commercial dairy systems to lower emissions intensity per kilogram of milk solids without compromising herd health.",
            keyPhrases: [
                "feed conversion efficiency",
                "emissions intensity per unit of output",
                "evidence-based herd nutrition",
                "circular bioeconomy"
            ],
            arabicNotes: "هذا المسار الاختياري يدربك على التعبير الأكاديمي والمهني المتخصص في علوم الزراعة وتغذية الحيوان والتقنية الحيوية والاستدامة البيئية، مع القدرة على تبسيط المصطلحات لغير المتخصصين.",
            practiceTask: "Write a 250-word IELTS Task 2-style argument evaluating whether technological innovation or dietary shifts play the larger role in sustainable food systems."
        ),
        AcademicEnglishUnit(
            id: "acad-07-lit-review",
            title: "Literature Review Synthesis & Thematic Grouping",
            category: "Scientific Articles",
            isSpecializedAgriBio: false,
            overview: "Synthesize multiple studies thematically rather than listing summaries author by author ('Smith said... Jones said...').",
            keyConventions: [
                "Group studies by consensus, methodology, or unresolved contradiction.",
                "Use evaluative reporting verbs ('corroborate', 'challenge', 'refine', 'overlook') to establish your scholarly voice.",
                "Conclude with a crisp research gap statement motivating your study."
            ],
            modelExcerpt: "Although early feedlot trials reported steep methane reductions from macroalgae additives (Jones, 2021; Patel, 2022), subsequent pasture-based studies (Byrne et al., 2024) noted high seasonal intake variability, leaving continuous grazing efficacy unresolved.",
            keyPhrases: [
                "A growing body of literature converges on...",
                "Despite extensive investigation into X, comparatively little is known about...",
                "Taken together, these divergent findings point to..."
            ],
            arabicNotes: "مراجعة الأدبيات المتقدمة تجمع الدراسات حسب المحاور والاتفاق أو الاختلاف بدلاً من سرد كل باحث على حدة، وتُختم بتحديد الفجوة البحثية بدقة.",
            practiceTask: "Write a 150-word thematic synthesis paragraph comparing three hypothetical studies on renewable energy or nutrition."
        ),
        AcademicEnglishUnit(
            id: "acad-08-grant-proposals",
            title: "PhD & Research Grant Proposal Writing",
            category: "Research Proposals",
            isSpecializedAgriBio: false,
            overview: "Articulate clear research questions, testable hypotheses, measurable milestones, and societal impact for EU/Irish fellowships.",
            keyConventions: [
                "State the specific knowledge gap within the first two sentences.",
                "Align every work package with a verifiable deliverable and risk-mitigation plan.",
                "Quantify expected economic, environmental, or scientific impact without hype."
            ],
            modelExcerpt: "This project tests whether multi-species forage mixtures can reduce synthetic nitrogen inputs by 35% while maintaining milk-solids output across 18 commercial Irish farms. Work Package 1 establishes baseline soil carbon; Work Package 2 evaluates herd performance across two grazing seasons.",
            keyPhrases: [
                "The overarching objective of this proposal is to...",
                "To address this gap, we test three interrelated hypotheses...",
                "Anticipated deliverables include open-access datasets and..."
            ],
            arabicNotes: "مقترح المنحة أو الدكتوراه الناجح يحدد الفجوة البحثية فوراً، ويطرح فرضيات قابلة للقياس، ويربط كل مرحلة بمخرجات واضحة وخطة إدارة مخاطر.",
            practiceTask: "Draft a 180-word project summary stating your research problem, methodology, and expected impact."
        ),
        AcademicEnglishUnit(
            id: "acad-09-peer-review-rebuttal",
            title: "Responding to Peer Reviewers Professionally",
            category: "Academic Publishing",
            isSpecializedAgriBio: false,
            overview: "Write calm, structured, evidence-backed point-by-point responses to journal reviewers—even when politely disagreeing.",
            keyConventions: [
                "Thank the reviewer specifically for constructive critiques and quote exact line numbers of revisions.",
                "When disagreeing, cite empirical data or methodological precedent without defensive language.",
                "Structure every reply as: Reviewer Comment → Author Response → Exact Manuscript Change."
            ],
            modelExcerpt: "We thank Reviewer 2 for highlighting potential seasonal confounding in Figure 3. We have now added a mixed-effects covariate model (Methods, p. 8, lines 14–22) confirming that the treatment effect remains statistically significant across both spring and autumn cohorts (p = 0.004).",
            keyPhrases: [
                "We appreciate the reviewer's insightful observation regarding...",
                "Accordingly, we have revised Section 2.3 to clarify...",
                "While we acknowledge this perspective, our dataset indicates..."
            ],
            arabicNotes: "الرد على محكّمي المجلات العلمية يتسم بالهدوء والاحترافية وتوثيق التعديلات بأرقام الصفحات والأسطر، مع استخدام الأدلة الإحصائية عند الاختلاف في الرأي.",
            practiceTask: "Write two concise reviewer responses: one accepting a statistical suggestion and one politely defending your sample design."
        ),
        AcademicEnglishUnit(
            id: "acad-10-conference-qa",
            title: "International Conference Q&A & Panel Defense",
            category: "Academic Presentations",
            isSpecializedAgriBio: false,
            overview: "Handle tough, unexpected, or multi-part audience questions with Band 9 poise, precision, and intellectual honesty.",
            keyConventions: [
                "Paraphrase complex questions briefly so the whole room hears and you gain 3 seconds to structure your reply.",
                "Bridge cleanly when a question falls outside your experimental scope.",
                "Invite post-session collaboration for deep technical follow-ups."
            ],
            modelExcerpt: "Thank you—that is an important methodological question about subsoil sampling depth. In this phase we restricted cores to 30 cm due to budget constraints; however, we are partnering with soil physicists next spring to extend sampling to 100 cm, and I would be glad to share our protocol after the session.",
            keyPhrases: [
                "That touches on a critical nuance...",
                "While our dataset did not directly test X, our findings are consistent with...",
                "I would be happy to look at those figures with you after the panel."
            ],
            arabicNotes: "في جلسات الأسئلة بالمؤتمرات، أعد صياغة السؤال باختصار لتكسب وقتاً للتفكير، وكن صريحاً بشأن حدود دراستك دون ارتباك.",
            practiceTask: "Practice recording 45-second spoken answers to two challenging questions about your field in Pronunciation Lab or Speaking."
        ),
        AcademicEnglishUnit(
            id: "acad-11-ireland-eu-interviews",
            title: "International Career Interviews & Executive Summaries (Ireland / EU)",
            category: "Professional Communication",
            isSpecializedAgriBio: false,
            overview: "Communicate achievements clearly using the STAR framework (Situation, Task, Action, Result) tailored to Irish and European technical employers.",
            keyConventions: [
                "Quantify impact ('reduced feed formulation cost by 8%', 'analysed 400+ field samples') rather than listing vague job duties.",
                "Balance confidence with collaborative humility—highly valued in Irish and EU workplace culture.",
                "Prepare 2–3 informed questions about the organization's research pipeline or sustainability targets."
            ],
            modelExcerpt: "When seasonal forage quality dipped on a partner dairy farm, I audited silage dry-matter reports, reformulated mineral and protein balances with the farm advisor, and helped stabilize milk-solids yield within four weeks while cutting wasted concentrate by 9%.",
            keyPhrases: [
                "In my previous role, I took ownership of...",
                "As a measurable outcome, we achieved...",
                "What excites me most about your team's current projects is..."
            ],
            arabicNotes: "المقابلات المهنية في أيرلندا وأوروبا تفضّل الإجابات المنظمة بمنهج STAR المدعومة بأرقام ونتائج ملموسة مع نبرة تعاونية واثقة.",
            practiceTask: "Write a 160-word STAR story describing a technical problem you solved and the measurable result."
        ),
        AcademicEnglishUnit(
            id: "acad-12-agri-policy-briefs",
            title: "Applied Track: Policy Briefs & One Health Sustainability Reports",
            category: "Agricultural & Animal Sciences",
            isSpecializedAgriBio: true,
            overview: "Translate complex animal science, biotechnology, and environmental findings into executive policy briefs for non-specialist decision-makers.",
            keyConventions: [
                "Open with a 3-bullet Executive Takeaway before technical evidence.",
                "Translate jargon ('enteric methanogenesis' → 'methane produced during cattle digestion') without losing scientific accuracy.",
                "Weigh cost, farmer adoption feasibility, and environmental targets side by side."
            ],
            modelExcerpt: "Executive Summary: Integrating white clover into perennial ryegrass pastures cuts chemical nitrogen fertilizer demand by up to 40% while sustaining herbage yield. Targeted advisory grants and soil-testing vouchers can accelerate farm-level uptake across Ireland within five years.",
            keyPhrases: [
                "Key policy recommendation:",
                "Cost-benefit trade-offs indicate that...",
                "Scaling adoption across commercial farms will require..."
            ],
            arabicNotes: "مذكرات السياسات الزراعية والبيئية تترجم البحث العلمي المعقد إلى توصيات عملية واضحة لصناع القرار والمزارعين دون التفريط بالدقة العلمية.",
            practiceTask: "Draft a 200-word policy brief recommending one practical sustainability measure for livestock or crop production."
        )
    ]
}
