import SwiftUI
import Charts
import IELTSCore

public struct ProgressAnalyticsView: View {
    @EnvironmentObject private var app: AppState

    public init() {}

    private var chronologicalAttempts: [ExamAttemptRecord] {
        app.attempts.sorted { $0.date < $1.date }
    }

    private var errorCategoryCounts: [(category: String, count: Int)] {
        let grouped = Dictionary(grouping: app.mistakes, by: \.errorCategory)
        return grouped
            .map { (category: $0.key, count: $0.value.reduce(0) { $0 + $1.recurrenceCount }) }
            .sorted { $0.count > $1.count }
            .prefix(8)
            .map { $0 }
    }

    private var vocabRetentionSummary: (mastered: Int, learning: Int, due: Int) {
        let now = Date()
        let mastered = app.vocabulary.filter { $0.repetitions >= 3 && $0.intervalDays >= 14 }.count
        let due = app.vocabulary.filter { $0.nextReviewDate <= now }.count
        let learning = max(0, app.vocabulary.count - mastered)
        return (mastered, learning, due)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "Progress & analytics",
                    subtitle: "Interactive charts derived strictly from your recorded exam attempts, grammar verifications, SM-2 vocabulary reviews, and mistake history. No synthetic progress is ever fabricated.",
                    badgeText: "\(app.attempts.count) recorded attempt(s)"
                )

                // Overall Band Progression Chart
                IMCard {
                    Text("Overall & module band progression").imText(.title2)
                    if chronologicalAttempts.isEmpty {
                        Text("Complete at least one Listening, Reading, Writing, Speaking, or Full Mock attempt to plot historical band evolution.")
                            .imText(.body6)
                            .foregroundStyle(.secondary)
                    } else {
                        Chart(chronologicalAttempts) { attempt in
                            LineMark(
                                x: .value("Date", attempt.date),
                                y: .value("Estimated Band", attempt.overallBand)
                            )
                            .foregroundStyle(IMTheme.accentPrimary)
                            PointMark(
                                x: .value("Date", attempt.date),
                                y: .value("Estimated Band", attempt.overallBand)
                            )
                            .foregroundStyle(IMTheme.accentPrimary)
                        }
                        .chartYScale(domain: 0...9)
                        .frame(height: 220)
                    }
                }

                // Current Module Snapshot Bar Chart
                IMCard {
                    Text("Current module estimates vs target (\(String(format: "%.1f", app.profile.targetBand)))").imText(.title2)
                    let moduleData: [(String, Double)] = [
                        ("Listening", app.profile.estimatedListeningBand),
                        ("Reading", app.profile.estimatedReadingBand),
                        ("Writing", app.profile.estimatedWritingBand),
                        ("Speaking", app.profile.estimatedSpeakingBand)
                    ]
                    Chart {
                        ForEach(moduleData, id: \.0) { item in
                            BarMark(
                                x: .value("Module", item.0),
                                y: .value("Band", item.1)
                            )
                            .foregroundStyle(IMTheme.accentPrimary)
                        }
                        RuleMark(y: .value("Target", app.profile.targetBand))
                            .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                            .foregroundStyle(IMTheme.statusSuccess)
                    }
                    .chartYScale(domain: 0...9)
                    .frame(height: 200)
                }

                // Error Frequency & Vocabulary Retention
                HStack(alignment: .top, spacing: IMTheme.sp200) {
                    IMCard {
                        Text("Error frequency by category").imText(.title3)
                        if errorCategoryCounts.isEmpty {
                            Text("No errors recorded yet.").imText(.body6).foregroundStyle(.secondary)
                        } else {
                            Chart(errorCategoryCounts, id: \.category) { item in
                                BarMark(
                                    x: .value("Occurrences", item.count),
                                    y: .value("Category", item.category)
                                )
                                .foregroundStyle(IMTheme.statusWarning)
                            }
                            .frame(height: 210)
                        }
                    }

                    IMCard {
                        Text("Grammar & vocabulary retention").imText(.title3)
                        let v = vocabRetentionSummary
                        VStack(alignment: .leading, spacing: IMTheme.sp100) {
                            HStack {
                                Text("Grammar topics mastered").imText(.body6)
                                Spacer()
                                IMBadge(text: "\(app.masteredGrammarCount) / \(GrammarCurriculum.lessons.count)")
                            }
                            HStack {
                                Text("Vocabulary long-term retained").imText(.body6)
                                Spacer()
                                IMBadge(text: "\(v.mastered) / \(app.vocabulary.count)")
                            }
                            HStack {
                                Text("Vocabulary due now").imText(.body6)
                                Spacer()
                                IMBadge(text: "\(v.due)", tint: v.due > 0 ? IMTheme.statusWarning : IMTheme.statusSuccess)
                            }
                            let readingWPMs = app.attempts.compactMap(\.readingWPM)
                            if !readingWPMs.isEmpty {
                                let avgWPM = readingWPMs.reduce(0, +) / Double(readingWPMs.count)
                                HStack {
                                    Text("Average Academic Reading speed").imText(.body6)
                                    Spacer()
                                    IMBadge(text: "\(Int(avgWPM)) WPM")
                                }
                            }
                        }
                    }
                }

                // Weekly & Monthly Summary Report
                IMCard {
                    Text("Activity summary report").imText(.title2)
                    let weekCutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                    let monthCutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                    let weekAttempts = app.attempts.filter { $0.date >= weekCutoff }.count
                    let monthAttempts = app.attempts.filter { $0.date >= monthCutoff }.count
                    let weekMinutes = app.attempts.filter { $0.date >= weekCutoff }.reduce(0) { $0 + $1.durationSeconds } / 60

                    HStack(spacing: IMTheme.sp200) {
                        IMBadge(text: "Last 7 days: \(weekAttempts) attempt(s), \(weekMinutes) min")
                        IMBadge(text: "Last 30 days: \(monthAttempts) attempt(s)")
                        IMBadge(text: "Essays saved: \(app.essays.count)")
                        IMBadge(text: "Recordings saved: \(app.recordings.count)")
                    }
                    Text("Estimates are calculated from recorded sessions and never guarantee an official IELTS test result.")
                        .imText(.caption5)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(IMTheme.sp400)
        }
    }
}
