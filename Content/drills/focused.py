"""Original short, targeted IELTS-style drills; no full-exam content is reused.

Listening services and operational details are fictional. Reading examples explicitly
illustrate reasoning; they do not claim to report empirical research. Each unit is a
short skill exercise, not an IELTS-length passage or a scored examination section.
"""
from _kit import Q, G

LISTENING = [
{
 'title': 'A changed collection arrangement', 'part': 1,
 'context': 'A customer confirms the arrangements for collecting a repaired bicycle.',
 'script': [
  ('Customer', 'GB', "Hello, I'm calling about the bicycle I left with you yesterday. I was told I could collect it on Saturday, but a message arrived saying the arrangements had changed. Could you tell me what I should do? I can come on either day this weekend."),
  ('Assistant', 'AU', "Certainly. The repair will be ready on Saturday, as promised, but our collection desk will be closed then because the front entrance is being painted. You can collect on Sunday instead. We're opening especially for collections between ten and one, although the workshop itself won't be operating."),
  ('Customer', 'GB', "Sunday is fine. Do I come through the front entrance once the paint is dry, or is there another way in? I don't know the building very well."),
  ('Assistant', 'AU', "Please use the courtyard entrance. The side gate opens from the small lane behind the building. The collection point is beside the greenhouse. Bring your receipt so we can identify the bicycle. You don't need the original repair form as well; we kept a copy when you left the bike."),
 ],
 'groups': [G('Questions 1–4. Complete the notes. Write ONE WORD ONLY for each answer.', [
  Q('note', 'New collection day: __________.', 'Sunday', 'You can collect on Sunday instead.', 'The repair date is unchanged, but collection is moved to Sunday.', max=1, trap='Saturday is when the repair is ready, not when collection is available.'),
  Q('note', 'Use the __________ entrance.', 'courtyard', 'Please use the courtyard entrance.', 'The courtyard entrance replaces the unavailable front entrance.', max=1),
  Q('note', 'Collection point: beside the __________.', 'greenhouse', 'The collection point is beside the greenhouse.', 'The greenhouse is the stated landmark.', max=1),
  Q('note', 'Bring the __________.', 'receipt', 'Bring your receipt so we can identify the bicycle.', 'Only the receipt is required; the repair form is not.', max=1),
 ])],
},
{
 'title': 'Choosing a suitable evening class', 'part': 1,
 'context': 'A learner asks a course coordinator about two beginner courses.',
 'script': [
  ('Learner', 'IE', "I'm interested in learning to sew, but I have never used a machine. The website lists two evening courses, and I can't work out which one would be suitable. One seems to include making clothes, which is what I eventually want to do."),
  ('Coordinator', 'GB', "The clothes course assumes that you can already set up a machine and stitch a straight seam. Start with the introductory course. In the first session you'll make a cushion cover, and later you'll try a simple bag. You don't have to bring a project of your own."),
  ('Learner', 'IE', "That sounds more realistic. The old leaflet says classes are in Room Twelve. Is that still correct? I need to tell a friend who might join me."),
  ('Coordinator', 'GB', "They've moved to Room Seven, on the ground floor. The room is more spacious. We provide machines, fabric and thread, but bring your own scissors. You'll also need to book before arriving, because there are only eight places. The clothes course has twelve places, but don't confuse that with the beginner group."),
 ],
 'groups': [G('Questions 1–4. Complete the notes. Write ONE WORD AND/OR A NUMBER for each answer.', [
  Q('note', 'First project: a __________ cover.', 'cushion', "In the first session you'll make a cushion cover", 'A cushion cover precedes the later bag project.', max=1),
  Q('note', 'New classroom: Room __________.', ['Seven', '7'], "They've moved to Room Seven", 'Room Seven replaces Room Twelve.', max=1),
  Q('note', 'Learners must bring __________.', 'scissors', 'bring your own scissors', 'Machines, fabric and thread are supplied.', max=1),
  Q('note', 'The introductory course has __________ places.', ['eight', '8'], 'there are only eight places', 'Twelve refers to the clothes course.', max=1),
 ])],
},
{
 'title': 'Guidance for a community seed exchange', 'part': 2,
 'context': 'An organiser explains the procedure for a small seed-exchange event.',
 'script': [
  ('Organiser', 'AU', "Before we open the exchange tables, let me explain the labels. We are not asking people to be experts, but other gardeners need enough information to decide whether a packet is suitable. Write the plant name clearly and include the year the seeds were collected. If you don't know the variety, say so rather than guessing. There are blank labels at reception."),
  ('Organiser', 'AU', "Please bring dry seeds in envelopes, not in plastic bags that might trap moisture. We have a separate table for plants in pots, so don't put those among the seed packets. A volunteer can show you which table is appropriate when you arrive."),
  ('Organiser', 'AU', "You are welcome even if you have nothing to exchange. We want beginners to participate, not feel that they must already own a collection. Donations are optional and help us buy labels. The short talk starts at eleven in the courtyard. If it rains, we'll move to the classroom; the exchange itself will remain in this hall throughout the morning."),
 ],
 'groups': [
  G('Questions 1–2. Choose the correct letter, A, B or C.', [
   Q('mcq', 'What should a participant do if a seed variety is unknown?', 'B', "If you don't know the variety, say so rather than guessing.", 'The organiser asks for uncertainty to be stated.', opts=['Leave the packet at home.', 'Indicate that the variety is uncertain.', 'Choose the most likely variety.']),
   Q('mcq', 'Who may take part in the exchange?', 'C', 'You are welcome even if you have nothing to exchange.', 'Bringing seeds is not a condition of participation.', opts=['Only experienced gardeners.', 'Only people who make a donation.', 'People without anything to contribute.']),
  ]),
  G('Questions 3–4. Complete the notes. Write ONE WORD ONLY for each answer.', [
   Q('note', 'Package dry seeds in __________.', 'envelopes', 'Please bring dry seeds in envelopes', 'Envelopes are preferred to plastic bags.', max=1),
   Q('note', 'Wet-weather location for the talk: the __________.', 'classroom', "If it rains, we'll move to the classroom", 'The talk moves to the classroom; the exchange stays in the hall.', max=1),
  ]),
 ],
},
{
 'title': 'An orientation for volunteer readers', 'part': 2,
 'context': 'A coordinator briefs volunteers who will read aloud at a community centre.',
 'script': [
  ('Coordinator', 'GB', "Thank you for joining our volunteer reading group. Each session lasts forty minutes, but you won't read continuously for that whole time. Begin by asking participants what they would enjoy hearing. Some may want a story, while others prefer a newspaper article. We have examples available, and you can offer a choice without overwhelming the group."),
  ('Coordinator', 'GB', "Read at a comfortable pace and pause when people want to discuss a passage. The aim is shared enjoyment rather than finishing a particular number of pages. Please don't correct a participant who wants to try reading aloud unless they ask for help. Quiet encouragement is usually more appropriate than turning the session into a test."),
  ('Coordinator', 'GB', "Afterwards, write a brief note in the session diary. Record which texts were used and any requests for next time, but don't include personal details about participants. Put books back on the trolley. We used to keep them in the cupboard, but that space is now for craft materials. If you cannot attend a booked session, contact reception rather than simply asking another volunteer to take over."),
 ],
 'groups': [G('Questions 1–4. Choose the correct letter, A, B or C.', [
  Q('mcq', 'How should volunteers begin a reading session?', 'A', 'Begin by asking participants what they would enjoy hearing.', 'Participants should have a say in the reading material.', opts=['Ask the group about their preferences.', 'Set a target number of pages.', 'Read the newspaper before offering alternatives.']),
  Q('mcq', 'What does the coordinator identify as the main purpose?', 'C', 'The aim is shared enjoyment', 'The session is for enjoyment, not assessment or speed.', opts=['Improving examination performance.', 'Completing a whole book.', 'Enjoying reading together.']),
  Q('mcq', 'What belongs in the session diary?', 'B', 'Record which texts were used and any requests for next time', 'The diary records materials and future requests.', opts=['Detailed personal histories.', 'Texts and requests for future sessions.', 'Corrections to each participant’s reading.']),
  Q('mcq', 'Where should volunteers return books?', 'A', 'Put books back on the trolley.', 'The trolley is the current storage location.', opts=['On the trolley.', 'In the craft cupboard.', 'At the reception desk.']),
 ])],
},
{
 'title': 'Separating observation from explanation', 'part': 3,
 'context': 'Two students discuss observations made during a classroom design activity.',
 'script': [
  ('Nadia', 'GB', "I've looked at our notes from the classroom activity. You wrote that the group beside the window was more motivated, but I'm not sure we observed motivation directly. What exactly did we see that led you to that conclusion?"),
  ('Evan', 'US', "They started writing sooner and produced more ideas on their sheet. But you're right: that doesn't necessarily mean they were more motivated. They might have understood the instructions more quickly, or one member might have suggested an approach immediately."),
  ('Nadia', 'GB', "Let's describe what happened first, then discuss possible explanations separately. We should also say that we only watched one session. We can't conclude that sitting near a window makes groups work faster from that alone."),
  ('Evan', 'US', "Agreed. For the next observation, let's use the same recording sheet independently. We can compare the descriptions afterwards. I'd like to record when each group begins the task, but we need to agree what 'begins' means. Talking about an idea might be part of the work even before anyone writes."),
  ('Nadia', 'GB', "And we should remove the names from the report. The assignment is about the activity, not ranking individual classmates. We can refer to the groups by letters instead."),
 ],
 'groups': [G('Questions 1–4. Choose the correct letter, A, B or C.', [
  Q('mcq', 'Why does Nadia question the word “motivated”?', 'C', "I'm not sure we observed motivation directly", 'The description moves from observed behaviour to an inferred cause.', opts=['The group produced no written work.', 'The observation was conducted outdoors.', 'It interprets behaviour rather than simply recording it.']),
  Q('mcq', 'What limitation will they state in the report?', 'A', 'we only watched one session', 'One session cannot establish a general causal conclusion.', opts=['Only one session was observed.', 'No group completed a recording sheet.', 'The instructions were deliberately changed.']),
  Q('mcq', 'What will they clarify before timing the next activity?', 'B', "we need to agree what 'begins' means", 'A shared definition is needed before recording starting times.', opts=['Which group is most motivated.', 'What counts as starting the task.', 'How many windows the room contains.']),
  Q('mcq', 'How will groups be identified in the report?', 'C', 'We can refer to the groups by letters instead.', 'Letters replace names in the report.', opts=['By the names of their leaders.', 'By the number of ideas produced.', 'By letters.']),
 ])],
},
{
 'title': 'Selecting material for a student exhibition', 'part': 3,
 'context': 'Two students decide what to include in an exhibition about a design process.',
 'script': [
  ('Priya', 'AU', "For our exhibition, I originally thought we should show only the final models. They look much neater than the early attempts. But then visitors wouldn't see how our ideas developed, and that is the point of the assignment."),
  ('Daniel', 'GB', "Exactly. We don't need every sketch, though. Let's choose one that shows a decision changing. Your first version had a handle at the top, and the later one moved it to the side. That would let us explain why trying the model affected the design."),
  ('Priya', 'AU', "We should label the first model as a prototype, so nobody thinks it is a finished product. The caption needs to mention that it was made only to test the grip. We didn't test how long the material would last."),
  ('Daniel', 'GB', "And let's include the feedback sheet, but remove the volunteers' names first. We can summarise repeated comments rather than display every response. I don't think an average score alone would explain what people found awkward."),
  ('Priya', 'AU', "For the last panel, let's state what remains unresolved. We could invite suggestions, but we shouldn't imply that the final version has passed a full safety assessment. The exhibition shows a learning process, not a product launch."),
 ],
 'groups': [G('Questions 1–4. Complete the notes. Write ONE WORD ONLY for each answer.', [
  Q('note', 'Choose a sketch showing a changed __________.', 'decision', "Let's choose one that shows a decision changing.", 'The chosen sketch should demonstrate development, not merely neatness.', max=1),
  Q('note', 'Label the early model as a __________.', 'prototype', 'label the first model as a prototype', 'The label prevents it being mistaken for a finished product.', max=1),
  Q('note', 'The early model was made to test the __________.', 'grip', 'it was made only to test the grip', 'Material durability was outside the test.', max=1),
  Q('note', 'Remove volunteers’ __________ from the feedback sheet.', 'names', "remove the volunteers' names first", 'Feedback can be shown without identifying volunteers.', max=1),
 ])],
},
{
 'title': 'Understanding a demonstration model', 'part': 4,
 'context': 'A lecturer explains the purpose and limitations of a simplified model.',
 'script': [
  ('Lecturer', 'IE', "A demonstration model represents selected features of a system. Its usefulness depends on a clear purpose. Imagine using a tray of sand to show how a channel changes when water flows through it. The model may make the movement of sediment visible, but that does not mean every detail behaves like a full-sized river. The scale, material and duration have all been changed."),
  ('Lecturer', 'IE', "Before beginning, state which relationship you want to demonstrate. Then identify which conditions will remain constant and which one you will vary. Otherwise, an interesting visual change can be difficult to interpret. If several things change together, you may not know which produced the result."),
  ('Lecturer', 'IE', "Keep a record of the sequence, including attempts that did not behave as expected. These are not automatically useless; they may reveal a missing assumption. However, an unexpected result should not immediately be treated as a discovery about the larger system. First check the model itself. A demonstration can generate a useful question without providing a complete answer. Its limitations should therefore appear in the explanation, rather than being mentioned only if someone challenges the conclusion."),
 ],
 'groups': [G('Questions 1–4. Complete the notes. Write ONE WORD ONLY for each answer.', [
  Q('note', 'The value of a demonstration depends on its __________.', 'purpose', 'Its usefulness depends on a clear purpose.', 'The model must have a defined explanatory purpose.', max=1),
  Q('note', 'Several changed conditions can make results hard to __________.', 'interpret', 'an interesting visual change can be difficult to interpret', 'Changing several variables makes attribution difficult.', max=1),
  Q('note', 'An unexpected result may reveal a missing __________.', 'assumption', 'they may reveal a missing assumption', 'Unsuccessful attempts can expose assumptions needing attention.', max=1),
  Q('note', 'Include the model’s __________ in the explanation.', 'limitations', 'Its limitations should therefore appear in the explanation', 'Limitations should be stated proactively.', max=1),
 ])],
},
{
 'title': 'From a proposal to a reliable schedule', 'part': 4,
 'context': 'A lecturer discusses planning a small public event.',
 'script': [
  ('Lecturer', 'GB', "A schedule is more than a list of activities with starting times. It also expresses dependencies. If a demonstration requires a table to be assembled first, the assembly is not simply another optional task. It must be completed before that activity can begin. Identifying these relationships early helps organisers see why a small delay in one place can affect several later events."),
  ('Lecturer', 'GB', "Distinguish the time an activity takes from the availability of the people who carry it out. A task requiring twenty minutes may still delay the programme for an hour if the only trained person is busy elsewhere. Recording responsibilities beside activities helps expose such conflicts before the event."),
  ('Lecturer', 'GB', "A useful plan also includes a buffer: a realistic allowance for minor delays. This should not be confused with making every estimate deliberately vague. Explain what the extra time is intended to absorb. Finally, decide how changes will be communicated. A revised schedule helps only if the people affected receive it. Keeping several conflicting versions in circulation can create more confusion than the original delay. Use one clearly identified current version and mark earlier copies as withdrawn."),
 ],
 'groups': [G('Questions 1–4. Complete the notes. Write ONE WORD ONLY for each answer.', [
  Q('note', 'A schedule shows relationships known as __________.', 'dependencies', 'It also expresses dependencies.', 'Some activities depend on earlier tasks being completed.', max=1),
  Q('note', 'Consider people’s __________ as well as task duration.', 'availability', 'the availability of the people who carry it out', 'A qualified person may be occupied elsewhere.', max=1),
  Q('note', 'Allow a __________ for minor delays.', 'buffer', 'includes a buffer: a realistic allowance for minor delays', 'A buffer provides planned spare time.', max=1),
  Q('note', 'Mark old schedule copies as __________.', 'withdrawn', 'mark earlier copies as withdrawn', 'Clear version control prevents contradictory instructions.', max=1),
 ])],
},
]

READING = [
{
 'title': 'What a seed packet can tell a gardener', 'discipline': 'Information Literacy',
 'paragraphs': [
  "A packet of seeds can contain several kinds of information, and they should not all be read in the same way. The plant name identifies what the packet is intended to contain. A sowing period gives guidance about timing, while a description of height helps a gardener imagine the mature plant. None of these details guarantees that every seed will develop successfully. Conditions in a particular garden may differ from those assumed by the writer of the instructions.",
  "Imagine two gardeners using seeds from the same packet. One grows them in a sheltered container; the other chooses an exposed bed. Different results would not, by themselves, prove that the label was inaccurate. To investigate a disappointing outcome, the gardener would need to consider preparation, moisture and other conditions rather than selecting a single explanation immediately. The packet is therefore a starting point for a practical decision, not a complete description of every possible growing situation. Clear guidance can acknowledge such limits without becoming so cautious that it provides no useful direction.",
 ],
 'groups': [
  G('Questions 1–2. Do the statements agree with the information? Write TRUE, FALSE or NOT GIVEN.', [
   Q('tfng', 'Information about plant height helps a gardener anticipate its mature size.', 'TRUE', 'a description of height helps a gardener imagine the mature plant', 'Height information describes an expected mature characteristic.'),
   Q('tfng', 'Different results from one packet necessarily demonstrate an inaccurate label.', 'FALSE', 'Different results would not, by themselves, prove that the label was inaccurate.', 'Other growing conditions must be considered.'),
  ]),
  G('Questions 3–4. Complete the sentences. Choose ONE WORD ONLY from the text.', [
   Q('sentence', 'A sowing period provides advice about __________.', 'timing', 'A sowing period gives guidance about timing', 'The sowing period concerns when to sow.', max=1),
   Q('sentence', 'The packet is a starting point for a practical __________.', 'decision', 'a starting point for a practical decision', 'Guidance supports a decision but cannot cover all circumstances.', max=1),
  ]),
 ],
},
{
 'title': 'The limits of a building model', 'discipline': 'Design Methods',
 'paragraphs': [
  "An architectural model can make the arrangement of a proposed building easier to understand. A viewer may see how rooms connect or where an entrance sits in relation to a street. But the model's usefulness depends on what it was made to represent. A simple block model may be appropriate for comparing overall shapes, even if it contains no doors or windows. Its missing details do not automatically make it a poor model; they may reflect a deliberately limited purpose.",
  "Problems arise when a viewer treats a representation as evidence for a claim it was not designed to support. A miniature room that looks bright under an exhibition lamp does not establish the amount of daylight the full-sized room will receive. That question needs a method suited to light and the relevant conditions. Designers should explain what a model can and cannot show. Doing so does not weaken the proposal. It allows observers to ask appropriate questions and prevents visual appeal from being mistaken for a completed assessment of performance.",
 ],
 'groups': [G('Questions 1–4. Choose the correct letter, A, B or C.', [
  Q('mcq', 'What may a simple block model usefully compare?', 'A', 'appropriate for comparing overall shapes', 'Overall form can be studied without detailed openings.', opts=['The overall forms of proposed buildings.', 'The durability of window materials.', 'The exact amount of daylight in each room.']),
  Q('mcq', 'Why might a model omit doors?', 'C', 'they may reflect a deliberately limited purpose', 'Omissions can match the intended task rather than indicate poor quality.', opts=['The designer forgot the entrance.', 'The future building will have no doors.', 'Doors are irrelevant to its particular purpose.']),
  Q('mcq', 'What is the problem with judging daylight from an exhibition model?', 'B', 'does not establish the amount of daylight the full-sized room will receive', 'Display lighting does not establish full-sized performance.', opts=['All models are unsuitable for public exhibitions.', 'The display conditions do not establish the real result.', 'A bright room is necessarily uncomfortable.']),
  Q('mcq', 'Explaining a model’s limits allows observers to', 'A', 'ask appropriate questions', 'Clear limits support more relevant discussion.', opts=['ask questions suited to what it represents.', 'avoid considering the proposal further.', 'treat visual appeal as proof of performance.']),
 ])],
},
{
 'title': 'A collection is not automatically a sample', 'discipline': 'Research Methods',
 'paragraphs': [
  "Imagine a school displaying photographs submitted by families for an anniversary exhibition. The pictures may offer rich accounts of particular experiences. They do not necessarily represent every family connected with the school. Some households may have preserved many photographs, while others have none to contribute. The exhibition reflects both the original events and later decisions about what was kept, found and submitted.",
  "This limitation does not make the collection worthless. It changes the questions that can responsibly be asked of it. A photograph can document an occasion or invite further investigation, but counting the activities visible in the collection cannot by itself establish how often all pupils took part in those activities. An organiser could seek additional material from less represented groups and record how contributions were obtained. Even then, the aim should be to broaden understanding rather than announce that every absence has been corrected. Stating how the collection was assembled helps visitors distinguish an engaging set of examples from a representative survey.",
 ],
 'groups': [G('Questions 1–4. Do the statements agree with the information? Write TRUE, FALSE or NOT GIVEN.', [
  Q('tfng', 'The photographs may preserve valuable accounts of individual experiences.', 'TRUE', 'The pictures may offer rich accounts of particular experiences.', 'A non-representative collection can still be valuable.'),
  Q('tfng', 'Every household in the hypothetical school has photographs available to contribute.', 'FALSE', 'others have none to contribute', 'Some households have no available photographs.'),
  Q('tfng', 'The anniversary exhibition will remain open for six weeks.', 'NOT GIVEN', 'an anniversary exhibition', 'The text gives no opening duration.'),
  Q('tfng', 'Explaining how contributions were obtained can help visitors interpret the collection.', 'TRUE', 'Stating how the collection was assembled helps visitors distinguish', 'Assembly information clarifies the limits of representativeness.'),
 ])],
},
{
 'title': 'When two figures do not describe the same thing', 'discipline': 'Quantitative Reasoning',
 'paragraphs': [
  "Two percentages can look directly comparable while referring to different totals. Suppose a hypothetical centre reports that thirty per cent of its workshop participants travelled by bicycle. Another centre reports that twenty per cent of all its visitors cycled. The first figure concerns people attending workshops; the second includes people who came for other reasons. Comparing the figures without noting this distinction would assume that the groups being described were equivalent.",
  "The period covered matters as well. A figure collected during a summer activity programme may not describe behaviour throughout the year. Neither percentage has to be inaccurate for the comparison to be misleading. A careful reader asks what population each number refers to, when the information was collected and how participation was defined. These questions should come before an explanation of why one centre appears more successful. Otherwise, an attractive numerical difference can invite a confident story that the available evidence does not support. The first task is to establish whether the figures answer the same question.",
 ],
 'groups': [
  G('Questions 1–2. Choose the correct letter, A, B or C.', [
   Q('mcq', 'What differs between the two hypothetical centres’ percentages?', 'B', 'The first figure concerns people attending workshops; the second includes people who came for other reasons.', 'The underlying populations differ.', opts=['The unit used to measure distance.', 'The groups included in the totals.', 'The definition of a bicycle.']),
   Q('mcq', 'What should precede an explanation of the numerical difference?', 'A', 'establish whether the figures answer the same question', 'Comparability should be checked before interpreting the difference.', opts=['Checking whether the measures are comparable.', 'Assuming both figures describe a whole year.', 'Choosing the centre with the larger percentage.']),
  ]),
  G('Questions 3–4. Complete the sentences. Choose ONE WORD ONLY from the text.', [
   Q('sentence', 'Each number should be linked to the __________ it describes.', 'population', 'what population each number refers to', 'The population is the group underlying the figure.', max=1),
   Q('sentence', 'Both percentages may be accurate while the comparison is __________.', 'misleading', 'Neither percentage has to be inaccurate for the comparison to be misleading.', 'Accurate individual figures do not guarantee a fair comparison.', max=1),
  ]),
 ],
},
{
 'title': 'Why a catalogue may preserve disagreement', 'discipline': 'Heritage Interpretation',
 'paragraphs': [
  "A community archive may receive two different accounts of an object. One contributor remembers a wooden box being used to store tools; another recalls seeing it used for sewing materials. These statements need not be mutually exclusive. The box may have served several purposes at different times. An archive that selects one account simply to produce a single neat label risks losing part of the object's history.",
  "However, preserving accounts is not the same as treating every claim as equally well supported. A useful record can identify who supplied an account, when it was recorded and whether other evidence supports it. The archive may distinguish a contributor's recollection from a conclusion reached after examining documents. If new information changes the interpretation, earlier accounts can remain accessible with an explanation of the change. This approach allows visitors to understand how knowledge developed. It also recognises that uncertainty is part of an honest description, rather than a defect that must be concealed by choosing the most confident-sounding story.",
 ],
 'groups': [G('Questions 1–4. Complete the notes. Choose ONE WORD ONLY from the text.', [
  Q('note', 'The example box may have had several __________.', 'purposes', 'served several purposes at different times', 'Different remembered uses can both be correct.', max=1),
  Q('note', 'A record should identify who supplied an __________.', 'account', 'who supplied an account', 'Attribution helps readers judge the source.', max=1),
  Q('note', 'A contributor’s recollection differs from a __________ based on documents.', 'conclusion', 'a conclusion reached after examining documents', 'The record distinguishes kinds of support.', max=1),
  Q('note', 'An honest description can include __________.', 'uncertainty', 'uncertainty is part of an honest description', 'Uncertainty should not be hidden by a confident story.', max=1),
 ])],
},
{
 'title': 'The value of an unsuccessful prototype', 'discipline': 'Design Evaluation',
 'paragraphs': [
  "A prototype is not necessarily intended to succeed in every respect. It may be built to answer a narrow question before a designer commits to a complete product. Imagine a temporary handle attached to a cardboard model. The assembly might be unsuitable for carrying a heavy load but still useful for investigating where a user's hand naturally falls. Judging it solely by its strength would overlook its intended purpose.",
  "An unsuccessful trial can therefore be informative, provided the result is interpreted carefully. If users cannot find the handle, that may reveal a problem worth addressing. But the designer must consider whether the model differs from the proposed product in ways that affected the result. A missing colour contrast, for example, could influence what users notice. The trial should be described with enough detail to make these limitations visible. The lesson is not that every failure proves progress. It is that a clearly framed trial can produce useful information even when it does not confirm the designer's expectations.",
 ],
 'groups': [
  G('Questions 1–2. Do the statements agree with the information? Write TRUE, FALSE or NOT GIVEN.', [
   Q('tfng', 'A prototype may be designed to investigate a limited question.', 'TRUE', 'answer a narrow question', 'A prototype need not test every product feature.'),
   Q('tfng', 'Every unsuccessful trial demonstrates that a design has improved.', 'FALSE', 'not that every failure proves progress', 'The value depends on framing and interpretation.'),
  ]),
  G('Questions 3–4. Choose the correct letter, A, B or C.', [
   Q('mcq', 'The cardboard model might help investigate', 'C', "where a user's hand naturally falls", 'Its purpose may concern grip location rather than load strength.', opts=['the maximum safe load of the final material.', 'the long-term cost of production.', 'the natural position of a user’s hand.']),
   Q('mcq', 'Why should differences between the model and proposed product be considered?', 'A', 'in ways that affected the result', 'A feature of the model may influence the observation.', opts=['They may influence the trial’s outcome.', 'They guarantee the result will be wrong.', 'They remove the need to describe the procedure.']),
  ]),
 ],
},
{
 'title': 'Should every instruction include every detail?', 'discipline': 'Communication Design',
 'paragraphs': [
  "Instructions can become difficult because they contain too little information, but additional detail is not always the answer. A newcomer may need a clear first step before learning about unusual exceptions. If every exception appears before that step, the reader can struggle to identify what applies to an ordinary case. In my view, guidance should distinguish the usual route from circumstances requiring additional help.",
  "This does not justify hiding information that affects safety or access. A reader must be able to discover relevant alternatives before making a consequential choice. The challenge is to organise detail, not simply to remove it. Headings, examples and a clear route to further assistance can make complexity manageable. I would judge instructions by whether users can complete the intended task and recognise when they need help, rather than by how short the text appears. A brief page that repeatedly sends users in the wrong direction is not an improvement over a longer explanation that supports accurate action.",
 ],
 'groups': [G('Questions 1–4. Do the statements agree with the writer’s views? Write YES, NO or NOT GIVEN.', [
  Q('ynng', 'Readers may need to understand the ordinary procedure before unusual cases.', 'YES', 'A newcomer may need a clear first step before learning about unusual exceptions.', 'The writer supports organising routine guidance before exceptions.'),
  Q('ynng', 'Safety information may be concealed to keep a page short.', 'NO', 'This does not justify hiding information that affects safety', 'Shortness does not justify hiding consequential information.'),
  Q('ynng', 'The writer tested these instructions with twenty new users.', 'NOT GIVEN', 'I would judge instructions', 'A judgement criterion is given, not a report of a test or sample size.'),
  Q('ynng', 'Successful action is a better criterion than the apparent brevity of instructions.', 'YES', 'rather than by how short the text appears', 'The writer prioritises accurate task completion and recognising the need for help.'),
 ])],
},
{
 'title': 'The appeal and limits of a single score', 'discipline': 'Assessment Literacy',
 'paragraphs': [
  "A single score is convenient. It can summarise a result, make a table compact and allow a quick comparison. Yet the convenience can hide differences between the performances being summarised. Imagine two learners receiving the same total on an exercise with several skills. One answers the vocabulary questions well but struggles with inference; the other shows the opposite pattern. Their totals match, but useful next steps would differ.",
  "In my view, an overall result should therefore be accompanied by information that helps a learner act. This need not mean reporting a separate score for every tiny feature. Very small groups of questions may provide too little evidence for confident conclusions. A responsible explanation distinguishes a pattern worth investigating from a secure judgement of ability. The purpose of feedback is not to create the greatest possible quantity of numbers. It is to identify what the available evidence supports, explain its limits and suggest a reasonable next activity. A summary score remains useful when it is treated as a summary rather than a complete diagnosis.",
 ],
 'groups': [
  G('Questions 1–2. Choose the correct letter, A, B or C.', [
   Q('mcq', 'Why might learners with the same total need different activities?', 'B', 'Their totals match, but useful next steps would differ.', 'Their strengths and weaknesses can be distributed differently.', opts=['The exercise contains no vocabulary questions.', 'Their performance patterns may differ.', 'One total must have been calculated incorrectly.']),
   Q('mcq', 'What concern does the writer raise about very small question groups?', 'C', 'too little evidence for confident conclusions', 'A small sample can support only cautious inferences.', opts=['They always measure too many skills.', 'They cannot produce a raw score.', 'They may be insufficient for a firm judgement.']),
  ]),
  G('Questions 3–4. Complete the sentences. Choose ONE WORD ONLY from the text.', [
   Q('sentence', 'An overall result should help the learner __________.', 'act', 'information that helps a learner act', 'Feedback should guide a practical next step.', max=1),
   Q('sentence', 'A summary score is not a complete __________.', 'diagnosis', 'rather than a complete diagnosis', 'The score summarises performance rather than explaining every skill.', max=1),
  ]),
 ],
},
]
