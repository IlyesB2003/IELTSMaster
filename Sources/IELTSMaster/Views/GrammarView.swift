import SwiftUI
import IELTSCore

public struct GrammarView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedLessonID: String = GrammarCurriculum.lessons.first?.id ?? ""
    @LocalState private var selectedAnswers: [String: Int] = [:]
    @LocalState private var checkedSession: Bool = false
    @LocalState private var showArabic: Bool = false

    public init() {}

    private var selectedLesson: GrammarLesson {
        GrammarCurriculum.lessons.first(where: { $0.id == selectedLessonID }) ?? GrammarCurriculum.lessons[0]
    }

    public var body: some View {
        HSplitView {
            // Left Lesson List (20 Structured Topics)
            List(GrammarCurriculum.lessons, selection: $selectedLessonID) { lesson in
                let prog = app.grammarProgress[lesson.id]
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(lesson.order). \(lesson.title)").imText(.body5)
                        Text(lesson.cefrRange).imText(.caption5).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let status = prog?.status {
                        IMBadge(
                            text: status.rawValue,
                            tint: status == .mastered ? IMTheme.statusSuccess : (status == .reviewing ? IMTheme.statusWarning : nil)
                        )
                    }
                }
                .tag(lesson.id)
                .padding(.vertical, 3)
            }
            .frame(minWidth: 270, maxWidth: 320)
            .onChange(of: selectedLessonID) { _, _ in
                selectedAnswers = [:]
                checkedSession = false
            }

            // Right Lesson Detail & Interactive Exercises
            ScrollView {
                VStack(alignment: .leading, spacing: IMTheme.sp300) {
                    IMPageHeader(
                        title: selectedLesson.title,
                        subtitle: selectedLesson.summary,
                        badgeText: selectedLesson.cefrRange
                    )

                    if app.profile.languageMode != .englishImmersion {
                        Toggle("Show Arabic explanation (الشرح بالعربية)", isOn: $showArabic)
                    }

                    IMCard {
                        Text("Core grammar rules").imText(.title3)
                        ForEach(selectedLesson.detailedRules, id: \.self) { rule in
                            Text("• \(rule)").imText(.body6)
                        }
                        Divider()
                        Text("Academic examples").imText(.title4)
                        ForEach(selectedLesson.examples, id: \.self) { ex in
                            Text(ex).imText(.body6).foregroundStyle(.secondary)
                        }
                        if !selectedLesson.commonIELTSTraps.isEmpty {
                            Divider()
                            Text("Common IELTS traps").imText(.title4)
                            ForEach(selectedLesson.commonIELTSTraps, id: \.self) { trap in
                                Text("• \(trap)").imText(.caption2).foregroundStyle(IMTheme.statusWarning)
                            }
                        }
                        if showArabic && app.profile.languageMode != .englishImmersion {
                            IMArabicBlock(text: selectedLesson.arabicExplanation)
                        }
                    }

                    IMCard {
                        Text("Mastery verification exercises").imText(.title3)
                        ForEach(selectedLesson.exercises) { ex in
                            VStack(alignment: .leading, spacing: IMTheme.sp75) {
                                Text(ex.prompt).imText(.body2)
                                ForEach(ex.options.indices, id: \.self) { idx in
                                    Button {
                                        if !checkedSession { selectedAnswers[ex.id] = idx }
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedAnswers[ex.id] == idx ? "largecircle.fill.circle" : "circle")
                                            Text(ex.options[idx]).imText(.body6)
                                            Spacer()
                                        }
                                        .padding(4)
                                    }
                                    .buttonStyle(.plain)
                                }
                                if checkedSession {
                                    let isCorrect = selectedAnswers[ex.id] == ex.correctIndex
                                    IMBadge(text: isCorrect ? "Correct" : "Needs review", tint: isCorrect ? IMTheme.statusSuccess : IMTheme.statusDanger)
                                    Text(ex.explanation).imText(.caption2).foregroundStyle(.secondary)
                                    if showArabic && app.profile.languageMode != .englishImmersion {
                                        IMArabicBlock(text: ex.arabicExplanation)
                                    }
                                }
                                Divider()
                            }
                        }

                        HStack {
                            if checkedSession {
                                Button("Practice again") {
                                    selectedAnswers = [:]
                                    checkedSession = false
                                }
                                .buttonStyle(.bordered)
                            } else {
                                Button("Verify answers") {
                                    verifyExercises()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(selectedAnswers.count < selectedLesson.exercises.count)
                            }
                            Spacer()
                            if let prog = app.grammarProgress[selectedLesson.id] {
                                Text("Status: \(prog.status.rawValue) • Accuracy: \(Int(prog.accuracy * 100))% across \(prog.attempts) attempt(s)")
                                    .imText(.caption4)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(IMTheme.sp400)
            }
        }
        .onAppear {
            showArabic = app.profile.shouldShowArabicByDefault
        }
    }

    private func verifyExercises() {
        var correct = 0
        var wrongs: [(String, String, String, String)] = []
        for ex in selectedLesson.exercises {
            let picked = selectedAnswers[ex.id] ?? -1
            if picked == ex.correctIndex {
                correct += 1
            } else {
                let pickedText = (0..<ex.options.count).contains(picked) ? ex.options[picked] : "(none)"
                wrongs.append((ex.prompt, pickedText, ex.options[ex.correctIndex], ex.explanation))
            }
        }
        app.recordGrammarSession(
            lesson: selectedLesson,
            correctCount: correct,
            totalCount: selectedLesson.exercises.count,
            wrongPrompts: wrongs
        )
        checkedSession = true
    }
}
