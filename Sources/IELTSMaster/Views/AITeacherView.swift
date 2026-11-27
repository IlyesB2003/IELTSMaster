import SwiftUI
import IELTSCore

/// Conversational IELTS teacher. Uses the local model when connected, grounded in the official criteria;
/// falls back to offline knowledge when no model is available.
public struct AITeacherView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.colorScheme) private var colorScheme
    @LocalState private var inputPrompt: String = ""
    @LocalState private var includeArabicExplanation: Bool = false

    public init() {}

    private var canSend: Bool {
        !inputPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !app.isStreamingTeacher
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            conversation
            Divider()
            composer
        }
        .onAppear {
            includeArabicExplanation = app.profile.shouldShowArabicByDefault
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp100) {
            HStack(alignment: .firstTextBaseline, spacing: IMTheme.sp100) {
                Text("AI Teacher").imText(.heading5)
                IMBadge(
                    text: app.primaryOllamaModel.isEmpty ? "Offline knowledge" : app.primaryOllamaModel,
                    tint: app.primaryOllamaModel.isEmpty ? IMTheme.statusWarning : IMTheme.statusSuccess
                )
                Spacer(minLength: 0)
            }
            IMFlow(spacing: IMTheme.sp75) {
                Toggle("Arabic explanations", isOn: $includeArabicExplanation)
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .disabled(app.profile.languageMode == .englishImmersion)
                chip("Lesson from my mistakes", symbol: "arrow.uturn.backward") {
                    app.launchMistakeRevisionWithTeacher()
                }
                if let weak = app.weakestSkills.first {
                    chip("Teach me: \(weak.title)", symbol: "target") {
                        app.askTeacherToExplain(skillTag: weak.skillTag, module: weak.module)
                    }
                }
                chip("Task 2 cohesion drill", symbol: "pencil.line") {
                    send("Create a 5-minute Academic Writing Task 2 drill on cohesion and complex sentences, tailored to my profile and target band \(String(format: "%.1f", app.profile.targetBand)), with 2 short practice checks.")
                }
                chip("Explain a grammar rule", symbol: "textformat") {
                    send("Explain the difference between the present perfect and the past simple for IELTS writing, with 3 academic examples and 3 quick check questions.")
                }
            }
            if app.primaryOllamaModel.isEmpty {
                Text("No local model is connected, so answers come from the built-in IELTS knowledge base. For full conversations, start Ollama and pick a model in AI Model Manager.")
                    .imText(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, IMTheme.sp300)
        .padding(.vertical, IMTheme.sp200)
    }

    private func chip(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .imText(.caption1)
                .lineLimit(1)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule(style: .continuous).fill(IMTheme.elevatedBackground(colorScheme)))
        }
        .buttonStyle(.plain)
        .disabled(app.isStreamingTeacher)
    }

    // MARK: Conversation

    private var conversation: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: IMTheme.sp200) {
                    if app.teacherMessages.isEmpty && !app.isStreamingTeacher {
                        IMEmptyState(
                            icon: "person.bubble",
                            title: "Ask your teacher anything",
                            message: "Grammar rules, academic vocabulary, a sentence you're unsure about, or how to tackle a question type. Your recurring mistakes and your target band \(String(format: "%.1f", app.profile.targetBand)) are included automatically."
                        )
                    }
                    ForEach(app.teacherMessages) { msg in
                        bubble(msg).id(msg.id)
                    }
                    if app.isStreamingTeacher {
                        streamingBubble.id("streaming")
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(IMTheme.sp300)
                .frame(maxWidth: 900, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: app.teacherMessages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .onChange(of: app.streamingTeacherDraft) { _, _ in
                proxy.scrollTo("bottom", anchor: .bottom)
            }
            .onAppear { proxy.scrollTo("bottom", anchor: .bottom) }
        }
    }

    @ViewBuilder
    private func bubble(_ msg: TeacherMessage) -> some View {
        let isUser = msg.role == "user"
        HStack(alignment: .top) {
            if isUser { Spacer(minLength: 80) }
            VStack(alignment: .leading, spacing: IMTheme.sp75) {
                HStack(spacing: 6) {
                    Text(isUser ? "You" : "Teacher").imText(.caption3).foregroundStyle(isUser ? IMTheme.accentPrimary : IMTheme.brandTeal)
                    if let model = msg.modelUsed, !isUser {
                        Text(model).imText(.caption5).foregroundStyle(.tertiary)
                    }
                    Spacer(minLength: 0)
                    Text(msg.timestamp, style: .time).imText(.caption5).foregroundStyle(.tertiary)
                }
                Text(msg.content)
                    .font(.system(size: 14))
                    .lineSpacing(3)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                if let ar = msg.arabicContent, !ar.isEmpty {
                    IMArabicBlock(text: ar)
                }
                if !msg.citations.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sources").imText(.caption3).foregroundStyle(.secondary)
                        ForEach(msg.citations, id: \.self) { cite in
                            Text("• \(cite)").imText(.caption5).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(IMTheme.sp200)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isUser ? IMTheme.accentPrimary.opacity(colorScheme == .dark ? 0.22 : 0.10) : IMTheme.cardBackground(colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isUser ? Color.clear : IMTheme.borderColor(colorScheme), lineWidth: 1)
            )
            if !isUser { Spacer(minLength: 40) }
        }
    }

    private var streamingBubble: some View {
        VStack(alignment: .leading, spacing: IMTheme.sp75) {
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text("Teacher is writing…").imText(.caption3).foregroundStyle(.secondary)
                Spacer(minLength: 0)
                Button("Stop") { app.cancelTeacherStreaming() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
            if !app.streamingTeacherDraft.isEmpty {
                Text(app.streamingTeacherDraft)
                    .font(.system(size: 14))
                    .lineSpacing(3)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(IMTheme.sp200)
        .imSurface()
    }

    // MARK: Composer

    private var composer: some View {
        HStack(alignment: .bottom, spacing: IMTheme.sp100) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $inputPrompt)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 6)
                if inputPrompt.isEmpty {
                    Text("Ask a question or paste a sentence to check…")
                        .font(.system(size: 14))
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 64)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(IMTheme.elevatedBackground(colorScheme)))

            Button {
                submit()
            } label: {
                Label("Send", systemImage: "arrow.up.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: .command)
            .disabled(!canSend)
            .help("Send (⌘↩)")
        }
        .padding(.horizontal, IMTheme.sp300)
        .padding(.vertical, IMTheme.sp100)
    }

    private func submit() {
        guard canSend else { return }
        send(inputPrompt)
        inputPrompt = ""
    }

    private func send(_ text: String) {
        app.sendTeacherPrompt(text, requestArabic: includeArabicExplanation)
    }
}
