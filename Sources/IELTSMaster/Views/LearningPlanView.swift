import SwiftUI
import IELTSCore

public struct LearningPlanView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var selectedMinutes: Int = 45
    private let durations = [15, 30, 45, 60, 90]

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "My learning plan",
                    subtitle: "Adaptive daily and weekly study schedule generated from your diagnostic results, recurring mistakes, and lowest IELTS modules.",
                    badgeText: "\(app.currentPlan.sessionDurationMinutes) min sessions"
                )

                IMCard {
                    IMFlow {
                        VStack(alignment: .leading, spacing: IMTheme.sp50) {
                            Text("Session duration").imText(.title3)
                            Text("Sessions of 45 minutes or longer automatically include scheduled cognitive breaks.")
                                .imText(.caption5)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Picker("Duration", selection: $selectedMinutes) {
                            ForEach(durations, id: \.self) { m in
                                Text("\(m) min").tag(m)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 340)

                        Button("Rebuild plan") {
                            app.regenerateStudyPlan(sessionMinutes: selectedMinutes)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                IMCard {
                    Text("Detected adaptive priorities").imText(.title2)
                    ForEach(app.currentPlan.priorityWeaknesses, id: \.self) { priority in
                        HStack(spacing: IMTheme.sp75) {
                            Image(systemName: "target")
                                .foregroundStyle(IMTheme.accentPrimary)
                            Text(priority).imText(.body6)
                        }
                    }
                }

                IMCard {
                    HStack {
                        Text("Weekly schedule").imText(.title2)
                        Spacer()
                        let completed = app.currentPlan.sessions.filter { !$0.isBreak && $0.isCompleted }.count
                        let total = app.currentPlan.sessions.filter { !$0.isBreak }.count
                        IMBadge(text: "\(completed) / \(total) sessions done")
                    }

                    ForEach(app.currentPlan.sessions) { item in
                        HStack(alignment: .top, spacing: IMTheme.sp100) {
                            Button {
                                app.toggleSessionCompleted(item.id)
                            } label: {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isCompleted ? IMTheme.statusSuccess : .secondary)
                                    .font(.system(size: 18))
                            }
                            .buttonStyle(.plain)
                            .disabled(item.isBreak)

                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(item.dayLabel).imText(.caption3).foregroundStyle(.secondary)
                                    IMBadge(text: "\(item.durationMinutes) min")
                                    IMBadge(text: item.module)
                                }
                                Text(item.title).imText(.body4)
                                Text(item.focusReason).imText(.caption5).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !item.isBreak {
                                Button("Open") {
                                    navigateToModule(item.module)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, IMTheme.sp50)
                        Divider()
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
        .onAppear {
            selectedMinutes = app.profile.preferredSessionMinutes
        }
    }

    private func navigateToModule(_ module: String) {
        switch module {
        case "Writing": app.selectedSection = .writing
        case "Reading": app.selectedSection = .reading
        case "Listening": app.selectedSection = .listening
        case "Speaking": app.selectedSection = .speaking
        case "Grammar": app.selectedSection = .grammar
        case "Vocabulary": app.selectedSection = .vocabulary
        case "Mistake Notebook": app.selectedSection = .mistakeNotebook
        default: app.selectedSection = .dashboard
        }
    }
}
