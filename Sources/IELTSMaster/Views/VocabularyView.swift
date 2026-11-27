import SwiftUI
import IELTSCore

public struct VocabularyView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var searchQuery: String = ""
    @LocalState private var selectedCategory: String = "All"
    @LocalState private var showArabic: Bool = true
    @LocalState private var activeReviewMode: Bool = false
    @LocalState private var revealAnswer: Bool = false

    public init() {}

    private var categories: [String] {
        ["All"] + Array(Set(app.vocabulary.map(\.category))).sorted()
    }

    private var filteredItems: [VocabularyItem] {
        app.vocabulary.filter { item in
            let catOK = selectedCategory == "All" || item.category == selectedCategory
            let qOK = searchQuery.isEmpty
                || item.word.localizedCaseInsensitiveContains(searchQuery)
                || item.definition.localizedCaseInsensitiveContains(searchQuery)
            return catOK && qOK
        }
    }

    private var dueQueue: [VocabularyItem] {
        app.adaptiveEngine.dueVocabularyItems(from: app.vocabulary)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Academic vocabulary & SM-2 trainer",
                    subtitle: "IELTS Academic lexicon, collocations, phrasal verbs, connectors, and scientific terminology with IPA, audio pronunciation, Arabic translation, and SuperMemo-2 spaced repetition.",
                    badgeText: "\(dueQueue.count) due for review"
                )

                IMCard {
                    IMFlow(spacing: IMTheme.sp100) {
                        TextField("Search word or definition...", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 260)

                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { cat in Text(cat).tag(cat) }
                        }
                        .frame(maxWidth: 220)

                        if app.profile.languageMode != .englishImmersion {
                            Toggle("Arabic", isOn: $showArabic)
                        }

                        Spacer()

                        Button(activeReviewMode ? "Browse dictionary" : "Start SM-2 active recall") {
                            activeReviewMode.toggle()
                            revealAnswer = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                if activeReviewMode {
                    if let current = dueQueue.first {
                        IMCard(padding: IMTheme.sp300) {
                            HStack {
                                IMBadge(text: current.category)
                                IMBadge(text: current.cefrLevel.rawValue)
                                Spacer()
                                Button("Pronounce") {
                                    app.audioService.speak(text: current.word, accent: .british)
                                }
                                .buttonStyle(.bordered)
                            }
                            Text(current.word).imText(.heading4)
                            Text("\(current.partOfSpeech) • \(current.ipa)")
                                .imText(.body6)
                                .foregroundStyle(.secondary)

                            if revealAnswer {
                                Divider()
                                Text(current.definition).imText(.body2)
                                Text("Example: \(current.exampleSentence)").imText(.body6).foregroundStyle(.secondary)
                                if !current.collocations.isEmpty {
                                    Text("Collocations: \(current.collocations.joined(separator: " • "))").imText(.caption2)
                                }
                                if showArabic && app.profile.languageMode != .englishImmersion {
                                    IMArabicBlock(title: "المعنى بالعربية", text: current.arabicTranslation)
                                }
                                HStack(spacing: IMTheme.sp100) {
                                    Button("Again (1d)") { rate(current, quality: 1) }.buttonStyle(.bordered)
                                    Button("Hard") { rate(current, quality: 3) }.buttonStyle(.bordered)
                                    Button("Good") { rate(current, quality: 4) }.buttonStyle(.borderedProminent)
                                    Button("Easy") { rate(current, quality: 5) }.buttonStyle(.bordered)
                                }
                                .padding(.top, IMTheme.sp100)
                            } else {
                                Button("Reveal meaning & collocations") {
                                    revealAnswer = true
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, IMTheme.sp100)
                            }
                        }
                    } else {
                        IMEmptyState(
                            icon: "checkmark.seal",
                            title: "All scheduled vocabulary reviewed",
                            message: "You have no overdue SM-2 cards right now. Switch back to Browse dictionary to explore more collocations."
                        )
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: IMTheme.sp200)], spacing: IMTheme.sp200) {
                        ForEach(filteredItems) { item in
                            IMCard {
                                HStack {
                                    Text(item.word).imText(.title2)
                                    Text(item.ipa).imText(.caption4).foregroundStyle(.secondary)
                                    Spacer()
                                    Button {
                                        app.audioService.speak(text: "\(item.word). \(item.exampleSentence)", accent: .british)
                                    } label: {
                                        Image(systemName: "speaker.wave.2")
                                    }
                                    .buttonStyle(.bordered)
                                }
                                HStack {
                                    IMBadge(text: item.partOfSpeech)
                                    IMBadge(text: item.cefrLevel.rawValue)
                                    IMBadge(text: item.category)
                                }
                                Text(item.definition).imText(.body6)
                                Text(item.exampleSentence).imText(.caption2).foregroundStyle(.secondary)
                                if !item.collocations.isEmpty {
                                    Text("Collocations: \(item.collocations.joined(separator: ", "))")
                                        .imText(.caption5)
                                        .foregroundStyle(.secondary)
                                }
                                if showArabic && app.profile.languageMode != .englishImmersion {
                                    IMArabicBlock(title: "الترجمة", text: item.arabicTranslation)
                                }
                            }
                        }
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
        .onAppear {
            showArabic = app.profile.shouldShowArabicByDefault
        }
    }

    private func rate(_ item: VocabularyItem, quality: Int) {
        app.reviewVocabularyItem(id: item.id, quality: quality)
        revealAnswer = false
    }
}
