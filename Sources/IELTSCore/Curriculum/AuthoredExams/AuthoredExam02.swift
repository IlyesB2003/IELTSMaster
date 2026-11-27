import Foundation

// Authored Mock Exam 2 — "Health, Cities & Technology"
// Every script, passage and question in this file is written for this exam only.

extension AuthoredExams {
    static let exam02: MockExam = {
        let id = "authored-02"
        let L = "\(id)-L"
        let R = "\(id)-R"
        typealias K = AuthorKit

        // MARK: - Listening Part 1 (Note completion, Q1–10)
        let part1 = ListeningPart(
            id: "\(id)-lp1", partNumber: 1,
            title: "Volunteering at a community food bank",
            contextDescription: "A man phones a food bank to ask about volunteering. Complete the notes. Write ONE WORD AND/OR A NUMBER for each answer.",
            primaryAccent: .canadian,
            dialogue: [
                K.turn("Coordinator", .canadian, "Riverside Community Pantry, good afternoon."),
                K.turn("Sean", .irish, "Hello there. I'm phoning because I'd like to volunteer, and a friend said you were looking for people."),
                K.turn("Coordinator", .canadian, "We certainly are. Can I ask a couple of quick questions first? Are you over sixteen? That's our minimum age — anyone under eighteen needs a consent form from a parent, but sixteen is the cut-off."),
                K.turn("Sean", .irish, "Ha, yes, comfortably. I'm thirty-four."),
                K.turn("Coordinator", .canadian, "Great. So, we have three main roles: sorting donations, packing food boxes, and making deliveries to people who can't get here themselves."),
                K.turn("Sean", .irish, "I'd be interested in deliveries. I've got a driving licence, but I should say I don't actually own a car."),
                K.turn("Coordinator", .canadian, "That's no problem at all. Drivers use the pantry's own van, and it's insured for all our volunteers, so you'd never use your own vehicle anyway."),
                K.turn("Sean", .irish, "Perfect. When are the shifts?"),
                K.turn("Coordinator", .canadian, "Tuesday and Thursday evenings, and Saturday mornings. The deliveries mostly go out on Saturdays."),
                K.turn("Sean", .irish, "I work late on Thursdays, and Tuesdays I play football, so Saturday morning would suit me best."),
                K.turn("Coordinator", .canadian, "Saturday morning, then. A shift lasts three hours. They used to be four, but people found that too tiring, so we cut them down last year."),
                K.turn("Sean", .irish, "Three hours is fine. Is there any training?"),
                K.turn("Coordinator", .canadian, "Yes. Before your first shift you need to complete a short online course in food hygiene. It takes about forty-five minutes and you get a certificate at the end. Everyone does it, even the drivers, because they handle the boxes."),
                K.turn("Sean", .irish, "Makes sense. Do I need to bring anything on the first day?"),
                K.turn("Coordinator", .canadian, "Two things. We need proof of address for our insurance, so please bring a recent utility bill — a gas or electricity bill is fine. We don't need your passport. And you must wear closed shoes. Absolutely no sandals in the warehouse, because of the trolleys."),
                K.turn("Sean", .irish, "Got it. Is there anywhere to park? I'll probably come by bike, but just in case."),
                K.turn("Coordinator", .canadian, "There's no parking at the pantry itself, but you can park for free in the car park behind the library, which is about two minutes' walk."),
                K.turn("Sean", .irish, "Great. And who should I ask for when I arrive?"),
                K.turn("Coordinator", .canadian, "Ask for me — I'm Priya Szabo. That's S-Z-A-B-O."),
                K.turn("Sean", .irish, "S-Z-A-B-O. Thanks, Priya. Is there an induction?"),
                K.turn("Coordinator", .canadian, "There is. We run an induction evening for new volunteers on the first Wednesday of every month. This month it's Wednesday the third, at half past six. It lasts about an hour and you'll meet the other new people."),
                K.turn("Sean", .irish, "The third. I'll put it in my diary. Thanks very much."),
                K.turn("Coordinator", .canadian, "Before you go, is there anything you'd like to ask about the work itself?"),
                K.turn("Sean", .irish, "Yes, actually. What do volunteers usually do on a shift?"),
                K.turn("Coordinator", .canadian, "It varies. Some people sort donations as they come in, checking the dates and putting them on the shelves. Others help in the front room, welcoming visitors and helping them choose what they need. We try to rotate the tasks, so nobody does the same job every week, and at first you'll always work alongside someone experienced."),
                K.turn("Sean", .irish, "That sounds good. Do you get busier at certain times of year?"),
                K.turn("Coordinator", .canadian, "Definitely. The weeks before the winter holidays are our busiest, and that's when we most need extra help. In summer, things are usually a little calmer."),
                K.turn("Sean", .irish, "And would it be all right if a friend came along one day? She might want to volunteer too."),
                K.turn("Coordinator", .canadian, "Of course. She'd just need to register first, like you, and come to an induction evening."),
                K.turn("Sean", .irish, "Great, I'll tell her about it. Thanks again."),
                K.turn("Coordinator", .canadian, "You're welcome. And if your plans change, just send us a message, because we always have people on the waiting list who'd be glad to take a shift."),
                K.turn("Sean", .irish, "Will do. I'm really looking forward to getting started."),
                K.turn("Coordinator", .canadian, "Thank you, Sean. We'll see you then.")
            ],
            questions: [
                K.gap(L, 1, .noteCompletion, "Minimum age for volunteers: __________", ["16", "sixteen"], maxWords: 1, why: "Sixteen is the minimum; eighteen is only the age below which consent is needed.", evidence: "sixteen is the cut-off", skill: "distractor_correction"),
                K.gap(L, 2, .noteCompletion, "Delivery drivers use the pantry's own __________", ["van"], maxWords: 1, why: "Drivers use the pantry's van, not their own car.", evidence: "pantry's own van", skill: "detail"),
                K.gap(L, 3, .noteCompletion, "Preferred shift: __________ morning", ["Saturday", "Sat"], maxWords: 1, why: "Thursdays and Tuesdays are ruled out; he chooses Saturday morning.", evidence: "Saturday morning would suit me best", skill: "distractor_correction"),
                K.gap(L, 4, .noteCompletion, "Length of each shift: __________ hours", ["3", "three"], maxWords: 1, why: "Shifts are three hours; four hours was the old length.", evidence: "A shift lasts three hours", skill: "numbers"),
                K.gap(L, 5, .noteCompletion, "Before first shift: complete online course in food __________", ["hygiene"], maxWords: 1, why: "An online food hygiene course is required.", evidence: "online course in food hygiene", skill: "detail"),
                K.gap(L, 6, .noteCompletion, "Bring: a recent utility __________ (proof of address)", ["bill"], maxWords: 1, why: "A recent utility bill is needed; a passport is not.", evidence: "recent utility bill", skill: "distractor_correction"),
                K.gap(L, 7, .noteCompletion, "Wear closed __________", ["shoes"], maxWords: 1, why: "Closed shoes are required; sandals are not allowed.", evidence: "wear closed shoes", skill: "detail"),
                K.gap(L, 8, .noteCompletion, "Free parking: car park behind the __________", ["library"], maxWords: 1, why: "Free parking is in the car park behind the library.", evidence: "behind the library", skill: "detail"),
                K.gap(L, 9, .noteCompletion, "Coordinator's name: Priya __________", ["Szabo"], maxWords: 1, why: "She spells her surname S-Z-A-B-O.", evidence: "Priya Szabo", skill: "spelling"),
                K.gap(L, 10, .noteCompletion, "Induction evening: Wednesday the __________ at 6.30 pm", ["third", "3rd", "3"], maxWords: 1, why: "This month the induction is on Wednesday the third.", evidence: "Wednesday the third", skill: "dates")
            ],
            keyVocabulary: ["volunteer", "consent form", "donations", "insured", "food hygiene", "proof of address", "induction"]
        )

        // MARK: - Listening Part 2 (MCQ Q11–14, Matching Q15–20)
        let dayOptions = ["A. Monday", "B. Wednesday", "C. Friday"]
        let part2 = ListeningPart(
            id: "\(id)-lp2", partNumber: 2,
            title: "Radio feature: the new Westside Health Hub",
            contextDescription: "A local radio presenter describes a new community health centre. Questions 11–14: choose A, B or C. Questions 15–20: on which day is each service available? Choose A, B or C. You may use any letter more than once.",
            primaryAccent: .australian,
            dialogue: [
                K.turn("Presenter", .australian, "And now for some local news that will affect a lot of listeners. The new Westside Health Hub opens its doors next Monday on Harbour Street. If you've lived here a while, you'll know the building. It was originally a department store, back in the fifties, but most people remember it as the old cinema, which closed in 2015. It's been empty since then, so it's great to see it in use again."),
                K.turn("Presenter", .australian, "So why build a hub at all? There's been some talk that the hospital is overcrowded, but in fact the hospital says it's coping well. The main aim, according to the council, is to save Westside residents the forty-minute bus trip into the hospital for routine checks that don't need a specialist. The idea is to bring basic services closer to where people live."),
                K.turn("Presenter", .australian, "Booking is simple. You don't need a referral from your family doctor for most services. You can book online through the hub's website, or by phone if you prefer to talk to a person. The reception desk won't take bookings, I'm told — it's there for collecting results and general enquiries only."),
                K.turn("Presenter", .australian, "Parking was a big concern when the plans were announced, as Harbour Street gets very busy. The good news is that there's a car park at the back with thirty spaces, free for up to two hours, which should be plenty for most appointments."),
                K.turn("Presenter", .australian, "Now, let me run through when each service is available, because they're spread across the week. Eye tests will be on Wednesdays, with an optician coming in from the city practice."),
                K.turn("Presenter", .australian, "Physiotherapy was originally going to be on Fridays, but because so many people asked for a start-of-the-week session, it's been moved to Mondays."),
                K.turn("Presenter", .australian, "If you'd like advice on diet and nutrition, a dietitian will be there on Fridays. That service is particularly aimed at people managing long-term conditions, but anyone can book."),
                K.turn("Presenter", .australian, "Blood pressure checks are available on Mondays. There'll also be a self-service machine in the foyer every day, but if you want a nurse to take the reading and talk it through with you, Monday is the day."),
                K.turn("Presenter", .australian, "Hearing tests will take place on Fridays, in a specially sound-proofed room that used to be the cinema's projection booth — a nice bit of recycling there."),
                K.turn("Presenter", .australian, "And finally, vaccinations, including the seasonal flu jab, will be given on Wednesdays. The hub says that might extend to other days during the busy winter months, but for now it's Wednesday only."),
                K.turn("Presenter", .australian, "A few more details. The building has been fully adapted for people with mobility problems, with automatic doors, a lift to the first floor and wide corridors. There's a small pharmacy on the ground floor, so patients can collect prescriptions on their way out, and the waiting area includes a play corner for young children."),
                K.turn("Presenter", .australian, "The hub will be open from eight in the morning until eight in the evening on weekdays, and on Saturday mornings. On Sundays and public holidays, people should use the urgent care centre at the hospital or call the national health helpline. Local groups will also be able to use the meeting room on the first floor in the evenings, for example for parenting classes or support groups, and the organisers say they're keen to hear from anyone with ideas for other activities."),
                K.turn("Presenter", .australian, "The project has cost around four million dollars, most of it paid for by the regional health authority, and the organisers say the hub could serve as a model for similar centres in other parts of the city if it proves successful."),
                K.turn("Presenter", .australian, "So, that's the Westside Health Hub, opening Monday. We'll put all the details on our website after the programme.")
            ],
            questions: [
                K.mcq(L, 11, "What was the building used for immediately before it became empty?", ["A. a department store", "B. a cinema", "C. a car park"], "B", why: "It was first a department store, but most recently the cinema, which closed in 2015.", evidence: "remember it as the old cinema", distractor: "The department store was its original use, in the fifties."),
                K.mcq(L, 12, "What is the main reason for opening the hub?", ["A. The hospital is overcrowded.", "B. Residents will not need to travel so far for routine checks.", "C. Several local clinics have closed."], "B", why: "The council's aim is to save residents the forty-minute bus trip.", evidence: "forty-minute bus trip", distractor: "The hospital says it is 'coping well', so A is wrong."),
                K.mcq(L, 13, "How can patients book an appointment?", ["A. through their family doctor", "B. online or by phone", "C. at the reception desk"], "B", why: "Booking is online or by phone; no referral needed and reception does not take bookings.", evidence: "or by phone if you prefer"),
                K.mcq(L, 14, "What does the presenter say about parking?", ["A. There are free spaces for a limited time.", "B. Drivers will need to use Harbour Street.", "C. Parking must be paid for in advance."], "A", why: "Thirty spaces are free for up to two hours.", evidence: "free for up to two hours"),
                K.match(L, 15, .matching, "eye tests", dayOptions, "B", why: "Eye tests are on Wednesdays.", evidence: "Eye tests will be on Wednesdays", skill: "matching"),
                K.match(L, 16, .matching, "physiotherapy", dayOptions, "A", why: "Moved from Fridays to Mondays.", evidence: "moved to Mondays", distractor: "Friday was the original plan.", skill: "matching"),
                K.match(L, 17, .matching, "nutrition advice", dayOptions, "C", why: "A dietitian is there on Fridays.", evidence: "a dietitian will be there on Fridays", skill: "matching"),
                K.match(L, 18, .matching, "blood pressure checks with a nurse", dayOptions, "A", why: "Nurse-led checks are on Mondays; the machine is available daily.", evidence: "Monday is the day", skill: "matching"),
                K.match(L, 19, .matching, "hearing tests", dayOptions, "C", why: "Hearing tests are on Fridays.", evidence: "Hearing tests will take place on Fridays", skill: "matching"),
                K.match(L, 20, .matching, "vaccinations", dayOptions, "B", why: "Vaccinations are given on Wednesdays.", evidence: "Wednesday only", skill: "matching")
            ],
            keyVocabulary: ["referral", "routine check", "specialist", "physiotherapy", "dietitian", "foyer", "vaccination"]
        )

        // MARK: - Listening Part 3 (MCQ Q21–26, Flowchart Q27–30)
        let part3 = ListeningPart(
            id: "\(id)-lp3", partNumber: 3,
            title: "Planning a study on students' sleep",
            contextDescription: "Two psychology students, Leah and Marcus, plan a research project on sleep. Questions 21–26: choose A, B or C. Questions 27–30: complete the flowchart. Write ONE WORD AND/OR A NUMBER.",
            primaryAccent: .canadian,
            dialogue: [
                K.turn("Leah", .canadian, "OK, so we've got the results of the pilot survey back. What did you make of them?"),
                K.turn("Marcus", .american, "Well, I wasn't surprised that most people use their phones in bed — I think we both expected that."),
                K.turn("Leah", .canadian, "Same. And the number getting eight hours was low, but that's what every study says. The thing that really surprised me was how few replied. We emailed two hundred students and only forty filled it in."),
                K.turn("Marcus", .american, "Yeah, that was disappointing. For the main study we need a better way of recruiting people than email."),
                K.turn("Leah", .canadian, "Agreed. Now, how are we actually going to measure sleep? We said we'd consider sleep diaries."),
                K.turn("Marcus", .american, "My worry with diaries is that people simply forget to fill them in. They don't lie, exactly, but they leave a few days blank and then try to remember later."),
                K.turn("Leah", .canadian, "Fitness trackers would be more accurate, obviously, but there's no way we can afford them for thirty people. And a one-off questionnaire won't show changes from night to night."),
                K.turn("Marcus", .american, "So, a diary, then — but with something to deal with the forgetting problem."),
                K.turn("Leah", .canadian, "Let's come back to that. What about the reading? Did you look at the blue-light papers?"),
                K.turn("Marcus", .american, "I did. Everyone seems to accept that blue light from screens keeps you awake."),
                K.turn("Leah", .canadian, "That's the thing, though. When I read the actual studies, the evidence was much weaker than the news stories make out. A lot of the effect seems to come from what people are doing on their phones — messaging, games — rather than the light itself."),
                K.turn("Marcus", .american, "Interesting. We should mention that in the literature review."),
                K.turn("Leah", .canadian, "So, next steps. Before we can recruit anyone, we need approval from the ethics committee."),
                K.turn("Marcus", .american, "I'll contact them tomorrow. I've already got the form. You could start designing the diary itself."),
                K.turn("Leah", .canadian, "Fine. And for the presentation next month — we won't have full results by then, will we?"),
                K.turn("Marcus", .american, "No chance. So I think we focus mainly on our methodology, with just a slide or two on recommendations for future research."),
                K.turn("Leah", .canadian, "Good. Let's sketch out the plan, then. Step one, recruitment. Instead of email, let's put up posters in the student union. That's where people actually look."),
                K.turn("Marcus", .american, "Yes. Then the people who sign up keep a sleep diary for two weeks — that's fourteen days, which gives us both weekdays and weekends twice."),
                K.turn("Leah", .canadian, "And to deal with the forgetting issue, they get a reminder by text message every morning at eight."),
                K.turn("Marcus", .american, "Perfect. Then at the end we collect the diaries and enter everything into a spreadsheet. We don't need special statistics software for something this size."),
                K.turn("Leah", .canadian, "Should we offer participants anything for taking part? Two weeks is quite a commitment."),
                K.turn("Marcus", .american, "Maybe a voucher for the campus café. The department sometimes offers small rewards for student projects like ours."),
                K.turn("Leah", .canadian, "Good idea. And we'll need to keep everything anonymous. Each participant could have a code number instead of a name on their diary."),
                K.turn("Marcus", .american, "Yes, and we'll keep the list that links the codes to people's names separately, and delete it once the study is finished."),
                K.turn("Leah", .canadian, "We should also think about what happens if someone drops out halfway through."),
                K.turn("Marcus", .american, "We'll just record it. A few people always drop out, and it's worth reporting how many, because it tells us something about how practical the method is."),
                K.turn("Leah", .canadian, "True. And it would help anyone planning a bigger study later on, so they'd know what to expect."),
                K.turn("Marcus", .american, "Exactly. Honest reporting of what didn't work is just as useful as the results themselves, especially for a pilot project of this size."),
                K.turn("Leah", .canadian, "I agree. Let's write all of this up in a short plan so we both know exactly who is doing what before we start."),
                K.turn("Leah", .canadian, "Great. I think that's a plan.")
            ],
            questions: [
                K.mcq(L, 21, "What surprised Leah about the pilot survey?", ["A. how many students used phones in bed", "B. how few students slept for eight hours", "C. how few students responded"], "C", why: "Phone use and short sleep were expected; only forty of two hundred replied.", evidence: "how few replied"),
                K.mcq(L, 22, "What is Marcus's main concern about sleep diaries?", ["A. Participants may forget to complete them.", "B. They take too long to analyse.", "C. Participants may give false information."], "A", why: "People forget and try to remember later; he says they don't lie.", evidence: "simply forget to fill them in", distractor: "C is rejected: 'They don't lie, exactly'."),
                K.mcq(L, 23, "Why do they reject fitness trackers?", ["A. They are less accurate than diaries.", "B. They would be too expensive.", "C. They don't show night-to-night changes."], "B", why: "They can't afford trackers for thirty people.", evidence: "no way we can afford them", distractor: "C describes the questionnaire, not trackers."),
                K.mcq(L, 24, "What does Leah say about research on blue light?", ["A. It has been clearly proven.", "B. The evidence is weaker than is often believed.", "C. It does not apply to mobile phones."], "B", why: "The evidence was much weaker than news stories suggest.", evidence: "much weaker than the news stories"),
                K.mcq(L, 25, "What will Marcus do next?", ["A. contact the ethics committee", "B. design the diary", "C. book a room for the presentation"], "A", why: "He will contact the ethics committee tomorrow; Leah will design the diary.", evidence: "I'll contact them tomorrow"),
                K.mcq(L, 26, "What will their presentation mainly focus on?", ["A. their results", "B. their methodology", "C. recommendations for future research"], "B", why: "Results won't be ready; they will focus mainly on methodology.", evidence: "focus mainly on our methodology", distractor: "Recommendations get only a slide or two."),
                K.gap(L, 27, .flowchartCompletion, "Recruit participants: put up __________ in the student union", ["posters"], maxWords: 1, why: "They will put up posters instead of emailing.", evidence: "put up posters", skill: "flowchart"),
                K.gap(L, 28, .flowchartCompletion, "Participants keep a sleep diary for __________ days", ["14", "fourteen"], maxWords: 1, why: "Two weeks, which is fourteen days.", evidence: "fourteen days", skill: "flowchart"),
                K.gap(L, 29, .flowchartCompletion, "A text __________ is sent every morning", ["reminder"], maxWords: 1, why: "Participants get a reminder by text every morning.", evidence: "reminder by text message", skill: "flowchart"),
                K.gap(L, 30, .flowchartCompletion, "Collect diaries and enter data into a __________", ["spreadsheet"], maxWords: 1, why: "Data go into a spreadsheet; special software isn't needed.", evidence: "into a spreadsheet", skill: "flowchart")
            ],
            keyVocabulary: ["pilot survey", "recruit", "sleep diary", "literature review", "ethics committee", "methodology", "participant"]
        )

        // MARK: - Listening Part 4 (Note completion Q31–40)
        let part4 = ListeningPart(
            id: "\(id)-lp4", partNumber: 4,
            title: "Lecture: the history of hand hygiene in hospitals",
            contextDescription: "A lecture in a history of medicine course. Complete the notes. Write ONE WORD ONLY for each answer.",
            primaryAccent: .british,
            dialogue: [
                K.turn("Lecturer", .british, "Today we're going to look at something that seems almost too obvious to need a history: washing your hands. Yet the idea that doctors should clean their hands between patients was resisted for decades, and the story tells us a lot about how medical knowledge changes."),
                K.turn("Lecturer", .british, "Our starting point is the Vienna General Hospital in the 1840s. The hospital had two maternity clinics, where women came to give birth. A young Hungarian doctor, Ignaz Semmelweis, noticed something disturbing: many more mothers died of fever in one clinic than in the other."),
                K.turn("Lecturer", .british, "The key difference was the staff. The clinic with the higher death rate was run by doctors and medical students, while the other was staffed by midwives. The women of Vienna knew this, and some even begged to be admitted to the midwives' clinic."),
                K.turn("Lecturer", .british, "What were the doctors doing differently? Part of their training involved performing autopsies — examining the bodies of patients who had died. They frequently went straight from the autopsy room to the maternity ward, without doing anything more than wiping their hands."),
                K.turn("Lecturer", .british, "The breakthrough came after a tragedy. A colleague of Semmelweis received a cut from a student's scalpel during an autopsy, became ill and died. His symptoms closely resembled those of the mothers. Semmelweis concluded that some kind of material from the bodies was being carried on the doctors' hands."),
                K.turn("Lecturer", .british, "In 1847 he required everyone entering the ward to wash their hands in a solution of chlorinated lime. He chose it because it removed the smell from the autopsy room, which he took as a sign that it removed the harmful material too. The death rate in the doctors' clinic fell dramatically."),
                K.turn("Lecturer", .british, "You might expect him to have been celebrated. Instead, many senior doctors rejected his ideas. There was no theory of germs at the time to explain why handwashing worked. And, perhaps more importantly, accepting his conclusion meant accepting that doctors themselves were to blame for their patients' deaths — a very uncomfortable idea."),
                K.turn("Lecturer", .british, "Semmelweis didn't help his own cause. He was slow to publish his results, and when he finally did, many years later, the book was long and often angry towards his critics. He died in 1865, his work largely unrecognised."),
                K.turn("Lecturer", .british, "Recognition came with the development of germ theory later in the century. In Britain, the surgeon Joseph Lister began using carbolic acid to clean wounds and instruments, and showed that it greatly reduced infection after operations. Gradually, the idea that invisible organisms caused disease became accepted."),
                K.turn("Lecturer", .british, "Semmelweis's own story ended sadly. He returned to Hungary and worked in Budapest, but his ideas were still widely rejected during his lifetime, and he died in 1865, at the age of forty-seven. Today he is remembered as a pioneer of infection control, and a university in Budapest is named after him. Around the same period, Florence Nightingale was promoting cleanliness and fresh air in military hospitals during the Crimean War, although she approached the problem from a different direction, focusing on sanitation and careful record-keeping."),
                K.turn("Lecturer", .british, "So the lesson of this story is not simply that one man was right and everyone else was wrong. It also shows how difficult it can be to change professional habits, even when the evidence seems clear, and how important it is to communicate new findings effectively."),
                K.turn("Lecturer", .british, "Today, hand hygiene is a central part of infection control, but compliance remains a problem. Hospitals often measure how well staff follow the rules through direct observation — someone actually watches and records whether hands are cleaned at the right moments. And the main tool has changed: rather than soap and water, most hospitals now rely on alcohol-based gel, which is quicker to use and can be placed beside every bed.")
            ],
            questions: [
                K.gap(L, 31, .noteCompletion, "Vienna General Hospital had two maternity __________.", ["clinics"], maxWords: 1, why: "The hospital had two maternity clinics.", evidence: "two maternity clinics", skill: "note_completion"),
                K.gap(L, 32, .noteCompletion, "The clinic with more deaths was staffed by __________ and students.", ["doctors"], maxWords: 1, why: "It was run by doctors and medical students; the other by midwives.", evidence: "run by doctors and medical students", skill: "note_completion"),
                K.gap(L, 33, .noteCompletion, "Doctors often came directly from performing __________.", ["autopsies", "autopsy"], maxWords: 1, why: "They went straight from the autopsy room to the ward.", evidence: "performing autopsies", skill: "note_completion"),
                K.gap(L, 34, .noteCompletion, "A colleague died after receiving a __________ from a scalpel.", ["cut"], maxWords: 1, why: "He received a cut from a student's scalpel.", evidence: "received a cut", skill: "note_completion"),
                K.gap(L, 35, .noteCompletion, "1847: handwashing in a solution of chlorinated __________ became compulsory.", ["lime"], maxWords: 1, why: "A solution of chlorinated lime.", evidence: "chlorinated lime", skill: "note_completion"),
                K.gap(L, 36, .noteCompletion, "His idea implied that doctors were to __________ for deaths.", ["blame"], maxWords: 1, why: "Accepting it meant doctors were to blame.", evidence: "were to blame", skill: "note_completion"),
                K.gap(L, 37, .noteCompletion, "Semmelweis was slow to publish his __________.", ["results"], maxWords: 1, why: "He was slow to publish his results.", evidence: "slow to publish his results", skill: "note_completion"),
                K.gap(L, 38, .noteCompletion, "Lister used __________ acid to clean wounds and instruments.", ["carbolic"], maxWords: 1, why: "Lister used carbolic acid.", evidence: "carbolic acid", skill: "note_completion"),
                K.gap(L, 39, .noteCompletion, "Compliance is often measured through direct __________.", ["observation"], maxWords: 1, why: "Hospitals measure compliance through direct observation.", evidence: "direct observation", skill: "note_completion"),
                K.gap(L, 40, .noteCompletion, "Most hospitals now rely on alcohol-based __________.", ["gel", "gels"], maxWords: 1, why: "Alcohol-based gel has largely replaced soap and water.", evidence: "alcohol-based gel", skill: "note_completion")
            ],
            keyVocabulary: ["maternity", "midwife", "autopsy", "scalpel", "germ theory", "infection control", "compliance"]
        )

        // MARK: - Reading Passage 1 (Matching headings Q1–7, Short answer Q8–13)
        let headings = [
            "i. A turning point brought about by protest and fuel shortages",
            "ii. Why the benefits of cycling are hard to measure",
            "iii. Decline in the age of the motor car",
            "iv. Keeping bicycles and motor traffic apart",
            "v. An early period of popularity",
            "vi. A technology that widens cycling's appeal",
            "vii. Objections from businesses that proved largely unfounded",
            "viii. The growth of cycling among children",
            "ix. Advice for cities with few cyclists"
        ]
        let passage1 = ReadingPassage(
            id: "\(id)-rp1", passageNumber: 1,
            title: "The Bicycle and the City",
            discipline: "Urban Planning & Transport History",
            paragraphs: [
                "In the closing decades of the nineteenth century, the bicycle was one of the most important inventions of its age. The so-called 'safety bicycle', with two wheels of equal size and a chain driving the rear wheel, appeared in the 1880s and quickly replaced the dangerous high-wheeled machines that had come before it. Within a generation, mass production had brought the price down to a level that ordinary workers could afford. For millions of people, the bicycle offered a new kind of freedom: the ability to travel several kilometres to work, to visit relatives in neighbouring villages, or simply to explore the countryside at weekends. In many European cities in the early twentieth century, bicycles outnumbered every other form of private transport.",
                "This golden age did not last. After the Second World War, rising incomes put the private car within reach of a growing proportion of households, and planners in many countries began to reshape cities around it. Wide roads were driven through historic centres, tram lines were removed, and parking spaces replaced squares and gardens. Cycling came to be seen as old-fashioned, something people did only if they could not afford anything better. As traffic grew heavier and faster, it also became more dangerous, and the number of journeys made by bicycle fell steeply in almost every industrialised country.",
                "The Netherlands, now often held up as a model cycling nation, went through the same decline. What changed its direction was a combination of events in the early 1970s. The number of road deaths, including many children, had risen sharply, and a protest movement demanded safer streets. Then, in 1973, an oil crisis caused fuel prices to rise suddenly, and the government introduced car-free Sundays to reduce consumption. For a few weeks, people saw what their towns looked like without traffic, and many found that they liked it. These experiences helped to build political support for a different approach to transport planning, which gradually became national policy.",
                "The approach that emerged was based on a simple principle: people will cycle in large numbers only if they feel safe, and most people do not feel safe sharing a busy road with fast vehicles. On main roads, Dutch planners therefore began to build cycle tracks physically separated from traffic, usually by a raised kerb or a strip of grass. Junctions were redesigned so that cyclists and drivers could see each other clearly, and residential streets were turned into zones where cars could pass only at walking pace. Painted lines on the road surface, which offer little real protection, came to be regarded as inadequate on busy routes.",
                "Such changes were not always welcomed. In many towns, shopkeepers objected strongly to plans to remove parking spaces or narrow roads, fearing that customers would go elsewhere. Their concern was understandable, but studies carried out in a number of cities have suggested that it was often misplaced. When asked, shopkeepers consistently overestimated how many of their customers arrived by car. Moreover, although people on bicycles tend to spend less per visit, they visit more frequently, so that over a month their total spending is often similar to or higher than that of drivers. In several cases, streets that were closed to through traffic became more popular with shoppers, not less.",
                "In recent years, the electric bicycle has changed the picture again. By providing assistance whenever the rider pedals, an e-bike reduces the effort needed to climb slopes, carry shopping or travel long distances. This has made cycling practical in cities where steep hills were previously a serious obstacle, and it has attracted many people who would not otherwise have considered cycling, including older riders and commuters who live far from their workplaces. Sales have risen rapidly across Europe, although the higher cost of e-bikes and the risk of theft remain barriers for some potential users.",
                "For cities where cycling is still rare, the Dutch experience offers both encouragement and a warning. It shows that decline can be reversed, but also that the process takes decades and depends on sustained political commitment. Some cities have begun by installing temporary lanes, marked with paint and plastic posts, to test routes before investing in permanent construction. This can be a useful first step, provided that the lanes are later upgraded. Above all, the evidence suggests that what matters most is continuity. A few isolated stretches of excellent cycle track achieve little if riders must rejoin heavy traffic at every junction; a connected network, even a modest one, is worth far more than a collection of impressive fragments."
            ],
            questions: [
                K.match(R, 1, .matchingHeadings, "Paragraph A", headings, "v", why: "Paragraph A describes the bicycle's spread and popularity around 1900.", evidence: "bicycles outnumbered every other form", skill: "matching_headings"),
                K.match(R, 2, .matchingHeadings, "Paragraph B", headings, "iii", why: "Paragraph B explains how cars led to a steep fall in cycling.", evidence: "fell steeply", skill: "matching_headings"),
                K.match(R, 3, .matchingHeadings, "Paragraph C", headings, "i", why: "Protests over road deaths and the 1973 oil crisis changed Dutch policy.", evidence: "oil crisis", skill: "matching_headings"),
                K.match(R, 4, .matchingHeadings, "Paragraph D", headings, "iv", why: "Cycle tracks physically separated from traffic.", evidence: "physically separated from traffic", skill: "matching_headings"),
                K.match(R, 5, .matchingHeadings, "Paragraph E", headings, "vii", why: "Shopkeepers' fears were 'often misplaced'.", evidence: "often misplaced", distractor: "Spending is measured here, but heading ii (benefits hard to measure) is not the main idea.", skill: "matching_headings"),
                K.match(R, 6, .matchingHeadings, "Paragraph F", headings, "vi", why: "E-bikes attract people who would not otherwise cycle.", evidence: "electric bicycle", skill: "matching_headings"),
                K.match(R, 7, .matchingHeadings, "Paragraph G", headings, "ix", why: "Lessons for cities where cycling is still rare.", evidence: "cycling is still rare", skill: "matching_headings"),
                K.gap(R, 8, .shortAnswer, "What did the Dutch government introduce in 1973 to reduce fuel use?", ["car-free Sundays", "car free Sundays"], maxWords: 3, why: "Paragraph C: the government introduced car-free Sundays.", evidence: "car-free Sundays", skill: "short_answer"),
                K.gap(R, 9, .shortAnswer, "Apart from a strip of grass, what usually separates Dutch cycle tracks from traffic?", ["raised kerb", "a raised kerb", "kerb", "raised curb", "curb"], maxWords: 3, why: "Paragraph D: usually by a raised kerb or a strip of grass.", evidence: "raised kerb", skill: "short_answer"),
                K.gap(R, 10, .shortAnswer, "Which feature of some cities do e-bikes make much less of an obstacle?", ["hills", "steep hills"], maxWords: 2, why: "Paragraph F: cycling is now practical where steep hills were an obstacle.", evidence: "steep hills", skill: "short_answer"),
                K.gap(R, 11, .shortAnswer, "Which way of arriving did shopkeepers overestimate among their customers?", ["by car", "car", "cars"], maxWords: 2, why: "Paragraph E: shopkeepers overestimated how many customers arrived by car.", evidence: "arrived by car", skill: "short_answer"),
                K.gap(R, 12, .shortAnswer, "What do some cities install first to test cycle routes?", ["temporary lanes"], maxWords: 2, why: "Paragraph G: temporary lanes marked with paint and plastic posts.", evidence: "temporary lanes", skill: "short_answer"),
                K.gap(R, 13, .shortAnswer, "According to the final paragraph, what quality of a cycle network matters most?", ["continuity"], maxWords: 2, why: "Paragraph G: what matters most is continuity.", evidence: "what matters most is continuity", skill: "short_answer")
            ]
        )

        // MARK: - Reading Passage 2 (Sentence endings Q14–18, TFNG Q19–23, Flowchart Q24–26)
        let endings = [
            "A. because calls arrive in random clusters.",
            "B. because no spare time remains to clear sudden backlogs.",
            "C. because it is seen as fairer.",
            "D. because occupied time seems to pass more quickly.",
            "E. because anxiety affects how time is experienced.",
            "F. because it reduces the total time people spend waiting.",
            "G. because a reason for the delay has been given."
        ]
        let passage2 = ReadingPassage(
            id: "\(id)-rp2", passageNumber: 2,
            title: "Why Waiting Feels Longer Than It Is",
            discipline: "Operations Research & Psychology",
            paragraphs: [
                "Most people in developed countries spend a surprising amount of their lives waiting in line: at supermarket checkouts, in traffic, on the telephone to customer services. It is an experience almost universally disliked, and organisations that make customers wait too long risk losing them. Yet the study of queues has a long history, and it has produced two quite different kinds of insight. One is mathematical, concerned with how long people actually wait. The other is psychological, concerned with how long the wait feels.",
                "The mathematical study of queues began in the early twentieth century with the work of Agner Krarup Erlang, a Danish engineer employed by the Copenhagen telephone company. Erlang wanted to know how many lines and operators an exchange needed in order to handle calls without keeping callers waiting too often. His key insight was that calls arrive randomly, and that even if an exchange has enough capacity on average, random clusters of calls will still create queues. The models he developed are still in use today, not only in telecommunications but also in planning hospital emergency departments, call centres and computer networks.",
                "One of the most counter-intuitive results of queuing theory concerns the way waiting time responds to how busy a system is. When a service operates well below its capacity, small increases in demand make little difference to waiting times. As it approaches full capacity, however, waiting times increase dramatically, because there is no spare time in which to clear the queues created by random bursts of arrivals. A checkout that is busy eighty per cent of the time may have short queues, while one that is busy ninety-five per cent of the time may have very long ones. For managers, this means that running a service at close to full capacity, which may appear efficient, can be a recipe for long delays.",
                "Theory also offers guidance on how queues should be organised. Many shops and banks have replaced separate lines in front of each counter with a single 'serpentine' queue that feeds all of them. Mathematically, a single queue reduces the variation in waiting times, because no customer can be trapped behind someone with an unusually slow transaction while other lines move freely. Customers appear to prefer it too, but for a different reason: a single line is seen as fairer, since people are served strictly in the order in which they arrived.",
                "Fairness is just one of several factors that shape how a wait is experienced. In an influential essay published in the 1980s, the business researcher David Maister argued that the psychology of waiting matters as much as its length. Among his observations was that unoccupied time feels longer than occupied time, which is why mirrors are often placed beside lifts and why waiting rooms provide magazines. Uncertain waits feel longer than known, finite waits, and unexplained waits feel longer than those for which a reason is given. Anxiety, too, makes time pass more slowly, so that a patient waiting for test results may experience twenty minutes very differently from a customer waiting for coffee.",
                "A frequently told story illustrates how these ideas can be applied. An airport received many complaints from passengers about the time they spent waiting for their luggage. The airport increased the number of baggage handlers, reducing the average wait considerably, yet the complaints continued. Investigation revealed that passengers walked only a short distance from their plane to the baggage hall and then stood by the belt for most of the waiting time. The airport's solution was to move arrival gates further from the baggage hall, so that passengers spent most of the time walking rather than standing. The total time was much the same, but complaints fell almost to zero.",
                "Technology has created new ways of managing the experience of waiting. Many restaurants and clinics now allow customers to join a 'virtual queue' using their phones, receiving a message when it is their turn, so that they can wait wherever they like. Online services display progress bars and estimated waiting times, which reduce uncertainty even when they are not entirely accurate. Some researchers warn, however, that such techniques can be used to make people tolerate poor service rather than to improve it. Making a wait feel shorter is valuable, they argue, but it should not become a substitute for reducing the wait itself."
            ],
            questions: [
                K.match(R, 14, .matchingSentenceEndings, "Erlang realised that queues form even when capacity is sufficient on average", endings, "A", why: "Paragraph B: calls arrive randomly, and random clusters create queues.", evidence: "random clusters of calls", skill: "sentence_endings"),
                K.match(R, 15, .matchingSentenceEndings, "Waiting times rise sharply as a service nears full capacity", endings, "B", why: "Paragraph C: there is no spare time to clear queues from random bursts.", evidence: "no spare time in which to clear", skill: "sentence_endings"),
                K.match(R, 16, .matchingSentenceEndings, "Customers tend to prefer a single serpentine queue", endings, "C", why: "Paragraph D: customers prefer it because it is seen as fairer.", evidence: "seen as fairer", distractor: "F: the passage says it reduces variation, not total waiting time.", skill: "sentence_endings"),
                K.match(R, 17, .matchingSentenceEndings, "Mirrors are often placed beside lifts", endings, "D", why: "Paragraph E: unoccupied time feels longer than occupied time.", evidence: "unoccupied time feels longer", skill: "sentence_endings"),
                K.match(R, 18, .matchingSentenceEndings, "A patient waiting for test results may find twenty minutes feels long", endings, "E", why: "Paragraph E: anxiety makes time pass more slowly.", evidence: "Anxiety, too, makes time pass more slowly", skill: "sentence_endings"),
                K.tfng(R, 19, "Erlang was employed by a telephone company in Copenhagen.", "TRUE", why: "Paragraph B: a Danish engineer employed by the Copenhagen telephone company.", evidence: "Copenhagen telephone company"),
                K.tfng(R, 20, "A service that is busy 80% of the time will always have longer queues than one busy 95% of the time.", "FALSE", why: "Paragraph C says the reverse: the 95% checkout may have very long queues.", evidence: "ninety-five per cent"),
                K.tfng(R, 21, "Single serpentine queues were first introduced by banks.", "NOT GIVEN", why: "Paragraph D mentions shops and banks using them, but not who introduced them first.", evidence: "Many shops and banks"),
                K.tfng(R, 22, "Maister based his essay on interviews with customers.", "NOT GIVEN", why: "Paragraph E reports Maister's observations but not how he gathered them.", evidence: "David Maister"),
                K.tfng(R, 23, "After the airport hired more baggage handlers, passengers stopped complaining.", "FALSE", why: "Paragraph F: the wait fell, yet the complaints continued.", evidence: "yet the complaints continued"),
                K.gap(R, 24, .flowchartCompletion, "Problem: passengers complain about waiting for their __________", ["luggage", "baggage"], maxWords: 1, why: "Paragraph F: complaints about waiting for their luggage.", evidence: "waiting for their luggage", skill: "flowchart"),
                K.gap(R, 25, .flowchartCompletion, "First response: more baggage __________ employed → complaints continue", ["handlers"], maxWords: 1, why: "Paragraph F: the airport increased the number of baggage handlers.", evidence: "baggage handlers", skill: "flowchart"),
                K.gap(R, 26, .flowchartCompletion, "Second response: gates moved so passengers spend the time __________ → complaints almost stop", ["walking"], maxWords: 1, why: "Paragraph F: passengers spent most of the time walking rather than standing.", evidence: "walking rather than standing", skill: "flowchart")
            ]
        )

        // MARK: - Reading Passage 3 (MCQ Q27–30, Matching features Q31–35, Summary Q36–40)
        let people = [
            "A. Warren Weaver",
            "B. the Georgetown–IBM team",
            "C. Yehoshua Bar-Hillel",
            "D. the ALPAC committee",
            "E. IBM researchers in the late 1980s"
        ]
        let passage3 = ReadingPassage(
            id: "\(id)-rp3", passageNumber: 3,
            title: "Machines That Translate",
            discipline: "Computational Linguistics",
            paragraphs: [
                "For most of human history, translating between languages has been a slow, skilled and expensive craft. It is not surprising, then, that the idea of a machine able to translate automatically appeared almost as soon as electronic computers were invented. In 1949 the American mathematician Warren Weaver circulated a memorandum suggesting that translation might be treated as a problem of code-breaking: a text in Russian, he proposed, could be regarded as English that had been written in a strange code, which a machine might learn to decipher. The idea attracted funding and enthusiasm, particularly in the United States, where there was strong government interest in reading Soviet scientific publications.",
                "In 1954 a public demonstration organised by Georgetown University and IBM appeared to justify that enthusiasm. A computer translated more than sixty Russian sentences into English, and newspapers reported that fully automatic translation might be only a few years away. What the reports did not emphasise was how limited the demonstration was. The system had a vocabulary of about 250 words and just six grammatical rules, and the sentences had been carefully selected to avoid the kinds of difficulty that real texts contain.",
                "Those difficulties soon became apparent. Languages do not map neatly onto one another word for word: a single word may have several meanings, and the correct choice often depends on knowledge of the world rather than on grammar. The Israeli philosopher Yehoshua Bar-Hillel, who had himself worked on machine translation, illustrated the problem with a famous example. In the sentence 'The box was in the pen', a human reader immediately understands 'pen' as an enclosure, such as one for a small child, rather than a writing instrument, because a box could not fit inside a writing pen. A machine, Bar-Hillel argued, could make this choice reliably only if it possessed something like a complete understanding of the world, and he concluded that fully automatic, high-quality translation was not a realistic goal.",
                "Official patience was also running out. In 1966 a committee appointed by the US government, known as ALPAC, published a report concluding that machine translation was slower, less accurate and more expensive than human translation, and that there was no immediate prospect of useful results. It recommended that funding be reduced and redirected towards basic research in computational linguistics. Government investment in the field fell sharply, and for two decades work continued mainly on a smaller scale, often on systems designed for narrow purposes such as translating weather forecasts, in which vocabulary and sentence structure are highly predictable.",
                "The approach that revived the field was radically different from the rule-based systems that had gone before. Instead of trying to write down the grammar of each language, researchers at IBM in the late 1980s began to use large collections of texts that had already been translated by humans; in their case, records of debates in the Canadian parliament, which are published in both English and French. By analysing millions of sentence pairs, a computer could calculate the probability that a given word or phrase in one language corresponded to one in the other. These statistical systems made many errors, but they improved steadily as more data became available, and they required far less detailed linguistic knowledge to build.",
                "Since the mid-2010s, statistical methods have themselves largely been replaced by neural networks, which process whole sentences rather than individual phrases and produce translations that are noticeably more fluent. Free online translation services are now used by hundreds of millions of people, and for many everyday purposes, such as understanding the gist of a news article, reading a menu or exchanging simple messages, they are remarkably effective. Professional translators increasingly use machine output as a first draft, which they then correct and improve, a practice known as post-editing.",
                "Yet the problem that Bar-Hillel identified has not disappeared; it has merely become less visible. Neural systems do not understand texts in any human sense. They are very good at producing sentences that sound natural, and this very fluency can conceal mistakes, since a reader has no obvious signal that something has gone wrong. Errors are most likely in texts that depend heavily on context, culture or specialist knowledge, such as legal contracts, medical instructions and literature. Systems also perform much better for languages with large amounts of translated text available than for the thousands of languages with relatively little. For the foreseeable future, it seems, the most reliable translations will continue to involve a human who understands both languages and the purpose of the text."
            ],
            questions: [
                K.mcq(R, 27, "What was the main idea of Weaver's 1949 memorandum?", ["A. to describe a translation machine that had already been built", "B. to criticise the quality of human translators", "C. to propose that translation could be approached like code-breaking", "D. to ask for funding to teach Russian to scientists"], "C", why: "Paragraph A: translation might be treated as a problem of code-breaking.", evidence: "problem of code-breaking", skill: "detail"),
                K.mcq(R, 28, "What does the writer suggest about the 1954 demonstration?", ["A. Press reports gave a misleading impression of its significance.", "B. It translated a wide range of real scientific texts.", "C. It proved that Weaver's ideas were mistaken.", "D. It attracted little public attention."], "A", why: "Paragraph B: reports did not emphasise how limited it was; sentences were carefully selected.", evidence: "did not emphasise was how limited", distractor: "B is contradicted: the sentences were carefully selected, not real texts.", skill: "inference"),
                K.mcq(R, 29, "What does Bar-Hillel's 'box in the pen' example show?", ["A. Grammar rules are always ambiguous.", "B. Machines handle nouns worse than verbs.", "C. Dictionaries give too few meanings for each word.", "D. Choosing the right meaning can depend on knowledge of the world."], "D", why: "Paragraph C: the correct choice depends on knowledge of the world rather than on grammar.", evidence: "knowledge of the world rather than on grammar", skill: "inference"),
                K.mcq(R, 30, "What was true of the statistical systems developed at IBM?", ["A. They depended on detailed grammatical rules.", "B. They became more accurate as more translated text became available.", "C. They made very few errors from the start.", "D. They could only be used for weather forecasts."], "B", why: "Paragraph E: they improved steadily as more data became available.", evidence: "improved steadily as more data became available", distractor: "D refers to the narrow systems of paragraph D.", skill: "detail"),
                K.match(R, 31, .matchingFeatures, "argued that a key problem could not be solved without a full understanding of the world", people, "C", why: "Paragraph C: Bar-Hillel said a machine would need something like a complete understanding of the world.", evidence: "complete understanding of the world", skill: "matching_features"),
                K.match(R, 32, .matchingFeatures, "compared a foreign-language text to a message written in code", people, "A", why: "Paragraph A: Weaver suggested Russian could be regarded as English in a strange code.", evidence: "written in a strange code", skill: "matching_features"),
                K.match(R, 33, .matchingFeatures, "presented a system that handled a small number of carefully chosen sentences", people, "B", why: "Paragraph B: about sixty selected sentences, 250 words, six rules.", evidence: "carefully selected", skill: "matching_features"),
                K.match(R, 34, .matchingFeatures, "recommended that money be moved into more basic research", people, "D", why: "Paragraph D: ALPAC recommended reducing funding and redirecting it to computational linguistics.", evidence: "redirected towards basic research", skill: "matching_features"),
                K.match(R, 35, .matchingFeatures, "made use of existing human translations of parliamentary records", people, "E", why: "Paragraph E: IBM researchers used Canadian parliamentary debates in English and French.", evidence: "Canadian parliament", skill: "matching_features"),
                K.gap(R, 36, .summaryCompletion, "Neural networks produce translations that are more __________ than those of earlier systems.", ["fluent"], maxWords: 1, why: "Paragraph F: noticeably more fluent.", evidence: "noticeably more fluent", skill: "summary_completion"),
                K.gap(R, 37, .summaryCompletion, "Professional translators correct machine drafts, a practice called __________.", ["post-editing", "post editing", "postediting"], maxWords: 2, why: "Paragraph F: a practice known as post-editing.", evidence: "post-editing", skill: "summary_completion"),
                K.gap(R, 38, .summaryCompletion, "Because the output sounds natural, __________ may go unnoticed.", ["mistakes"], maxWords: 1, why: "Paragraph G: fluency can conceal mistakes.", evidence: "conceal mistakes", skill: "summary_completion"),
                K.gap(R, 39, .summaryCompletion, "Problems are most common in texts that need context, cultural awareness or __________ knowledge.", ["specialist"], maxWords: 1, why: "Paragraph G: context, culture or specialist knowledge.", evidence: "specialist knowledge", skill: "summary_completion"),
                K.gap(R, 40, .summaryCompletion, "Systems are weaker for languages with relatively little translated __________ available.", ["text"], maxWords: 1, why: "Paragraph G: languages with large amounts of translated text perform better.", evidence: "translated text available", skill: "summary_completion")
            ]
        )

        // MARK: - Writing
        let years = ["2000", "2005", "2010", "2015", "2020"]
        let shares: [(String, [Double])] = [
            ("Northport", [8, 10, 14, 19, 22]),
            ("Eastvale", [25, 26, 28, 31, 33]),
            ("Southbridge", [3, 3, 4, 5, 6])
        ]
        let task1 = WritingTask1Prompt(
            id: "\(id)-wt1",
            title: "Share of commuters cycling to work in three cities, 2000–2020",
            visualType: .lineChart,
            instructions: "The line graph shows the percentage of commuters who cycled to work in three cities between 2000 and 2020. Summarise the information by selecting and reporting the main features, and make comparisons where relevant. Write at least 150 words.",
            minimumWords: 150,
            dataPoints: shares.flatMap { city, values in
                zip(years, values).map { VisualDataPoint(series: city, category: $0.0, value: $0.1, unit: "%") }
            },
            keyOverviewPoints: [
                "Cycling rose in all three cities over the period.",
                "Eastvale had the highest share throughout (25% → 33%).",
                "Northport saw the largest increase, almost tripling from 8% to 22%; Southbridge stayed very low (3% → 6%)."
            ]
        )
        let task2 = WritingTask2Prompt(
            id: "\(id)-wt2",
            title: "Machine translation and language learning",
            essayType: .opinion,
            topicDomain: "Technology & Education",
            promptText: "Some people say that, because translation software is now widely available, learning a foreign language is no longer necessary. To what extent do you agree or disagree?",
            minimumWords: 250
        )

        // MARK: - Speaking
        let speaking = SpeakingPromptSet(
            id: "\(id)-spk",
            theme: "Time, patience and technology",
            part1Questions: [
                "Do you usually arrive early, on time, or late for appointments?",
                "What do you do while you are waiting for something, for example a bus?",
                "Which app or device do you use most in a typical day?",
                "Has technology made your daily routine easier or more complicated?"
            ],
            part2CueCard: SpeakingCueCard(
                topic: "Describe a time when you had to wait a long time for something important.",
                bulletPoints: ["what you were waiting for", "how long you waited", "what you did while you were waiting", "and explain how you felt about the wait"],
                prepSeconds: 60, speakSeconds: 120
            ),
            part3Questions: [
                "Why do you think people today seem to be less patient than in the past?",
                "Should public services such as hospitals be judged mainly on waiting times? Why or why not?",
                "How might technology change the way people queue or wait in the future?",
                "Is patience a skill that can be taught? How?"
            ]
        )

        return MockExam(
            id: id, examNumber: 2,
            title: "Mock Exam 2: Health, Cities & Technology",
            difficulty: .target,
            theme: "Health, Cities & Technology",
            listeningParts: [part1, part2, part3, part4],
            readingPassages: [passage1, passage2, passage3],
            writingTask1: task1, writingTask2: task2, speakingSet: speaking,
            provenance: K.provenance([
                "Historical figures in Listening Part 4 (Semmelweis, Lister) and Reading Passages 2–3 (Erlang, Maister, Weaver, Bar-Hillel, ALPAC) are real; accounts are simplified for practice and should not be cited as a reference.",
                "Cities in Writing Task 1 are fictional and the data are invented for practice."
            ])
        )
    }()
}
