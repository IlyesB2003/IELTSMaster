import SwiftUI
import IELTSCore

/// Skills Coach: measured accuracy per IELTS sub-skill, and a lesson for each one.
public struct SkillsCoachView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedLessonID: String? = nil

    public init() {}

    private var selectedLesson: StrategyLesson {
        if let id = selectedLessonID, let l = StrategyLessons.all.first(where: { $0.id == id }) { return l }
        if let tag = app.coachFocusSkill, let l = StrategyLessons.lesson(for: tag) { return l }
        if let tag = app.weakSkillTags.first, let l = StrategyLessons.lesson(for: tag) { return l }
        return StrategyLessons.all[0]
    }

    public var body: some View {
        GeometryReader { geo in
            if geo.size.width >= 880 {
                HStack(spacing: 0) {
                    ScrollView { skillList.padding(IMTheme.sp200) }
                        .frame(width: min(360, geo.size.width * 0.36))
                    Divider()
                    ScrollView { lessonDetail.padding(IMTheme.sp300).imPageWidth() }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: IMTheme.sp300) {
                        skillList
                        Divider()
                        lessonDetail
                    }
                    .padding(IMTheme.sp200)
                }
            }
        }
        .onChange(of: app.coachFocusSkill) { _, tag in
            if let tag, let l = StrategyLessons.lesson(for: tag) { selectedLessonID = l.id }
        }
        .onAppear {
            if let tag = app.coachFocusSkill, let l = StrategyLessons.lesson(for: tag) { selectedLessonID = l.id }
        }
    }

    // MARK: Skill list

    private var skillList: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp200) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Skills Coach").imText(.heading5)
                Text(app.skillEvents.isEmpty
                     ? "Your skill profile builds from every answer you submit. Lessons are ready now."
                     : "Measured from your last \(app.skillEvents.count) answers. Recent answers count most.")
                    .imText(.body6)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !app.weakestSkills.isEmpty {
                IMSectionTitle("Work on these first")
                ForEach(app.weakestSkills) { skill in skillRow(skill) }
            }

            let others = app.skillMastery.filter { !$0.isWeak }
            if !others.isEmpty {
                IMSectionTitle("Other skills you've practised")
                ForEach(others) { skill in skillRow(skill) }
            }

            IMSectionTitle("All lessons")
            ForEach(StrategyLessons.all) { lesson in
                Button {
                    selectedLessonID = lesson.id
                } label: {
                    HStack {
                        Image(systemName: "graduationcap")
                            .foregroundStyle(IMTheme.moduleColor(lesson.module))
                            .frame(width: 18)
                        Text(lesson.title).imText(.body5).multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(selectedLesson.id == lesson.id ? IMTheme.accentPrimary.opacity(0.12) : Color.clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func skillRow(_ skill: SkillMastery) -> some View {
        Button {
            if let l = StrategyLessons.lesson(for: skill.skillTag) { selectedLessonID = l.id }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                IMSkillBar(
                    title: skill.title,
                    value: skill.weightedAccuracy,
                    tint: IMTheme.accuracyColor(skill.weightedAccuracy),
                    trailingText: "\(Int((skill.weightedAccuracy * 100).rounded()))%"
                )
                Text("\(skill.module) · \(skill.correct)/\(skill.attempts) right · \(skill.confidence.rawValue.lowercased()) confidence")
                    .imText(.caption5)
                    .foregroundStyle(.secondary)
            }
            .padding(IMTheme.sp100)
            .imSurface(radius: 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(IMPressableStyle())
    }

    // MARK: Lesson detail

    private var lessonDetail: some View {
        let lesson = selectedLesson
        let stats = app.skillMastery.filter { lesson.skillTags.contains($0.skillTag) }
        let practiceKind: PracticeUnit.Kind = lesson.module == "Listening" ? .listening : .reading

        return VStack(alignment: .leading, spacing: IMTheme.sp300) {
            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.module.uppercased())
                    .font(.system(size: 10, weight: .bold)).tracking(0.8)
                    .foregroundStyle(IMTheme.moduleColor(lesson.module))
                Text(lesson.title).imText(.heading4)
                Text(lesson.whatItTests)
                    .imText(.body3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !stats.isEmpty {
                HStack(spacing: IMTheme.sp200) {
                    ForEach(stats) { s in
                        IMStatTile(
                            label: "\(SkillCatalog.title(for: s.skillTag)) · \(s.module)",
                            value: "\(Int((s.weightedAccuracy * 100).rounded()))%",
                            detail: "\(s.correct) of \(s.attempts) right"
                        )
                    }
                }
            }

            IMCard(padding: IMTheme.sp300) {
                Text("The method").imText(.title1)
                ForEach(Array(lesson.steps.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .firstTextBaseline, spacing: IMTheme.sp100) {
                        Text("\(i + 1)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(IMTheme.accentPrimary))
                        Text(step)
                            .imText(.body3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            IMCard(padding: IMTheme.sp300) {
                Label("Worked example", systemImage: "lightbulb").imText(.title1)
                Text(lesson.workedExample)
                    .imText(.body3)
                    .lineSpacing(3)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

            IMCard(padding: IMTheme.sp300) {
                Label("Traps to avoid", systemImage: "exclamationmark.triangle").imText(.title1)
                    .foregroundStyle(IMTheme.statusWarning)
                ForEach(lesson.traps, id: \.self) { trap in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•").foregroundStyle(IMTheme.statusWarning)
                        Text(trap).imText(.body3).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if app.profile.languageMode != .englishImmersion {
                IMArabicBlock(title: lesson.arabicTitle, text: lesson.arabicSummary)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: IMTheme.sp100) { actions(lesson: lesson, kind: practiceKind) }
                VStack(alignment: .leading, spacing: IMTheme.sp100) { actions(lesson: lesson, kind: practiceKind) }
            }
        }
        .frame(maxWidth: 760, alignment: .leading)
    }

    @ViewBuilder
    private func actions(lesson: StrategyLesson, kind: PracticeUnit.Kind) -> some View {
        Button {
            _ = app.startNextPractice(kind, focusSkill: lesson.skillTags.first)
        } label: {
            Label("Practise this now", systemImage: "play.fill")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)

        Button {
            app.askTeacherToExplain(skillTag: lesson.skillTags.first ?? "", module: lesson.module)
        } label: {
            Label("Ask the AI teacher to go deeper", systemImage: "person.bubble")
        }
        .buttonStyle(.bordered)
        .controlSize(.large)

        if kind == .reading {
            Button {
                Task { await app.generateFreshReading(focusSkill: lesson.skillTags.first) }
            } label: {
                Label("New AI passage for this skill", systemImage: "wand.and.stars")
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(app.isGeneratingPractice)
        }
    }
}
