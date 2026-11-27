import Foundation

/// Intelligent AI Teacher orchestrator grounded in RAG IELTS knowledge,
/// persistent learner memory (recurring mistakes, grammar mastery, diagnostic band),
/// and strict English/Arabic pedagogical rules.
public final class AITeacherService: @unchecked Sendable {
    private let llm: LocalLLMService
    private let rag: RAGService

    public init(llm: LocalLLMService, rag: RAGService) {
        self.llm = llm
        self.rag = rag
    }

    public func buildSystemPrompt(
        profile: LearnerProfile,
        recurringMistakes: [MistakeEntry],
        ragContext: String,
        requestArabicExplanation: Bool
    ) -> String {
        let weaknessSummary = recurringMistakes.prefix(5)
            .map { "- \($0.errorCategory) (\($0.recurrenceCount)x): \($0.relatedGrammarRule)" }
            .joined(separator: "\n")

        let arabicInstruction: String
        if profile.languageMode == .englishImmersion {
            arabicInstruction = "Respond strictly in English. Do not include Arabic."
        } else if requestArabicExplanation || profile.shouldShowArabicByDefault {
            arabicInstruction = "Respond primarily in clear academic English, and include a concise Arabic explanation section at the end labeled 'الشرح بالعربية:' to clarify complex grammar or vocabulary concepts. Never use any language other than English and Arabic."
        } else {
            arabicInstruction = "Respond in English only unless the learner explicitly asks for an Arabic explanation. Never use French or any third language."
        }

        return """
        You are IELTS Master AI Teacher, a senior IELTS Academic instructor and applied linguistics specialist.
        Learner Profile:
        - Current estimated IELTS band: \(String(format: "%.1f", profile.estimatedOverallBand)) (CEFR approx. \(profile.estimatedCEFR.rawValue), confidence: \(profile.assessmentConfidence.rawValue))
        - Target IELTS Academic band: \(String(format: "%.1f", profile.targetBand))
        - Academic interests: \(profile.academicInterests.joined(separator: ", "))
        - Professional objective: \(profile.professionalGoal)
        - Recurring error patterns detected in learner history:
        \(weaknessSummary.isEmpty ? "- No recurring mistakes recorded yet." : weaknessSummary)

        Pedagogical Rules:
        1. Teach rather than simply rewriting. Explain WHY mistakes occur and verify understanding with 1–2 short practice checks.
        2. Ground IELTS advice in the official public criteria retrieved below. Never claim to be an official IELTS examiner or guarantee a band score.
        3. \(arabicInstruction)

        Retrieved Verified Reference Context:
        \(ragContext.isEmpty ? "No external context retrieved." : ragContext)
        """
    }

    public func askTeacher(
        question: String,
        history: [TeacherMessage],
        profile: LearnerProfile,
        mistakes: [MistakeEntry],
        config: ModelRoutingConfiguration,
        fallbackModel: String,
        requestArabic: Bool,
        onToken: @escaping @Sendable (String) -> Void
    ) async -> TeacherMessage {
        let (ragContext, citations) = rag.buildGroundedContext(for: question, topK: 3)
        let recurring = mistakes.filter { $0.isRecurringPattern || $0.masteryStatus != .mastered }
        let system = buildSystemPrompt(
            profile: profile,
            recurringMistakes: recurring,
            ragContext: ragContext,
            requestArabicExplanation: requestArabic
        )

        var turns: [ChatTurn] = [ChatTurn(role: "system", content: system)]
        for msg in history.suffix(8) {
            turns.append(ChatTurn(role: msg.role, content: msg.content))
        }
        turns.append(ChatTurn(role: "user", content: question))

        do {
            let role: ModelTaskRole = requestArabic ? .arabicExplanation : .aiTeacher
            let reply = try await llm.streamChat(
                config: config,
                role: role,
                fallbackModel: fallbackModel,
                messages: turns,
                externalConsentGranted: profile.externalAIConsentGranted,
                onToken: onToken
            )
            return TeacherMessage(
                role: "assistant",
                content: reply,
                citations: citations,
                modelUsed: config.activeProvider == .ollama ? config.model(for: role, fallback: fallbackModel) : config.activeProvider.rawValue
            )
        } catch {
            // Deterministic offline grounded pedagogical fallback so the user always gets actionable help
            let fallbackText = buildOfflineGroundedResponse(
                question: question,
                ragContext: ragContext,
                recurring: recurring,
                includeArabic: requestArabic && profile.languageMode != .englishImmersion,
                errorReason: error.localizedDescription
            )
            onToken(fallbackText)
            return TeacherMessage(
                role: "assistant",
                content: fallbackText,
                citations: citations,
                modelUsed: "Offline Knowledge Engine"
            )
        }
    }

    private func buildOfflineGroundedResponse(
        question: String,
        ragContext: String,
        recurring: [MistakeEntry],
        includeArabic: Bool,
        errorReason: String
    ) -> String {
        var lines: [String] = []
        lines.append("Local AI inference is currently unavailable (\(errorReason)). Here is a grounded response from your verified offline IELTS knowledge base:")
        lines.append("")
        if !ragContext.isEmpty {
            lines.append("Verified Reference Guidance:")
            lines.append(ragContext)
            lines.append("")
        }
        if !recurring.isEmpty {
            lines.append("Relevant Recurring Priorities in Your Mistake Notebook:")
            for item in recurring.prefix(3) {
                lines.append("• \(item.errorCategory): \(item.relatedGrammarRule) (recorded \(item.recurrenceCount) time(s))")
            }
            lines.append("")
        }
        lines.append("Next Practice Check: Write 2 original academic sentences applying this rule, then open Writing or Grammar to verify accuracy.")
        if includeArabic {
            lines.append("")
            lines.append("الشرح بالعربية:")
            lines.append("نموذج الذكاء الاصطناعي المحلي غير متصل حالياً، لذلك تم استرجاع الإرشادات المعتمدة من قاعدة المعرفة المحلية. يمكنك تشغيل Ollama وتحديث قائمة النماذج في مدير النماذج للحصول على شروحات تفاعلية مخصصة.")
        }
        return lines.joined(separator: "\n")
    }
}
