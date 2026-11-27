import Foundation

/// Original illustrative IELTS Academic Writing responses across Band 4 to Band 9.
/// Explicitly labeled as original educational examples (never official IELTS scripts).
public enum WritingModelSamples {
    public static let samples: [WritingModelSample] = [
        WritingModelSample(
            id: "sample-t2-band4",
            taskNumber: 2,
            estimatedBand: 4.0,
            promptSummary: "Some people believe governments should invest more in public transport than in building new roads. To what extent do you agree or disagree?",
            essayText: """
            Today traffic is very big problem in many city. People use car every day and road is always busy. I agree government should spend money on bus and train.

            First, bus and train carry many people. If people take bus, there is less car on road and air is more clean. Car make pollution and it is bad for health. Also ticket for bus is cheap for poor people and student.

            Second, making new road cost a lot of money. Even when government build big road, more people buy car and traffic come back again. So new road do not solve problem.

            In conclusion, public transport is better than new road because it help environment and reduce traffic.
            """,
            examinerNotes: "Band 4.0 illustration: Addresses the prompt with a basic position, but is under-developed (<150 words), relies on simple repetitive vocabulary ('very big', 'make pollution'), and contains frequent article, plural, and subject-verb agreement errors.",
            arabicSummary: "مثال توضيحي لمستوى 4.0: الفكرة الأساسية واضحة لكن النص قصير جداً، والمفردات بسيطة ومكررة، وتوجد أخطاء متكررة في أدوات التعريف ومطابقة الفعل للفاعل."
        ),
        WritingModelSample(
            id: "sample-t2-band5.5",
            taskNumber: 2,
            estimatedBand: 5.5,
            promptSummary: "Some people believe governments should invest more in public transport than in building new roads. To what extent do you agree or disagree?",
            essayText: """
            In modern cities, traffic congestion has become a serious issue for daily commuters. Some people argue that governments should prioritize public transport instead of constructing new highways. I strongly agree with this view because public transit reduces pollution and saves public money in the long run.

            Firstly, expanding bus and rail networks can significantly reduce the number of private vehicles on the road. When trains and buses are reliable and affordable, many commuters prefer to leave their cars at home. As a result, carbon emissions decrease and air quality improves, which is beneficial for urban residents.

            Secondly, building new roads often fails to solve congestion permanently. Although wider highways may improve traffic flow at first, they usually encourage more people to buy cars. Consequently, traffic jams return within a few years, while the government must continue paying high maintenance costs.

            In conclusion, investing in public transportation is a more effective long-term strategy than expanding road networks because it lowers emissions and manages urban growth more sustainably.
            """,
            examinerNotes: "Band 5.5–6.0 illustration: Clear position and logical paragraphing, but still below 250 words (~180 words) and relies on predictable linkers ('Firstly', 'Secondly', 'In conclusion'). Expanding body paragraphs with concrete examples and varied complex clauses would move this to Band 7.0+.",
            arabicSummary: "مثال توضيحي لمستوى 5.5–6.0: تنظيم الفقرات جيد والموقف واضح، لكن عدد الكلمات أقل من 250 كلمة، وأدوات الربط تقليدية. التوسع بالأمثلة وتنويع التراكيب يرفع المستوى إلى 7.0 فأكثر."
        ),
        WritingModelSample(
            id: "sample-t2-band7.5",
            taskNumber: 2,
            estimatedBand: 7.5,
            promptSummary: "Some people believe governments should invest more in public transport than in building new roads. To what extent do you agree or disagree?",
            essayText: """
            Urban traffic congestion imposes heavy economic and environmental costs on modern societies. While maintaining existing road infrastructure remains necessary for freight and rural connectivity, I strongly agree that public budgets should prioritize mass transit systems over constructing new urban highways.

            The primary justification for prioritizing rail and bus networks is their superior carrying capacity and environmental efficiency. A single electrified commuter rail line can transport as many passengers per hour as multiple lanes of motorway while generating a fraction of the greenhouse gas emissions. Furthermore, reliable public transport promotes social equity by ensuring that students, older citizens, and lower-income workers can access employment and education without bearing the rising expenses of vehicle ownership, fuel, and urban parking.

            Conversely, expanding urban road capacity rarely delivers lasting relief from congestion. Transport economists frequently observe a phenomenon known as induced demand: when new lanes open, driving temporarily becomes faster, which encourages additional motorists to make car journeys until gridlock re-emerges. Allocating billions of euros to asphalt expansion therefore locks cities into higher maintenance liabilities, greater air pollution, and fragmented urban spaces. That said, targeted road upgrades remain justified in sparsely populated agricultural regions where high-frequency rail is economically unviable.

            In conclusion, although selective road maintenance is indispensable outside major cities, directing the bulk of transport investment toward accessible, high-capacity public transit offers a far more sustainable and cost-effective solution to urban congestion.
            """,
            examinerNotes: "Band 7.5 illustration: Exceeds 250 words (~255 words), presents a nuanced and consistent position, uses natural topic progression and precise collocations ('induced demand', 'social equity', 'maintenance liabilities'), and deploys complex concession and relative clauses accurately.",
            arabicSummary: "مثال توضيحي لمستوى 7.5: يستوفي شرط عدد الكلمات، ويقدم حجة متوازنة ومدعومة بمصطلحات دقيقة مثل induced demand وتراكيب نحوية مركبة سليمة دون أخطاء ملحوظة."
        ),
        WritingModelSample(
            id: "sample-t2-band9",
            taskNumber: 2,
            estimatedBand: 9.0,
            promptSummary: "Some people believe governments should invest more in public transport than in building new roads. To what extent do you agree or disagree?",
            essayText: """
            As metropolitan populations expand, policymakers face a recurring fiscal dilemma: whether to relieve gridlock by widening road networks or by investing decisively in public transit. Although essential road upkeep cannot be neglected—particularly for regional logistics and rural communities—I firmly contend that governments should allocate the majority of new transport capital to public transportation.

            First, mass transit resolves the spatial inefficiency inherent in private car dependence. Dense cities possess finite land, and dedicating ever larger corridors to motorways and parking degrades livability while yielding diminishing returns. By contrast, integrated metro, tram, and bus-rapid-transit networks move substantially greater passenger volumes through narrow corridors, curbing particulate pollution and lowering per-capita carbon emissions. Equally important, affordable transit widens labour-market access, enabling residents across income brackets to reach workplaces, hospitals, and universities reliably.

            Second, historical evidence from major cities demonstrates that highway expansion tends to be self-defeating. Under the well-documented mechanism of induced demand, newly added lane capacity attracts latent private vehicle trips, restoring congestion within a few years while permanently raising road-maintenance budgets. Redirecting those same public funds toward frequent, punctual transit—paired with safe cycling infrastructure—alters commuter incentives at the root rather than merely postponing bottlenecks. Admittedly, sparsely populated countryside areas lack the passenger density required for light rail; in such contexts, modest road improvements combined with demand-responsive rural buses represent a more pragmatic allocation of resources.

            Ultimately, prioritizing public transit over urban highway construction addresses congestion, climate targets, and economic inclusivity simultaneously, making it the sounder long-term investment for modern states.
            """,
            examinerNotes: "Band 9.0 illustration: Fully developed, sophisticated academic argument with seamless cohesion (no mechanical signposting), effortless lexical precision ('latent private vehicle trips', 'diminishing returns', 'fiscal dilemma'), and full syntactic control.",
            arabicSummary: "مثال توضيحي لمستوى 9.0: حجة أكاديمية ناضجة ومترابطة بسلاسة طبيعية دون أدوات ربط مصطنعة، مع دقة معجمية عالية وتحكم نحوي كامل."
        ),
        WritingModelSample(
            id: "sample-t1-band7.5",
            taskNumber: 1,
            estimatedBand: 7.5,
            promptSummary: "Line chart comparing renewable electricity share (%) in Ireland, Germany, and Spain from 2010 to 2024.",
            essayText: """
            The line chart illustrates the proportion of electricity generated from renewable sources in Ireland, Germany, and Spain over a fourteen-year period from 2010 to 2024.

            Overall, all three countries recorded substantial growth in renewable electricity generation, with Germany and Spain consistently exceeding half of their power mix by the end of the period, while Ireland achieved the steepest relative climb from the lowest starting point.

            In 2010, Spain led the group at 32%, followed by Germany at 19% and Ireland at 15%. Over the next eight years, Germany expanded rapidly to reach 38% in 2018, overtaking Spain temporarily after Spanish output fluctuated around 36%. During the same interval, Ireland rose steadily to 33%, driven largely by wind expansion.

            Between 2018 and 2024, growth accelerated across all three nations. Spain surged to 56% by 2024, narrowly ahead of Germany at 54%. Ireland climbed to 44% in 2024, nearly tripling its 2010 figure despite remaining below the other two countries throughout the timeframe.
            """,
            examinerNotes: "Band 7.5 Task 1 illustration (~172 words): Clear paraphrase in introduction, concise high-value overview without raw figures, logical chronological grouping, accurate comparisons, and precise trend verbs.",
            arabicSummary: "مثال توضيحي لمهمة الكتابة الأولى (مستوى 7.5): يتضمن إعادة صياغة واضحة، وفقرة نظرة عامة دقيقة بدون حشو أرقام، ومقارنات زمنية منظمة."
        ),
        WritingModelSample(
            id: "sample-t1-band8.5-process",
            taskNumber: 1,
            estimatedBand: 8.5,
            promptSummary: "Process diagram showing how farm slurry is converted into purified biomethane and organic fertilizer via anaerobic digestion.",
            essayText: """
            The diagram illustrates the closed-loop industrial process by which agricultural slurry is transformed into purified biomethane and nutrient-rich organic fertilizer.

            Overall, the conversion comprises five sequential stages—from raw collection and anaerobic fermentation to gas scrubbing and digestate separation—yielding both renewable grid energy and circular agricultural inputs with minimal waste.

            Initially, liquid livestock slurry is pumped from farm storage tanks into a sealed reception chamber, where coarse debris is screened out and feedstock temperature is stabilized. The conditioned slurry is then transferred into a heated, oxygen-free anaerobic digester maintained at approximately 38°C. Over several weeks, naturally occurring microbial communities break down organic solids, releasing raw biogas alongside a semi-liquid byproduct known as digestate.

            In the downstream phase, the raw biogas passes through a purification unit where carbon dioxide and hydrogen sulphide are scrubbed away, producing high-purity biomethane suitable for national gas grids or vehicle fuel. Simultaneously, the remaining digestate is mechanically separated into fibrous bedding and low-odour liquid fertilizer, which is returned directly to pastures, completing the circular cycle.
            """,
            examinerNotes: "Band 8.5 Task 1 Process illustration (~183 words): Seamless passive voice control ('is pumped', 'is mechanically separated'), accurate technical precision, crisp overview identifying the closed-loop nature and dual outputs.",
            arabicSummary: "مثال توضيحي لمهمة الكتابة الأولى — مخطط عمليات (مستوى 8.5): تحكم ممتاز في المبني للمجهول وأدوات التتابع الزمني مع نظرة عامة تحدد طبيعة الدورة المغلقة والمخرجات."
        ),
        WritingModelSample(
            id: "sample-t1-band9-table",
            taskNumber: 1,
            estimatedBand: 9.0,
            promptSummary: "Table comparing household energy sources (%) and average annual utility expenditure (€) across four European countries in 2024.",
            essayText: """
            The table compares the proportional breakdown of residential energy sources alongside mean annual household utility spending across Ireland, France, Germany, and Sweden in 2024.

            Overall, Sweden relied overwhelmingly on electricity and district heating while recording the lowest annual household bills, whereas Ireland and Germany remained substantially more dependent on fossil fuels and incurred the highest domestic energy costs.

            Electricity and district heating together accounted for 88% of Swedish residential energy, leaving natural gas and heating oil at a marginal combined share of 12%. France exhibited a broadly similar electric tilt (64%), reflected in moderate annual utility costs of €1,640 compared with Sweden's €1,390.

            By contrast, gas and oil still constituted roughly three-quarters of household energy in both Germany (76%) and Ireland (71%). This continued reliance on carbon-intensive fuels corresponded closely with elevated household expenditure: German residents paid an average of €2,280 per year, marginally below Ireland's peak figure of €2,410.
            """,
            examinerNotes: "Band 9.0 Task 1 Table illustration (~165 words): Synthesizes cross-column correlation (fossil fuel share vs cost) effortlessly, uses sophisticated proportional lexis ('marginal combined share', 'electric tilt'), and contains zero mechanical listing.",
            arabicSummary: "مثال توضيحي لمهمة الكتابة الأولى — جدول (مستوى 9.0): يربط بذكاء بين نسبة الوقود الأحفوري وتكلفة الفواتير دون سرد آلي للأرقام، مع مفردات نسبية دقيقة للغاية."
        ),
        WritingModelSample(
            id: "sample-t2-band8.5-discussion",
            taskNumber: 2,
            estimatedBand: 8.5,
            promptSummary: "Some people think technological innovation in food production can solve global hunger, while others believe reducing food waste and changing consumption habits is more effective. Discuss both views and give your own opinion.",
            essayText: """
            Debates over how to achieve lasting global food security often divide into two camps: those who place their faith in agricultural biotechnology and precision engineering, and those who insist that reforming food waste and dietary habits offers a faster, fairer remedy. In my view, while technological gains are indispensable for climate resilience, they will fall short unless paired with systemic reductions in post-harvest loss and consumer waste.

            Proponents of agricultural innovation rightly point out that climate volatility threatens staple harvests across vulnerable regions. Advances such as drought-tolerant cereal varieties, precision drip irrigation, and enzyme-enhanced livestock feeds raise output per hectare while curbing water and nitrogen intensity. Without such scientific breakthroughs, feeding a projected global population exceeding nine billion under warming temperatures would be extraordinarily difficult.

            Nevertheless, critics observe persuasively that global agriculture already produces enough calories to nourish humanity; hunger persists largely because roughly one-third of food is lost along broken supply chains or discarded by affluent households. Investing in solar-powered cold storage for rural smallholders, standardizing date labels, and moderating resource-intensive overconsumption could unlock vast nutritional supplies immediately at a fraction of the ecological footprint of expanding farmland.

            Ultimately, treating technology and behavioural reform as rival solutions creates a false dichotomy. Sustainable food security requires deploying resilient agricultural science on farms while simultaneously modernizing cold-chain logistics and curbing everyday food waste.
            """,
            examinerNotes: "Band 8.5 Discussion Essay (~256 words): Balanced treatment of both perspectives, crisp thesis synthesizing both sides ('false dichotomy'), precise domain collocations, and effortless complex syntax.",
            arabicSummary: "مثال توضيحي لمقال نقاشي (مستوى 8.5): يناقش الرأيين بتوازن عميق ويصل إلى موقف مركّب وناضج مع تراكيب نحوية سلسة ومفردات أكاديمية عالية الدقة."
        ),
        WritingModelSample(
            id: "sample-t2-band8-problem-solution",
            taskNumber: 2,
            estimatedBand: 8.0,
            promptSummary: "Antimicrobial resistance threatens both human medicine and livestock health worldwide. What are the main causes of this crisis, and what coordinated actions are required to slow it down?",
            essayText: """
            Antimicrobial resistance (AMR) has emerged as one of the most pressing One Health threats of the twenty-first century, undermining routine surgeries and veterinary care alike. Addressing this escalating crisis requires confronting both inappropriate clinical prescribing and routine agricultural overuse through coordinated regulation and preventative investment.

            Two primary drivers explain the rapid spread of resistant pathogens. In human healthcare, antibiotics are still frequently prescribed for viral infections against which they have no effect, or sold without prescription in under-regulated markets. Concurrently, in intensive livestock systems, low-dose antimicrobials have historically been administered across entire herds to compensate for overcrowded housing rather than to treat confirmed bacterial illness, creating an ideal evolutionary reservoir for resistant strains.

            Slowing AMR therefore demands synchronized action across medical and agricultural sectors. Governments should enforce prescription-only veterinary access and mandate transparent farm-level usage audits, following the successful stewardship models pioneered in northern Europe. Equally vital, public funding should incentivize preventative biosecurity, targeted herd vaccination, and rapid point-of-care diagnostics so that clinicians and veterinarians can confirm bacterial infections before prescribing. Finally, international pull-incentives—such as subscription payments for novel antibiotic development—can revive stalled pharmaceutical research without encouraging high-volume sales.

            In conclusion, antimicrobial resistance is driven largely by preventable misuse in clinics and farms; only strict stewardship, improved biosecurity, and reformed drug-development incentives can preserve these vital medicines for future generations.
            """,
            examinerNotes: "Band 8.0 Problem-Solution Essay (~254 words): Directly addresses both causes and coordinated solutions with domain-accurate terminology ('One Health', 'stewardship', 'point-of-care diagnostics') and cohesive paragraph progression.",
            arabicSummary: "مثال توضيحي لمقال المشكلة والحل (مستوى 8.0): يعالج الأسباب والحلول المنسقة بوضوح منهجي ومصطلحات علمية دقيقة."
        ),
        WritingModelSample(
            id: "sample-t2-band7-adv-disadv",
            taskNumber: 2,
            estimatedBand: 7.0,
            promptSummary: "Hybrid and remote work have enabled many professionals to relocate from major capitals to smaller regional towns. Do the advantages of this shift outweigh the disadvantages for local communities?",
            essayText: """
            The rapid expansion of remote and hybrid work has allowed thousands of urban professionals to move from expensive capital cities to smaller regional towns. Although this trend can push up local property prices, I believe its long-term economic and social benefits clearly outweigh the drawbacks for regional communities.

            On the negative side, an influx of higher-earning commuters can create affordability pressures in rural housing markets. Young local residents working in hospitality, retail, or agriculture may struggle to compete with buyers accustomed to metropolitan salaries. Additionally, sudden population growth can temporarily strain village schools, clinics, and water infrastructure that were designed for smaller communities.

            However, the advantages of regional revitalization are substantial and enduring. For decades, smaller towns suffered from youth out-migration, leaving empty shopfronts and declining public services. Remote workers inject steady year-round spending into local cafes, tradespeople, and coworking hubs, helping sustain rural enterprises that previously depended only on seasonal tourism. Moreover, a broader tax base and growing families strengthen the case for government investment in high-speed broadband, regional rail links, and modern healthcare facilities—improvements that benefit long-standing residents as well as newcomers.

            In conclusion, while local authorities must monitor housing affordability and expand essential services, the economic renewal and demographic vitality brought by remote professionals represent a net gain for regional towns.
            """,
            examinerNotes: "Band 7.0–7.5 Advantages/Disadvantages Essay (~244 words—aim for 255+ in exam): Clear position, strong balanced development, natural cohesion, and accurate complex sentences.",
            arabicSummary: "مثال توضيحي لمقال المزايا والعيوب (مستوى 7.0–7.5): موقف واضح ومقارنة منطقية متوازنة مع نصيحة بزيادة 10–15 كلمة لضمان تجاوز 250 كلمة بأمان."
        )
    ]
}
