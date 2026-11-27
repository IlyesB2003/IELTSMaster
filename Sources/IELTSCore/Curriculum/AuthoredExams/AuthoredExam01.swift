import Foundation

// Authored Mock Exam 1 — "Land, Food & Environment"
// Every script, passage and question in this file is written for this exam only.

extension AuthoredExams {
    static let exam01: MockExam = {
        let id = "authored-01"
        let L = "\(id)-L"
        let R = "\(id)-R"
        typealias K = AuthorKit

        // MARK: - Listening Part 1 (Form completion, Q1–10)
        let part1 = ListeningPart(
            id: "\(id)-lp1", partNumber: 1,
            title: "Renting an allotment plot",
            contextDescription: "A man phones the council allotments office to register for a garden plot. Complete the form. Write ONE WORD AND/OR A NUMBER for each answer.",
            primaryAccent: .british,
            dialogue: [
                K.turn("Officer", .british, "Good morning, Westbrook Council allotments office, Helen speaking. How can I help?"),
                K.turn("Daniel", .australian, "Hi. I'm calling about renting a plot. I saw a notice saying a few had become free."),
                K.turn("Officer", .british, "That's right, we've had several come up at the Mill Lane site. Can I take some details and put you on the list?"),
                K.turn("Daniel", .australian, "Sure."),
                K.turn("Officer", .british, "Your surname first, please."),
                K.turn("Daniel", .australian, "It's Ferraro. F-E-double R-A-R-O."),
                K.turn("Officer", .british, "Thank you. And your first name?"),
                K.turn("Daniel", .australian, "Daniel."),
                K.turn("Officer", .british, "And your address?"),
                K.turn("Daniel", .australian, "Forty-two Cotton Street — oh, sorry, no. I moved last month. It's seventeen Kestrel Road. K-E-S-T-R-E-L."),
                K.turn("Officer", .british, "Seventeen Kestrel Road. Lovely. Now, plots come in three sizes. A full plot is about two hundred and fifty square metres, a half plot is a hundred and twenty-five, and we also have small starter beds of around thirty square metres for complete beginners."),
                K.turn("Daniel", .australian, "I've only grown herbs on a balcony, so a full one sounds like too much. But a starter bed seems a bit small for what I have in mind. I'll go for a half plot."),
                K.turn("Officer", .british, "A half plot, then. The annual rent for that is forty-eight pounds. It was forty until April, but the council put it up this year."),
                K.turn("Daniel", .australian, "That's fine. Does that include water?"),
                K.turn("Officer", .british, "Water is included, yes — there's a tap at the end of every path. What isn't included is the deposit for the key to the main gate. That's fifteen pounds, and you get it back when you give up the plot."),
                K.turn("Daniel", .australian, "Fifteen. OK."),
                K.turn("Officer", .british, "Could I ask where you heard about the scheme? We're trying to find out which kind of advertising actually works."),
                K.turn("Daniel", .australian, "My neighbour mentioned it once, but what made me ring was the notice I saw in the library."),
                K.turn("Officer", .british, "I'll put the library down. Now, there are a few rules I have to go through. You can't put up any structure taller than two metres without permission — sheds, greenhouses and so on. And bonfires are only allowed in November. People used to light them all through the autumn and we had a lot of complaints."),
                K.turn("Daniel", .australian, "Right. What about animals? I'd like to keep a few chickens eventually."),
                K.turn("Officer", .british, "Chickens are fine, up to six, but no cockerels, and there's a separate form for that. Bees are allowed if you have a beekeeping certificate."),
                K.turn("Daniel", .australian, "Good to know."),
                K.turn("Officer", .british, "We also have a tool-share shed on site. Membership is free, but you have to attend a short safety session first. The next one is on Saturday the fourteenth."),
                K.turn("Daniel", .australian, "Morning or afternoon?"),
                K.turn("Officer", .british, "Ten until eleven in the morning, at the site hut. You'll need to bring sturdy boots. Gloves are provided, so don't worry about those."),
                K.turn("Daniel", .australian, "Boots, fine. And how long is the wait at the moment?"),
                K.turn("Officer", .british, "For a half plot, about three weeks. When one is ready, we'll send you the offer with the plot number and a map of the site. We used to post offer letters, but now everything goes by email, so could I take your address?"),
                K.turn("Daniel", .australian, "Of course. It's d-ferraro, all lower case, at mailbox dot com."),
                K.turn("Daniel", .australian, "Just one more question. Is there anywhere on the site to keep things? I live in a flat, so there's no room at home for a wheelbarrow and all the rest."),
                K.turn("Officer", .british, "There's a shared store near the gate, and many plot holders also put up a small shed on their own plot. If you want to build one, check the size rules in the handbook first, because sheds mustn't be too tall or shade your neighbour's plot."),
                K.turn("Daniel", .australian, "That makes sense. And is there water on site?"),
                K.turn("Officer", .british, "Yes, there are taps at the end of each path. We ask people to use watering cans rather than leaving hoses running, especially in summer, and a lot of plot holders collect rainwater as well."),
                K.turn("Daniel", .australian, "Great, I'll keep that in mind."),
                K.turn("Officer", .british, "Perfect. You should hear from us soon, Mr Ferraro.")
            ],
            questions: [
                K.gap(L, 1, .formCompletion, "Surname: __________", ["Ferraro"], maxWords: 1, why: "Daniel spells his surname: F-E-double R-A-R-O.", evidence: "It's Ferraro", skill: "spelling"),
                K.gap(L, 2, .formCompletion, "Address: 17 __________ Road", ["Kestrel"], maxWords: 1, why: "He corrects himself: he moved from Cotton Street to 17 Kestrel Road.", evidence: "seventeen Kestrel Road", skill: "distractor_correction"),
                K.gap(L, 3, .formCompletion, "Plot size requested: __________ plot", ["half"], maxWords: 1, why: "A full plot is too much and a starter bed too small, so he chooses a half plot.", evidence: "I'll go for a half plot", skill: "detail"),
                K.gap(L, 4, .formCompletion, "Annual rent: £__________", ["48", "forty-eight", "48.00"], maxWords: 1, why: "The rent is now £48; £40 was the old price before April.", evidence: "forty-eight pounds", skill: "numbers"),
                K.gap(L, 5, .formCompletion, "Gate key deposit: £__________ (refundable)", ["15", "fifteen", "15.00"], maxWords: 1, why: "The key deposit is fifteen pounds, returned when the plot is given up.", evidence: "That's fifteen pounds", skill: "numbers"),
                K.gap(L, 6, .formCompletion, "Heard about scheme from: notice in the __________", ["library"], maxWords: 1, why: "The neighbour is a distractor; the notice he acted on was in the library.", evidence: "notice I saw in the library", skill: "distractor_correction"),
                K.gap(L, 7, .formCompletion, "Bonfires permitted only in: __________", ["November", "Nov"], maxWords: 1, why: "Bonfires are only allowed in November.", evidence: "only allowed in November", skill: "detail"),
                K.gap(L, 8, .formCompletion, "Tool-share safety session: Saturday __________", ["14", "14th", "the 14th", "fourteenth", "the fourteenth"], maxWords: 2, why: "The next safety session is on Saturday the fourteenth.", evidence: "Saturday the fourteenth", skill: "dates"),
                K.gap(L, 9, .formCompletion, "Must bring: sturdy __________", ["boots"], maxWords: 1, why: "Boots must be brought; gloves are provided (distractor).", evidence: "bring sturdy boots", skill: "distractor_correction"),
                K.gap(L, 10, .formCompletion, "Plot offer will be sent by: __________", ["email", "e-mail"], maxWords: 1, why: "Offers used to be posted, but now they are sent by email.", evidence: "everything goes by email", skill: "distractor_correction")
            ],
            keyVocabulary: ["allotment", "plot", "annual rent", "deposit", "refundable", "structure", "certificate", "tool-share"]
        )

        // MARK: - Listening Part 2 (MCQ Q11–15, Matching Q16–20)
        let featureOptions = [
            "A. a working model",
            "B. a dressing-up area for children",
            "C. original hand tools",
            "D. a café",
            "E. a short film about the mill",
            "F. a viewing platform",
            "G. temporary art exhibitions"
        ]
        let part2 = ListeningPart(
            id: "\(id)-lp2", partNumber: 2,
            title: "A guided visit to Hartley Mill",
            contextDescription: "A guide welcomes visitors to a restored cotton mill. Questions 11–15: choose the correct letter, A, B or C. Questions 16–20: which feature can visitors find at each location? Choose from A–G.",
            primaryAccent: .british,
            dialogue: [
                K.turn("Guide", .british, "Good morning, everyone, and welcome to Hartley Mill. My name's Graham and I'll be showing you round today. Before we go in, I'd like to give you a bit of background and explain what you'll find on the site."),
                K.turn("Guide", .british, "The mill was built in 1793 to spin cotton. Visitors often assume the owners chose this spot because the land was cheap, or because it was close to the coast for exporting cloth. In fact, land in the valley was rather expensive, and the nearest port was a long day's journey away. What decided it was the river itself: as it drops through the gorge just above us it flows very fast, and that gave the mill a powerful, dependable source of energy."),
                K.turn("Guide", .british, "In the 1840s a steam engine was installed. You might expect that this led to a huge increase in the workforce, but numbers stayed much the same. The real advantage was that the mill no longer had to stop work during dry summers, when the river ran low and the water wheel could barely turn."),
                K.turn("Guide", .british, "The mill finally closed in 1962 and stood empty for many years. Restoration was carried out mainly by volunteers. We did receive a small grant from the county council, and a couple of local building firms donated materials, but the bulk of the money — around two-thirds of it — came from a national lottery heritage grant. Without that, I doubt we'd be standing here."),
                K.turn("Guide", .british, "A few practical points. You're welcome to take photographs anywhere on the site except in the engine room. That's not because of copyright or anything like that — the engine is running today and we need people to keep their attention on where they're walking. No special permission is needed anywhere else."),
                K.turn("Guide", .british, "Some of you have asked what's new. The riverside picnic area opened last year, and the gift shop has been here since we reopened. What's new this season is our evening tours, which run every Friday from June to September, when you can see the mill lit as it would have been by gas lamps."),
                K.turn("Guide", .british, "Now, let me tell you what you'll find in each building. Starting on your left, the Weaver's Cottage has been furnished as it would have been in the 1850s. Children particularly enjoy it, because there's a corner where they can try on the clothes that mill families wore."),
                K.turn("Guide", .british, "Next to it is the Lock Keeper's House. People sometimes expect more exhibits there, but it's actually where you'll find our café, which serves lunches made with local produce."),
                K.turn("Guide", .british, "In the Engine Room, as I mentioned, the steam engine is running today. Beside it there's a working model that shows how power was carried by belts and shafts to every floor of the mill — it's the clearest way to understand the system."),
                K.turn("Guide", .british, "The Old Granary used to host our temporary exhibitions, but those have moved. Instead, if you climb to the top floor you'll reach a viewing platform we built last spring, which gives you a wonderful view along the whole valley."),
                K.turn("Guide", .british, "Finally, down by the water, the Boathouse is now where local artists show their work. The displays change every six weeks, so there's usually something different if you come back. And if you'd like to see the short film about the mill's history, that's shown in the visitor centre at the entrance, so you can catch it on the way out. Right, let's begin."),
                K.turn("Guide", .british, "Oh, and before we set off, just a couple of practical points. Please keep to the marked paths, because some of the ground near the river can be slippery after rain. The toilets are in the visitor centre, and there are benches along the route if anyone needs a rest. The whole walk takes about an hour, and I'll stop at each building to explain what you're looking at. If you have any questions, please just ask as we go along.")
            ],
            questions: [
                K.mcq(L, 11, "Why was the mill built on this site?", ["A. The land was inexpensive.", "B. The river flowed quickly.", "C. It was close to a port."], "B", why: "Cheap land and a nearby port are both rejected; the fast river was the deciding factor.", evidence: "flows very fast", distractor: "Land was 'rather expensive' and the port was 'a long day's journey away'."),
                K.mcq(L, 12, "What was the main benefit of installing the steam engine?", ["A. The mill could employ far more workers.", "B. Work could continue in dry summers.", "C. The river no longer needed to be managed."], "B", why: "The real advantage was that work did not have to stop when the river ran low.", evidence: "no longer had to stop work during dry summers", distractor: "Worker numbers 'stayed much the same'."),
                K.mcq(L, 13, "Most of the money for the restoration came from", ["A. a national lottery heritage grant.", "B. local building firms.", "C. the county council."], "A", why: "About two-thirds came from the lottery heritage grant; the council grant was small and firms gave materials.", evidence: "national lottery heritage grant"),
                K.mcq(L, 14, "What does the guide say about photography?", ["A. A permit is needed in some buildings.", "B. It is not allowed in the engine room.", "C. It is restricted because of copyright."], "B", why: "Photos are allowed everywhere except the engine room, for safety reasons.", evidence: "except in the engine room", distractor: "He explicitly says it is not about copyright and no permission is needed."),
                K.mcq(L, 15, "What is new at the mill this season?", ["A. evening tours", "B. a picnic area", "C. a gift shop"], "A", why: "The picnic area opened last year and the shop has always been there; evening tours are new.", evidence: "evening tours"),
                K.match(L, 16, .matching, "Weaver's Cottage", featureOptions, "B", why: "Children can try on the clothes mill families wore.", evidence: "try on the clothes", skill: "matching"),
                K.match(L, 17, .matching, "Lock Keeper's House", featureOptions, "D", why: "Instead of exhibits, it contains the café.", evidence: "where you'll find our café", skill: "matching"),
                K.match(L, 18, .matching, "Engine Room", featureOptions, "A", why: "A working model shows how power reached each floor.", evidence: "working model", skill: "matching"),
                K.match(L, 19, .matching, "Old Granary", featureOptions, "F", why: "Exhibitions have moved away; the top floor now has a viewing platform.", evidence: "viewing platform", distractor: "Temporary exhibitions used to be here but have moved (to the Boathouse).", skill: "matching"),
                K.match(L, 20, .matching, "Boathouse", featureOptions, "G", why: "Local artists' displays change every six weeks.", evidence: "local artists show their work", distractor: "The film (E) is in the visitor centre, not the Boathouse.", skill: "matching")
            ],
            keyVocabulary: ["gorge", "steam engine", "workforce", "restoration", "heritage grant", "viewing platform", "temporary exhibition"]
        )

        // MARK: - Listening Part 3 (MCQ Q21–25, Matching Q26–30)
        let sourceOptions = [
            "A. too out of date to be useful",
            "B. useful for the methods section",
            "C. based on too few animals",
            "D. difficult to understand",
            "E. good for background information"
        ]
        let part3 = ListeningPart(
            id: "\(id)-lp3", partNumber: 3,
            title: "Seminar: seaweed in dairy cattle feed",
            contextDescription: "Two agricultural science students, Maya and Tom, discuss their project on seaweed feed supplements with their tutor. Questions 21–25: choose A, B or C. Questions 26–30: what do the students say about each source? Choose from A–E.",
            primaryAccent: .irish,
            dialogue: [
                K.turn("Dr Lennon", .irish, "Come in, both of you. So, you've sent me a draft of the seaweed project. Before we get into the detail, remind me why you picked this topic."),
                K.turn("Tom", .british, "Well, I'll be honest, the news coverage was what first caught my attention — there were a lot of stories about seaweed cutting methane from cows. But that's not really why we chose it."),
                K.turn("Maya", .australian, "No, it was because I spent the summer working on a dairy farm that was actually trialling a seaweed supplement. So we had access to real data from a working farm, which seemed too good to miss."),
                K.turn("Dr Lennon", .irish, "That's a good reason. And how has the farm data turned out?"),
                K.turn("Maya", .australian, "Mixed. The herd size was fine — about sixty cows, which is plenty for a student project. The problem is the records. The farmer measured milk yield for most of the trial, but there's a three-week gap in August when nothing was written down."),
                K.turn("Tom", .british, "We wondered whether we should just leave the farm data out altogether."),
                K.turn("Dr Lennon", .irish, "I wouldn't do that — it's the most original part of your work. And there isn't time to go back and collect more. What I'd suggest is that you're completely upfront about the gap. Describe it clearly in your limitations section and explain how it affects what you can conclude."),
                K.turn("Maya", .australian, "OK, that makes sense."),
                K.turn("Dr Lennon", .irish, "What about the methane measurements?"),
                K.turn("Tom", .british, "The farm used a handheld laser detector. I'd assumed those portable devices were pretty inaccurate, but a couple of studies suggest they're reasonable for comparing groups of animals, even if they're not precise for an individual cow."),
                K.turn("Maya", .australian, "And we both agree there's no way we could measure methane properly ourselves. Hiring time in the respiration chambers at the research centre costs thousands, so that was never an option."),
                K.turn("Dr Lennon", .irish, "Fine. Now, the conclusion. It's a sensible length, and it does go back to your original aims. My concern is the claim that seaweed 'solves' the problem of agricultural emissions. One farm over one summer simply can't support a statement like that. Tone it down."),
                K.turn("Tom", .british, "Fair enough. Can we run through the sources quickly? We weren't sure how to use some of them."),
                K.turn("Dr Lennon", .irish, "Go ahead."),
                K.turn("Tom", .british, "First, the government report on farm emissions. It doesn't say much about seaweed, but it gives a really clear overview of where agricultural emissions come from."),
                K.turn("Maya", .australian, "Yes, that's perfect for setting the scene at the start of the introduction."),
                K.turn("Tom", .british, "Then there's the Australian feedlot trial. The headline result is impressive, but when you look closely they only used twelve animals."),
                K.turn("Maya", .australian, "So we shouldn't put too much weight on it. We'll mention it, but carefully."),
                K.turn("Maya", .australian, "The review article was a struggle. It's so dense with statistics that I had to read some paragraphs four or five times."),
                K.turn("Tom", .british, "Same for me. I'm still not sure I followed the section on meta-analysis."),
                K.turn("Dr Lennon", .irish, "I can go through that with you. What about the farmers' survey?"),
                K.turn("Maya", .australian, "It's interesting, but it was carried out in 2003. Attitudes to feed additives have changed so much since then that I don't think we can rely on it."),
                K.turn("Tom", .british, "And finally the textbook chapter on feed conversion. It explains, step by step, how to calculate feed efficiency, so we're going to follow that procedure when we describe how we analysed the farm records."),
                K.turn("Maya", .australian, "Should we also include a short section on what further research could be done?"),
                K.turn("Dr Lennon", .irish, "Yes, but keep it brief. Suggest one or two questions that a future study could investigate, and explain why they would matter to farmers. A single paragraph is enough."),
                K.turn("Tom", .british, "And the word limit is still three thousand words?"),
                K.turn("Dr Lennon", .irish, "That's right, not including the reference list. And remember to check that every source you mention in the text appears in the references, and that the format is consistent."),
                K.turn("Dr Lennon", .irish, "Good. That's a sensible plan. Let's meet again once you've revised the conclusion.")
            ],
            questions: [
                K.mcq(L, 21, "Why did the students choose seaweed supplements as their topic?", ["A. Their tutor recommended it.", "B. Maya had worked on a farm that was testing it.", "C. It had received a lot of media attention."], "B", why: "News coverage caught Tom's attention, but the real reason was Maya's summer on a trial farm.", evidence: "spent the summer working on a dairy farm", distractor: "Media attention is mentioned and then rejected as the reason."),
                K.mcq(L, 22, "What problem did the students find with the farm data?", ["A. There were too few cows in the herd.", "B. Some milk yield records were missing.", "C. The farmer measured the wrong variable."], "B", why: "There is a three-week gap in the milk yield records in August.", evidence: "three-week gap in August", distractor: "Sixty cows is described as plenty."),
                K.mcq(L, 23, "What does the tutor advise them to do about the farm data?", ["A. remove it from the project", "B. explain its limitations clearly", "C. collect additional data"], "B", why: "She says not to drop it, there is no time to collect more, and they should be upfront about the gap.", evidence: "completely upfront about the gap"),
                K.mcq(L, 24, "What do the students agree about measuring methane?", ["A. It would be too expensive for them to do it themselves.", "B. Portable detectors give unreliable results.", "C. The farm's measurements should be repeated."], "A", why: "Hiring respiration chambers costs thousands, so measuring it themselves was never an option.", evidence: "costs thousands", distractor: "Tom thought portable detectors were inaccurate, but studies suggest they are reasonable for group comparisons."),
                K.mcq(L, 25, "What is the tutor's concern about the conclusion?", ["A. It makes claims that are too strong.", "B. It is too short.", "C. It does not refer back to the aims."], "A", why: "Saying seaweed 'solves' emissions cannot be supported by one farm over one summer.", evidence: "can't support a statement like that", distractor: "She says the length is sensible and it links to the aims."),
                K.match(L, 26, .matching, "the government report", sourceOptions, "E", why: "It gives a clear overview of emission sources, useful for the introduction.", evidence: "clear overview", skill: "matching_opinions"),
                K.match(L, 27, .matching, "the Australian feedlot trial", sourceOptions, "C", why: "Only twelve animals were used.", evidence: "only used twelve animals", skill: "matching_opinions"),
                K.match(L, 28, .matching, "the review article", sourceOptions, "D", why: "It is dense with statistics and hard to follow.", evidence: "dense with statistics", skill: "matching_opinions"),
                K.match(L, 29, .matching, "the farmers' survey", sourceOptions, "A", why: "Carried out in 2003; attitudes have changed since.", evidence: "carried out in 2003", skill: "matching_opinions"),
                K.match(L, 30, .matching, "the textbook chapter", sourceOptions, "B", why: "They will follow its calculation procedure when describing their analysis.", evidence: "follow that procedure", skill: "matching_opinions")
            ],
            keyVocabulary: ["supplement", "methane", "milk yield", "limitations section", "respiration chamber", "feed conversion", "meta-analysis"]
        )

        // MARK: - Listening Part 4 (Note completion Q31–40)
        let part4 = ListeningPart(
            id: "\(id)-lp4", partNumber: 4,
            title: "Lecture: birdsong in noisy cities",
            contextDescription: "A lecture in an urban ecology course. Complete the notes. Write ONE WORD ONLY for each answer.",
            primaryAccent: .american,
            dialogue: [
                K.turn("Lecturer", .american, "Today I want to look at how birds are adapting to one of the less obvious features of city life: noise. We tend to think about cities in terms of buildings and lost habitat, but for animals that communicate by sound, the acoustic environment matters enormously."),
                K.turn("Lecturer", .american, "Let's start with why song matters. For many songbirds, singing does two main jobs: it attracts a mate and it defends a territory against rivals. If a song can't be heard clearly, both of those jobs become harder."),
                K.turn("Lecturer", .american, "The noise of a city is not evenly spread across all sound frequencies. Traffic, in particular, produces mostly low frequency sound — that deep rumble you can feel as well as hear. So a bird whose song overlaps with that range is at a disadvantage."),
                K.turn("Lecturer", .american, "One of the earliest and best-known findings came from researchers in the Netherlands in the early two-thousands. They compared great tits living in noisy urban areas with those in quieter places and found that the city birds sang at a higher pitch. By shifting upward, they move their song away from the frequencies masked by traffic."),
                K.turn("Lecturer", .american, "Other species have adjusted their timing rather than their pitch. A study in a British city found that European robins living in places that were noisy during the day were more likely to sing at night, when the streets are quieter. Some of you may have heard a robin singing under a street light and wondered what was going on — this is part of the explanation."),
                K.turn("Lecturer", .american, "A third strategy is simply to sing louder. This is something humans do as well — think of how you raise your voice in a busy restaurant. But it isn't free. Singing louder uses more energy, and for a small bird that energy has to come from food, which may itself be scarce in a city."),
                K.turn("Lecturer", .american, "There may also be a hidden cost to the pitch shift. In some species, there's evidence that females prefer lower songs, perhaps because a lower song can signal a larger or healthier male. So a male who raises his pitch to be heard may become, in a sense, less attractive. We don't fully understand this trade-off yet."),
                K.turn("Lecturer", .american, "Now, a fascinating natural experiment came in 2020, when lockdowns emptied city streets around the world. In San Francisco, researchers who had recorded white-crowned sparrows for years found that, when traffic noise dropped, the sparrows sang more softly, and their songs carried further. In other words, the birds responded almost immediately when the noise was removed."),
                K.turn("Lecturer", .american, "What does this mean for urban planning? There are practical steps. Planting dense vegetation along busy roads can absorb some of the noise before it reaches parks and gardens. Road surfaces made of porous asphalt, which contains tiny air pockets, are noticeably quieter than conventional surfaces. And speed limits reduce noise as well as accidents."),
                K.turn("Lecturer", .american, "It's worth noting that birds aren't the only animals affected. Studies have found that some frogs living near busy roads call differently, and certain insects, such as grasshoppers, appear to adjust their songs as well. Even animals that don't rely on sound to attract a mate may be affected, because noise can make it harder for them to hear an approaching predator. So noise pollution is increasingly seen as a problem for whole ecosystems, not just for individual species."),
                K.turn("Lecturer", .american, "But above all, we need long-term monitoring. Most studies so far cover only a few breeding seasons, and we can't yet say whether these changes in song are learned behaviour or something that is becoming fixed over generations. That question will be the focus of next week's session.")
            ],
            questions: [
                K.gap(L, 31, .noteCompletion, "Traffic noise is mainly __________ frequency.", ["low"], maxWords: 1, why: "Traffic produces mostly low frequency sound.", evidence: "mostly low frequency sound", skill: "note_completion"),
                K.gap(L, 32, .noteCompletion, "Great tits in noisy urban areas sing at a higher __________.", ["pitch"], maxWords: 1, why: "City great tits sang at a higher pitch.", evidence: "sang at a higher pitch", skill: "note_completion"),
                K.gap(L, 33, .noteCompletion, "Robins in areas with daytime noise often sing at __________.", ["night"], maxWords: 1, why: "Robins in noisy places were more likely to sing at night.", evidence: "sing at night", skill: "note_completion"),
                K.gap(L, 34, .noteCompletion, "Another strategy: singing __________.", ["louder"], maxWords: 1, why: "A third strategy is simply to sing louder.", evidence: "simply to sing louder", skill: "note_completion"),
                K.gap(L, 35, .noteCompletion, "Cost of this strategy: requires more __________.", ["energy"], maxWords: 1, why: "Singing louder uses more energy.", evidence: "uses more energy", skill: "note_completion"),
                K.gap(L, 36, .noteCompletion, "In some species, females may prefer __________ songs.", ["lower", "low"], maxWords: 1, why: "There is evidence that females prefer lower songs.", evidence: "females prefer lower songs", skill: "note_completion"),
                K.gap(L, 37, .noteCompletion, "2020 lockdown, San Francisco: sparrows sang more __________.", ["softly", "quietly"], maxWords: 1, why: "When noise dropped, the sparrows sang more softly.", evidence: "sang more softly", skill: "note_completion"),
                K.gap(L, 38, .noteCompletion, "Planners: dense __________ along roads absorbs noise.", ["vegetation"], maxWords: 1, why: "Planting dense vegetation along roads absorbs noise.", evidence: "dense vegetation", skill: "note_completion"),
                K.gap(L, 39, .noteCompletion, "Quieter roads can be built using __________ asphalt.", ["porous"], maxWords: 1, why: "Porous asphalt contains air pockets and is quieter.", evidence: "porous asphalt", skill: "note_completion"),
                K.gap(L, 40, .noteCompletion, "Main research need: long-term __________.", ["monitoring"], maxWords: 1, why: "Above all, long-term monitoring is needed.", evidence: "long-term monitoring", skill: "note_completion")
            ],
            keyVocabulary: ["frequency", "pitch", "territory", "mask", "trade-off", "natural experiment", "porous", "breeding season"]
        )

        // MARK: - Reading Passage 1 (TFNG Q1–6, Note completion Q7–13)
        let passage1 = ReadingPassage(
            id: "\(id)-rp1", passageNumber: 1,
            title: "The Return of the Hedgerow",
            discipline: "Agricultural Ecology",
            paragraphs: [
                "Anyone who has travelled through the lowland countryside of Britain or northern France will be familiar with the hedgerow: a line of closely planted shrubs and small trees that divides one field from the next. Some hedges are remarkably old. Historians have found boundaries described in Anglo-Saxon land charters that still follow the same course today, and a few hedges are thought to be older than the fields around them, surviving as strips of ancient woodland that were left standing when the surrounding land was cleared for farming. Most, however, date from the enclosure movement of the eighteenth and nineteenth centuries, when common land was divided into private fields and thousands of kilometres of hawthorn were planted to mark the new boundaries and keep livestock in.",
                "For much of their history, hedges were valued for practical reasons. A well-maintained hedge was a cheap, self-repairing fence. It sheltered cattle and sheep from wind and rain, and it provided farm households with firewood, fruit and material for tools. Traditional management relied on a technique known as laying, in which a skilled worker partly cuts through the stems of each shrub near the base, bends them over at an angle and weaves them between upright stakes. The partly cut stems continue to grow, and within a year or two the hedge becomes dense from the ground upwards. Laying was slow and labour-intensive, and each region developed its own style, adapted to local livestock and weather.",
                "In the decades after the Second World War, hedges lost much of their value in the eyes of many farmers. Governments encouraged food production, machinery grew larger, and small fields became an obstacle to efficient cultivation. Hedges were removed to create larger fields, sometimes with the help of government grants. Those that remained were increasingly cut with tractor-mounted flails rather than laid by hand. Flailing is fast and cheap, but if it is carried out every year at the same height it gradually produces a hedge that is thin and full of gaps at the base, eventually turning it into a row of isolated bushes. Estimates of the total loss vary, partly because hedges were never comprehensively mapped before the removals began, but it is widely accepted that a large proportion of the network disappeared in the second half of the twentieth century.",
                "Ecologists were among the first to raise concerns. Studies showed that hedges provide habitat for a remarkable range of species, from insects and small mammals to nesting birds. Perhaps more importantly, they act as corridors, allowing animals to move between patches of woodland that would otherwise be isolated in a landscape of open fields. Bats, for instance, use lines of hedges as navigation routes when travelling between their roosts and feeding grounds, and some species appear reluctant to cross large open spaces at all. A hedge with a wide, uncultivated margin at its base is particularly valuable, as the strip of grasses and wild flowers supports pollinating insects.",
                "More recently, attention has turned to the role hedges can play in protecting soil and climate. Because a hedge is effectively a strip of permanent vegetation, the ground beneath it is rarely disturbed, and research has found that this soil can store considerably more carbon than the soil of a neighbouring arable field. Hedges planted across a slope can also slow the flow of water after heavy rain, reducing the amount of soil washed off fields and lowering the risk of flooding further downstream. For farmers there are more direct benefits too: hedges reduce wind speed across crops and provide shade for livestock during increasingly hot summers.",
                "These findings have prompted a change in policy. In several European countries, farmers can now receive payments for planting new hedges, for restoring gappy ones and for managing existing hedges in ways that benefit wildlife. The most common recommendation is simple: cut less often. Trimming a hedge once every two or three years, rather than annually, allows shrubs to flower and produce berries, which are an important source of food for birds in winter. Cutting slightly higher each time also helps, since it leaves fresh growth above the old cut instead of repeatedly removing the same wood.",
                "Not everyone is convinced that the current enthusiasm will last. Some farmers point out that new hedges take years to establish and need protection from rabbits and deer, while the payments available may not cover the true cost of the work. Others worry that schemes focus on the length of hedge planted rather than its quality, so that a newly planted line of saplings is counted in the same way as a mature, species-rich hedge. Nevertheless, interest in traditional skills is growing. Hedge-laying competitions, once confined to a handful of rural shows, now attract large numbers of entrants, and training courses frequently have waiting lists."
            ],
            questions: [
                K.tfng(R, 1, "Some hedges may be older than the farmland that surrounds them.", "TRUE", why: "Paragraph A: a few are thought to be older than the fields, surviving as strips of ancient woodland.", evidence: "older than the fields around them"),
                K.tfng(R, 2, "Hedge-laying was carried out in the same way in every region.", "FALSE", why: "Paragraph B: each region developed its own style.", evidence: "each region developed its own style"),
                K.tfng(R, 3, "After the Second World War, some farmers received financial support to remove hedges.", "TRUE", why: "Paragraph C: hedges were removed, sometimes with the help of government grants.", evidence: "government grants"),
                K.tfng(R, 4, "Tractor-mounted flails were first used on hedges in the 1960s.", "NOT GIVEN", why: "Paragraph C says flails replaced laying after the war but gives no date for their introduction.", evidence: "tractor-mounted flails", distractor: "The passage mentions 'decades after the Second World War' but no specific decade for flails."),
                K.tfng(R, 5, "Precise figures exist for the length of hedgerow lost in the twentieth century.", "FALSE", why: "Paragraph C: estimates vary because hedges were never comprehensively mapped.", evidence: "never comprehensively mapped"),
                K.tfng(R, 6, "Bats mainly feed on insects that live in hedges.", "NOT GIVEN", why: "Paragraph D says bats use hedges to navigate to feeding grounds, but not what or where they eat.", evidence: "navigation routes", distractor: "Feeding grounds are mentioned, but the bats' diet is not."),
                K.gap(R, 7, .noteCompletion, "Hedges connect patches of __________, allowing animals to move between them.", ["woodland"], maxWords: 2, why: "Paragraph D: hedges act as corridors between patches of woodland.", evidence: "patches of woodland", skill: "note_completion"),
                K.gap(R, 8, .noteCompletion, "A wide uncultivated __________ at the base of a hedge supports pollinating insects.", ["margin"], maxWords: 2, why: "Paragraph D: a wide, uncultivated margin supports pollinating insects.", evidence: "uncultivated margin", skill: "note_completion"),
                K.gap(R, 9, .noteCompletion, "Soil under a hedge can store more __________ than soil in a nearby arable field.", ["carbon"], maxWords: 2, why: "Paragraph E: this soil can store considerably more carbon.", evidence: "store considerably more carbon", skill: "note_completion"),
                K.gap(R, 10, .noteCompletion, "Hedges across slopes reduce soil loss and the risk of __________ downstream.", ["flooding", "floods"], maxWords: 2, why: "Paragraph E: lowering the risk of flooding further downstream.", evidence: "risk of flooding", skill: "note_completion"),
                K.gap(R, 11, .noteCompletion, "Hedges provide __________ for livestock in hot weather.", ["shade"], maxWords: 2, why: "Paragraph E: hedges provide shade for livestock during hot summers.", evidence: "provide shade for livestock", skill: "note_completion"),
                K.gap(R, 12, .noteCompletion, "Cutting every two or three years lets shrubs produce __________, a winter food for birds.", ["berries"], maxWords: 2, why: "Paragraph F: less frequent trimming allows shrubs to flower and produce berries.", evidence: "produce berries", skill: "note_completion"),
                K.gap(R, 13, .noteCompletion, "Critics say schemes count the __________ of hedge planted rather than its quality.", ["length"], maxWords: 2, why: "Paragraph G: schemes focus on the length of hedge planted rather than its quality.", evidence: "length of hedge planted", skill: "note_completion")
            ]
        )

        // MARK: - Reading Passage 2 (Matching information Q14–18, features Q19–22, sentence completion Q23–26)
        let paragraphOptions = ["A. Paragraph A", "B. Paragraph B", "C. Paragraph C", "D. Paragraph D", "E. Paragraph E", "F. Paragraph F", "G. Paragraph G"]
        let groupOptions = ["A. refrigeration engineers", "B. New Zealand sheep farmers", "C. British shoppers", "D. investors", "E. historians"]
        let passage2 = ReadingPassage(
            id: "\(id)-rp2", passageNumber: 2,
            title: "Frozen Cargo: How Refrigeration Changed the World's Diet",
            discipline: "Economic History & Food Technology",
            paragraphs: [
                "In the middle of the nineteenth century, the countries of the southern hemisphere faced a peculiar problem. Argentina, Australia and New Zealand had vast areas of grassland and rapidly growing flocks of sheep and herds of cattle, but relatively small populations to feed. Wool and hides could be shipped to Europe without difficulty, yet the meat itself had little commercial value. Much of it was boiled down to produce tallow, a fat used for making candles and soap, and the rest was simply wasted. Meanwhile, in the industrial cities of Britain, meat was expensive, and many working families could afford it only occasionally.",
                "The obvious solution was to carry meat across the oceans, but a voyage from New Zealand to London took around three months and crossed the tropics. Salting and drying had been used for centuries, but they changed the taste and texture of meat, and consumers regarded preserved meat as an inferior product. Canned meat became available in the 1860s and sold in large quantities, but it too suffered from a poor reputation, partly because early canning was unreliable and tins occasionally burst or spoiled. What exporters needed was a way of keeping meat as close as possible to its fresh state.",
                "The scientific principles of mechanical refrigeration were understood well before they could be applied at sea. By the 1850s, engineers in several countries had built machines that produced cold by compressing a gas and then allowing it to expand, and ice-making plants were operating in places such as Australia and the southern United States. The difficulty lay in making such machines reliable, compact and safe enough to run continuously on board a ship for weeks at a time, far from any workshop where repairs could be made. Early experimental voyages in the 1870s had mixed results: on some, the machinery failed and the cargo had to be thrown overboard.",
                "The turning point is usually dated to 1882, when a sailing ship named the Dunedin left New Zealand carrying almost five thousand frozen sheep carcasses. The voyage was far from smooth. Accounts suggest that the cold air did not circulate evenly, and the crew had to cut additional ventilation openings in the hold during the journey. Nevertheless, after more than three months at sea the cargo reached London in good condition and sold at a price considerably higher than it would have fetched at home. The financial success of the voyage persuaded investors that frozen meat could be a profitable trade, and within a few years dozens of refrigerated ships were operating on the route.",
                "Building the trade required much more than ships. Farmers in New Zealand had to change the breeds of sheep they kept, because animals raised mainly for wool did not produce the kind of meat British buyers wanted. Freezing works were built near the ports, where animals were slaughtered and frozen within hours. In Britain, cold stores had to be constructed at the docks, and specialist butchers learned how to thaw and cut frozen carcasses without damaging the meat. At first, many shoppers were suspicious: frozen meat was sometimes sold without being identified as such, and newspapers occasionally ran stories questioning whether it was safe. Over time, however, low prices won customers over, and imported meat became a regular part of the working-class diet.",
                "The effects were felt far beyond the dinner table. In New Zealand, refrigeration encouraged the breaking up of large sheep stations into smaller family farms, since meat production required more intensive management than wool. Dairy farming expanded too, as butter and cheese could now be exported in refrigerated holds. In Argentina, chilled beef became one of the country's leading exports and attracted large amounts of foreign investment. Historians have argued that, by linking producers and consumers on opposite sides of the world, refrigerated shipping played a major part in creating the first truly global food market.",
                "Today, the 'cold chain' — the unbroken series of refrigerated environments through which food passes from farm to consumer — is so familiar that it is easy to overlook. Yet it remains surprisingly fragile. A single failure, such as a power cut at a warehouse or a long delay at a border crossing, can spoil an entire consignment. The cold chain also has a significant environmental cost, since refrigeration accounts for a substantial share of the energy used in the food system, and some of the gases used as refrigerants contribute to climate change if they escape. Engineers are now developing natural refrigerants and more efficient systems, but the challenge of keeping food cold while reducing emissions is likely to grow as demand for fresh food rises worldwide."
            ],
            questions: [
                K.match(R, 14, .matchingInformation, "a description of alterations made to a ship while it was at sea", paragraphOptions, "D", why: "Paragraph D: the crew cut additional ventilation openings in the hold during the journey.", evidence: "cut additional ventilation openings", skill: "scanning"),
                K.match(R, 15, .matchingInformation, "reasons why older ways of preserving meat were unpopular", paragraphOptions, "B", why: "Paragraph B: salting and drying changed taste and texture; canning was unreliable.", evidence: "changed the taste and texture", skill: "scanning"),
                K.match(R, 16, .matchingInformation, "a reference to the vulnerability of modern food transport", paragraphOptions, "G", why: "Paragraph G: the cold chain remains surprisingly fragile.", evidence: "surprisingly fragile", skill: "scanning"),
                K.match(R, 17, .matchingInformation, "an example of meat being used for something other than food", paragraphOptions, "A", why: "Paragraph A: meat was boiled down to produce tallow for candles and soap.", evidence: "candles and soap", skill: "scanning"),
                K.match(R, 18, .matchingInformation, "the need to change livestock to suit a new market", paragraphOptions, "E", why: "Paragraph E: farmers had to change the breeds of sheep they kept.", evidence: "change the breeds of sheep", skill: "scanning"),
                K.match(R, 19, .matchingFeatures, "Their early distrust was overcome by low prices.", groupOptions, "C", why: "Paragraph E: shoppers were suspicious, but low prices won customers over.", evidence: "low prices won customers over", skill: "matching_features"),
                K.match(R, 20, .matchingFeatures, "They had to make equipment work far from any place it could be repaired.", groupOptions, "A", why: "Paragraph C: machines had to run at sea, far from any workshop.", evidence: "far from any workshop", skill: "matching_features"),
                K.match(R, 21, .matchingFeatures, "One profitable voyage convinced them to support the trade.", groupOptions, "D", why: "Paragraph D: the financial success of the voyage persuaded investors.", evidence: "persuaded investors", skill: "matching_features"),
                K.match(R, 22, .matchingFeatures, "They believe refrigerated shipping helped create a global food market.", groupOptions, "E", why: "Paragraph F: historians have argued this.", evidence: "Historians have argued", skill: "matching_features"),
                K.gap(R, 23, .sentenceCompletion, "Before refrigeration, wool and __________ were easy to export to Europe.", ["hides"], maxWords: 1, why: "Paragraph A: wool and hides could be shipped without difficulty.", evidence: "Wool and hides", skill: "sentence_completion"),
                K.gap(R, 24, .sentenceCompletion, "Early refrigeration machines worked by compressing and then expanding a __________.", ["gas"], maxWords: 1, why: "Paragraph C: machines compressed a gas and allowed it to expand.", evidence: "compressing a gas", skill: "sentence_completion"),
                K.gap(R, 25, .sentenceCompletion, "Freezing works were located close to the __________.", ["ports"], maxWords: 1, why: "Paragraph E: freezing works were built near the ports.", evidence: "near the ports", skill: "sentence_completion"),
                K.gap(R, 26, .sentenceCompletion, "Refrigerated holds also allowed New Zealand to export butter and __________.", ["cheese"], maxWords: 1, why: "Paragraph F: butter and cheese could now be exported.", evidence: "butter and cheese", skill: "sentence_completion")
            ]
        )

        // MARK: - Reading Passage 3 (MCQ Q27–31, YNNG Q32–36, Summary with word list Q37–40)
        let wordList = ["A. variety", "B. food", "C. repetitive", "D. predictable", "E. positive", "F. physical", "G. control", "H. silence"]
        let passage3 = ReadingPassage(
            id: "\(id)-rp3", passageNumber: 3,
            title: "Can Animals Be Bored?",
            discipline: "Animal Welfare Science",
            paragraphs: [
                "For a long time, scientists were reluctant to say that animals experience boredom. The word seemed to belong to the inner life of humans, and attributing it to a caged parrot or a pig in a pen risked what researchers call anthropomorphism: projecting human feelings onto creatures whose minds may work very differently. Behaviourists of the mid-twentieth century preferred to describe what animals did rather than speculate about what they felt. Yet anyone who has watched a dog left alone in a small flat all day, or a big cat pacing the same route along the edge of its enclosure, may find it hard to avoid the impression that something like boredom is taking place.",
                "Part of the difficulty is that boredom is hard to define even in people. Psychologists generally describe it as an unpleasant state that arises when a person wants to be engaged in satisfying activity but cannot be, either because the environment offers too little stimulation or because what is available feels meaningless. Crucially, boredom is not simply the absence of activity. A person relaxing in a garden is not necessarily bored; the same person waiting in a queue with nothing to do very likely is. What matters is the gap between the stimulation an individual seeks and the stimulation on offer.",
                "Defined in this way, boredom becomes something that can be tested in animals without needing to know exactly what they feel. One approach starts from a simple prediction: a bored animal should be unusually interested in almost any stimulus, even one it would normally ignore or find mildly unpleasant. In one widely discussed experiment, researchers kept mink in two kinds of housing. Some lived in standard small cages, while others had larger enclosures with water to swim in, objects to manipulate and platforms to climb. The animals were then shown a range of objects, some attractive, some neutral and some, such as the scent of a predator, normally avoided. Mink from the barren cages approached all of the objects more quickly and investigated them for longer, including the unpleasant ones. They also spent more time lying awake but inactive. To the researchers, this pattern fitted boredom better than fear or depression, both of which would be expected to reduce an animal's interest in new things.",
                "Other studies have reached similar conclusions using different species and methods. Animals kept in unstimulating environments will often work for access to variety, pressing a lever simply to change what they can see or hear. Some develop stereotypies: repetitive behaviours with no obvious purpose, such as bar-biting in sows or an elephant swaying from foot to foot. Stereotypies were once regarded as a straightforward sign of poor welfare, but the relationship is more complicated. They may reflect a past rather than a present problem, persisting long after conditions have improved, and an animal that performs them may in some cases be coping better than one that has become completely inactive. In my view, they should therefore be interpreted with considerable caution.",
                "The question matters because, if animals can be bored, then a great many of them may be bored for much of their lives. Laboratory animals, farm animals kept indoors, zoo animals and pets left alone during long working days all spend extended periods in environments that are predictable and offer few choices. Welfare standards have traditionally concentrated on preventing physical suffering: hunger, injury, disease and extremes of temperature. These are undoubtedly important, but they are not enough. An animal can be well fed, healthy and comfortable while still having nothing whatsoever to do, and some welfare scientists now argue that the absence of positive experiences should be treated as a welfare problem in its own right.",
                "In response, the practice known as environmental enrichment has spread widely. Zoos hide food so that animals must search for it, give primates puzzles to solve and regularly change the layout of enclosures. On farms, pigs may be given straw or other materials to root in, and hens may be provided with perches and areas for dust-bathing. Not all enrichment is equally effective, however. An object that is novel at first soon becomes familiar, and animals may lose interest in a new toy within days. The most successful forms of enrichment tend to be those that give an animal some control over its surroundings, or that allow it to perform behaviour it is strongly motivated to carry out, such as foraging.",
                "There are still sceptics. Some researchers argue that the experiments show only that animals in poor environments are more responsive to stimulation, which need not involve any conscious experience at all. Others note that the methods developed so far work best for species such as mammals and birds, whose behaviour is relatively easy to interpret, and say little about fish or invertebrates. Such caution is healthy, but it should not become an excuse for doing nothing. We do not need certainty about another creature's inner life to recognise that a monotonous environment is likely to be bad for it, and the cost of providing more varied surroundings is, in most cases, modest compared with the possible benefit."
            ],
            questions: [
                K.mcq(R, 27, "Why does the writer mention a dog and a big cat in paragraph A?", ["A. to show that pets suffer more than zoo animals", "B. to illustrate why the idea of animal boredom seems natural to many people", "C. to criticise the methods used by behaviourists", "D. to give examples of scientific anthropomorphism"], "B", why: "The examples show why it is 'hard to avoid the impression' that animals get bored.", evidence: "hard to avoid the impression", distractor: "D: anthropomorphism is mentioned earlier, but the examples describe ordinary observers, not scientists.", skill: "writer_purpose"),
                K.mcq(R, 28, "According to paragraph B, what is central to boredom?", ["A. a lack of physical movement", "B. a feeling of tiredness after activity", "C. a gap between the stimulation wanted and the stimulation available", "D. an inability to relax in quiet places"], "C", why: "'What matters is the gap between the stimulation an individual seeks and the stimulation on offer.'", evidence: "the gap between the stimulation", distractor: "A is explicitly rejected: boredom 'is not simply the absence of activity'.", skill: "detail"),
                K.mcq(R, 29, "Why were mink shown objects they would normally avoid?", ["A. to test whether their interest extended even to unpleasant things", "B. to measure how fearful the animals had become", "C. to make the barren cages more varied", "D. to compare mink with predator species"], "A", why: "The prediction was that a bored animal would be interested in almost any stimulus, even an unpleasant one.", evidence: "even one it would normally ignore or find mildly unpleasant", skill: "inference"),
                K.mcq(R, 30, "Why did the researchers think depression did not explain the mink's behaviour?", ["A. The mink in barren cages slept for longer.", "B. Depression cannot be measured in mink.", "C. The mink avoided the predator scent.", "D. Depression would make animals less interested in new objects."], "D", why: "Fear or depression would be expected to reduce interest in new things, but the mink showed more interest.", evidence: "reduce an animal's interest in new things", distractor: "A: they spent more time lying awake, not sleeping.", skill: "inference"),
                K.mcq(R, 31, "What does the writer say about environmental enrichment?", ["A. It has mainly been adopted by zoos.", "B. It is too expensive for most farms.", "C. Its effect may not last if it relies on novelty alone.", "D. It should be replaced by larger enclosures."], "C", why: "Paragraph F: a novel object soon becomes familiar and animals may lose interest within days.", evidence: "lose interest in a new toy within days", skill: "detail"),
                K.ynng(R, 32, "Mid-twentieth-century behaviourists were right to avoid discussing animal feelings.", "NOT GIVEN", why: "Paragraph A describes the behaviourists' approach but the writer does not judge whether they were right.", evidence: "Behaviourists of the mid-twentieth century", distractor: "Describing a view is not the same as the writer agreeing or disagreeing with it."),
                K.ynng(R, 33, "Stereotypic behaviour is always a sign that an animal is suffering at present.", "NO", why: "Paragraph D: stereotypies may reflect a past problem; the writer urges caution.", evidence: "interpreted with considerable caution"),
                K.ynng(R, 34, "Welfare standards that address only physical needs are inadequate.", "YES", why: "Paragraph E: physical protections 'are undoubtedly important, but they are not enough'.", evidence: "they are not enough"),
                K.ynng(R, 35, "Enrichment that allows foraging is more likely to succeed than simply providing new objects.", "YES", why: "Paragraph F: the most successful enrichment lets animals perform motivated behaviour such as foraging; new toys lose appeal.", evidence: "such as foraging"),
                K.ynng(R, 36, "Uncertainty about animal consciousness is a good reason to delay improving animals' surroundings.", "NO", why: "Paragraph G: caution 'should not become an excuse for doing nothing'.", evidence: "excuse for doing nothing"),
                K.match(R, 37, .summaryCompletion, "Animals in unstimulating conditions may press a lever to gain access to __________.", wordList, "A", why: "Paragraph D: animals will work for access to variety.", evidence: "work for access to variety", skill: "summary_completion"),
                K.match(R, 38, .summaryCompletion, "Stereotypies are __________ behaviours that have no obvious purpose.", wordList, "C", why: "Paragraph D: stereotypies are repetitive behaviours with no obvious purpose.", evidence: "repetitive behaviours", skill: "summary_completion"),
                K.match(R, 39, .summaryCompletion, "Many captive and indoor animals live in environments that are __________ and offer few choices.", wordList, "D", why: "Paragraph E: environments that are predictable and offer few choices.", evidence: "predictable and offer few choices", skill: "summary_completion"),
                K.match(R, 40, .summaryCompletion, "Some scientists argue that a lack of __________ experiences is itself a welfare problem.", wordList, "E", why: "Paragraph E: the absence of positive experiences should be treated as a welfare problem.", evidence: "absence of positive experiences", distractor: "F (physical) describes what traditional standards focus on, not what is missing.", skill: "summary_completion")
            ]
        )

        // MARK: - Writing
        let task1 = WritingTask1Prompt(
            id: "\(id)-wt1",
            title: "Household food waste by category, 2010 and 2020",
            visualType: .barChart,
            instructions: "The bar chart shows the average amount of food thrown away per household each week in one country in 2010 and 2020, by type of food. Summarise the information by selecting and reporting the main features, and make comparisons where relevant. Write at least 150 words.",
            minimumWords: 150,
            dataPoints: [
                VisualDataPoint(series: "2010", category: "Vegetables & salad", value: 420, unit: "grams"),
                VisualDataPoint(series: "2020", category: "Vegetables & salad", value: 310, unit: "grams"),
                VisualDataPoint(series: "2010", category: "Bread & bakery", value: 290, unit: "grams"),
                VisualDataPoint(series: "2020", category: "Bread & bakery", value: 250, unit: "grams"),
                VisualDataPoint(series: "2010", category: "Fruit", value: 210, unit: "grams"),
                VisualDataPoint(series: "2020", category: "Fruit", value: 230, unit: "grams"),
                VisualDataPoint(series: "2010", category: "Dairy", value: 180, unit: "grams"),
                VisualDataPoint(series: "2020", category: "Dairy", value: 150, unit: "grams"),
                VisualDataPoint(series: "2010", category: "Meat & fish", value: 150, unit: "grams"),
                VisualDataPoint(series: "2020", category: "Meat & fish", value: 120, unit: "grams"),
                VisualDataPoint(series: "2010", category: "Ready meals", value: 90, unit: "grams"),
                VisualDataPoint(series: "2020", category: "Ready meals", value: 140, unit: "grams")
            ],
            keyOverviewPoints: [
                "Total weekly waste fell, from about 1,340 g to 1,200 g per household.",
                "Vegetables and salad were the largest category in both years despite the biggest fall (−110 g).",
                "Only fruit and ready meals increased; ready meals rose most sharply (+50 g, roughly +56%)."
            ]
        )
        let task2 = WritingTask2Prompt(
            id: "\(id)-wt2",
            title: "Paying to visit museums and heritage sites",
            essayType: .discussion,
            topicDomain: "Culture & Public Funding",
            promptText: "Some people think that museums and historic sites should be free for everyone to visit, while others believe visitors should pay an entrance fee. Discuss both these views and give your own opinion.",
            minimumWords: 250
        )

        // MARK: - Speaking
        let speaking = SpeakingPromptSet(
            id: "\(id)-spk",
            theme: "Places, nature and the outdoors",
            part1Questions: [
                "Do you have a garden, or any plants where you live?",
                "How often do you spend time outdoors in your free time?",
                "Did you visit parks much when you were a child?",
                "Would you rather live in the countryside or in a city? Why?"
            ],
            part2CueCard: SpeakingCueCard(
                topic: "Describe a natural place you visited and enjoyed.",
                bulletPoints: ["where it is", "when you went there and who with", "what you did there", "and explain why you enjoyed it"],
                prepSeconds: 60, speakSeconds: 120
            ),
            part3Questions: [
                "Why do some people prefer to spend their free time indoors?",
                "How has the way people use public parks changed in recent years?",
                "Should governments limit building on farmland? Why or why not?",
                "What can ordinary people do to protect wildlife in towns and cities?"
            ]
        )

        return MockExam(
            id: id, examNumber: 1,
            title: "Mock Exam 1: Land, Food & Environment",
            difficulty: .intermediate,
            theme: "Land, Food & Environment",
            listeningParts: [part1, part2, part3, part4],
            readingPassages: [passage1, passage2, passage3],
            writingTask1: task1, writingTask2: task2, speakingSet: speaking,
            provenance: K.provenance([
                "Historical details in Reading Passage 2 (the 1882 Dunedin voyage, early refrigeration) are simplified for practice and should not be cited as a reference.",
                "Research findings in Listening Part 4 and Reading Passage 3 are summarised in general terms for practice."
            ])
        )
    }()
}
