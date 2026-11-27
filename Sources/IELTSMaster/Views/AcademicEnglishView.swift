import SwiftUI
import IELTSCore

public struct AcademicEnglishView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var includeSpecializedAgriBio: Bool = true
    @LocalState private var selectedUnitID: String = AcademicEnglishContent.units.first?.id ?? ""
    @LocalState private var practiceDraft: String = ""

    public init() {}

    private var visibleUnits: [AcademicEnglishUnit] {
        AcademicEnglishContent.units.filter { includeSpecializedAgriBio || !$0.isSpecializedAgriBio }
    }

    private var activeUnit: AcademicEnglishUnit {
        visibleUnits.first(where: { $0.id == selectedUnitID }) ?? visibleUnits[0]
    }

    public var body: some View {
        HSplitView {
            VStack(alignment: .leading, spacing: IMTheme.sp100) {
                Toggle("Include Agricultural & Biotech track", isOn: $includeSpecializedAgriBio)
                    .padding(IMTheme.sp100)
                List(visibleUnits, selection: $selectedUnitID) { unit in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(unit.title).imText(.body5)
                        HStack {
                            IMBadge(text: unit.category)
                            if unit.isSpecializedAgriBio {
                                IMBadge(text: "Optional Track", tint: IMTheme.statusSuccess)
                            }
                        }
                    }
                    .tag(unit.id)
                    .padding(.vertical, 4)
                }
            }
            .frame(minWidth: 270, maxWidth: 330)

            ScrollView {
                VStack(alignment: .leading, spacing: IMTheme.sp300) {
                    IMPageHeader(
                        title: activeUnit.title,
                        subtitle: activeUnit.overview,
                        badgeText: activeUnit.category
                    )

                    IMCard {
                        Text("Academic & professional conventions").imText(.title3)
                        ForEach(activeUnit.keyConventions, id: \.self) { item in
                            Text("• \(item)").imText(.body6)
                        }
                    }

                    IMCard {
                        Text("Model academic excerpt").imText(.title3)
                        Text(activeUnit.modelExcerpt)
                            .imText(.body3)
                            .textSelection(.enabled)
                        Divider()
                        Text("Reusable academic phrases").imText(.title4)
                        ForEach(activeUnit.keyPhrases, id: \.self) { phrase in
                            Text("• \(phrase)").imText(.body6).foregroundStyle(.secondary)
                        }
                        if app.profile.languageMode != .englishImmersion {
                            IMArabicBlock(text: activeUnit.arabicNotes)
                        }
                    }

                    IMCard {
                        Text("Applied writing task").imText(.title3)
                        Text(activeUnit.practiceTask).imText(.body6)
                        TextEditor(text: $practiceDraft)
                            .frame(minHeight: 150)
                            .overlay(RoundedRectangle(cornerRadius: IMTheme.radiusInner).stroke(Color.primary.opacity(0.12), lineWidth: 1))
                        HStack {
                            Text("\(IELTSScoringEngine.countWords(in: practiceDraft)) words").imText(.caption4).foregroundStyle(.secondary)
                            Spacer()
                            Button("Review with AI Teacher") {
                                app.selectedSection = .aiTeacher
                                app.sendTeacherPrompt(
                                    "Please review this Academic English practice response for '\(activeUnit.title)'. Evaluate register, clarity, concision, and grammar:\n\n\(practiceDraft)",
                                    requestArabic: app.profile.shouldShowArabicByDefault
                                )
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(practiceDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding(IMTheme.sp400)
            }
        }
    }
}
