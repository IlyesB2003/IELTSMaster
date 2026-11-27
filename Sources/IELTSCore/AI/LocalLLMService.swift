import Foundation

public enum LLMError: Error, LocalizedError, Sendable {
    case invalidURL
    case serviceUnavailable(String)
    case noModelSelected
    case externalConsentRequired
    case missingAPIKey(String)
    case httpError(Int, String)
    case invalidJSONOutput(String)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid AI provider URL."
        case .serviceUnavailable(let m): return "Local AI service unavailable: \(m)"
        case .noModelSelected: return "No AI model is selected. Open AI Model Manager to choose a model."
        case .externalConsentRequired: return "External AI provider requires explicit user privacy consent in Settings."
        case .missingAPIKey(let p): return "No API key configured in macOS Keychain for \(p)."
        case .httpError(let code, let body): return "AI service returned HTTP \(code): \(body.prefix(200))"
        case .invalidJSONOutput(let msg): return "AI response did not match the required JSON schema: \(msg)"
        case .cancelled: return "Inference was cancelled."
        }
    }
}

public struct ChatTurn: Codable, Sendable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

/// Manages local Ollama model discovery, 16 GB Apple Silicon memory budgeting,
/// streaming chat inference with cancellation, structured JSON validation/retries,
/// and optional Keychain-authenticated external providers.
public final class LocalLLMService: @unchecked Sendable {
    private let session: URLSession
    private let keychain: KeychainService

    public init(session: URLSession = .shared, keychain: KeychainService = KeychainService()) {
        self.session = session
        self.keychain = keychain
    }

    // MARK: - Ollama Discovery & Health

    public func discoverOllamaModels(baseURL: String = "http://127.0.0.1:11434") async throws -> [LocalModelInfo] {
        guard let tagsURL = URL(string: "\(baseURL)/api/tags") else {
            throw LLMError.invalidURL
        }
        var request = URLRequest(url: tagsURL)
        request.timeoutInterval = 8

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw LLMError.serviceUnavailable(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw LLMError.serviceUnavailable("Ollama did not return HTTP 200 on /api/tags.")
        }

        // Check currently loaded models (/api/ps) to flag active RAM usage
        let loadedNames = await fetchLoadedOllamaModelNames(baseURL: baseURL)

        struct OllamaTagsResponse: Decodable {
            struct ModelDetails: Decodable {
                let family: String?
                let parameter_size: String?
                let quantization_level: String?
            }
            struct ModelEntry: Decodable {
                let name: String
                let size: Int64?
                let details: ModelDetails?
            }
            let models: [ModelEntry]
        }

        let decoded = try JSONDecoder().decode(OllamaTagsResponse.self, from: data)
        return decoded.models.map { entry in
            let sizeBytes = entry.size ?? 0
            let estimatedRAM = max(1.2, (Double(sizeBytes) / 1_073_741_824.0) * 1.25)
            let family = inferFamily(name: entry.name, reported: entry.details?.family)
            let caps = inferCapabilities(name: entry.name, family: family)
            let ctx = inferContextWindow(name: entry.name, family: family)
            return LocalModelInfo(
                id: entry.name,
                name: entry.name,
                family: family,
                sizeBytes: sizeBytes,
                parameterSize: entry.details?.parameter_size ?? "Unknown",
                quantization: entry.details?.quantization_level ?? "Unknown",
                estimatedRAMGB: (estimatedRAM * 10).rounded() / 10,
                contextWindow: ctx,
                capabilities: caps,
                tokensPerSecond: nil,
                isLoaded: loadedNames.contains(entry.name)
            )
        }
    }

    private func fetchLoadedOllamaModelNames(baseURL: String) async -> Set<String> {
        guard let url = URL(string: "\(baseURL)/api/ps") else { return [] }
        var req = URLRequest(url: url)
        req.timeoutInterval = 4
        guard let (data, _) = try? await session.data(for: req),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let models = json["models"] as? [[String: Any]] else {
            return []
        }
        return Set(models.compactMap { $0["name"] as? String })
    }

    /// Recommends the best available local model for a role on a 16 GB Apple Silicon Mac,
    /// avoiding models that exceed comfortable unified memory limits.
    public func recommendModel(for role: ModelTaskRole, from available: [LocalModelInfo]) -> LocalModelInfo? {
        let fitting = available.filter { $0.fitsComfortablyIn16GB }
        let pool = fitting.isEmpty ? available : fitting
        guard !pool.isEmpty else { return nil }

        return pool.max { lhs, rhs in
            scoreModel(lhs, for: role) < scoreModel(rhs, for: role)
        }
    }

    private func scoreModel(_ model: LocalModelInfo, for role: ModelTaskRole) -> Double {
        var score = 0.0
        let lower = model.name.lowercased()
        // Prefer strong multilingual & reasoning families (Qwen, Gemma, Llama, DeepSeek, Mistral)
        if role == .arabicExplanation {
            if lower.contains("qwen") || lower.contains("gemma") || lower.contains("aya") { score += 30 }
        } else if role == .writingEvaluator || role == .contentVerification {
            if lower.contains("qwen") || lower.contains("deepseek") || lower.contains("llama") { score += 25 }
        } else {
            if lower.contains("qwen") || lower.contains("llama") || lower.contains("gemma") || lower.contains("mistral") { score += 20 }
        }
        // Sweet spot for 16 GB M4: 4 GB – 9.5 GB footprint
        if model.estimatedRAMGB >= 3.5 && model.estimatedRAMGB <= 9.5 {
            score += 15
        } else if model.estimatedRAMGB > 11.5 {
            score -= 20
        }
        if model.isLoaded { score += 5 }
        return score
    }

    public func benchmarkModel(_ modelName: String, baseURL: String = "http://127.0.0.1:11434") async throws -> Double {
        let start = Date()
        let result = try await generateOllamaChat(
            baseURL: baseURL,
            model: modelName,
            messages: [ChatTurn(role: "user", content: "Write one academic sentence explaining photosynthesis.")],
            jsonMode: false
        )
        let elapsed = max(0.05, Date().timeIntervalSince(start))
        let approxTokens = Double(max(1, result.split { $0.isWhitespace }.count)) * 1.3
        return (approxTokens / elapsed * 10).rounded() / 10
    }

    // MARK: - Chat & Streaming Inference

    public func streamChat(
        config: ModelRoutingConfiguration,
        role: ModelTaskRole,
        fallbackModel: String,
        messages: [ChatTurn],
        externalConsentGranted: Bool,
        onToken: @escaping @Sendable (String) -> Void
    ) async throws -> String {
        if config.activeProvider.isExternal {
            guard externalConsentGranted else {
                throw LLMError.externalConsentRequired
            }
            let full = try await completeExternalProvider(
                provider: config.activeProvider,
                model: config.externalModelName,
                messages: messages
            )
            onToken(full)
            return full
        }

        let model = config.model(for: role, fallback: fallbackModel)
        guard !model.isEmpty else { throw LLMError.noModelSelected }
        guard let url = URL(string: "\(config.ollamaBaseURL)/api/chat") else {
            throw LLMError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 240

        let payload: [String: Any] = [
            "model": model,
            "stream": true,
            "keep_alive": config.maxConcurrentLoadedModels <= 1 ? "2m" : "5m",
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw LLMError.serviceUnavailable("Ollama chat endpoint returned an error.")
        }

        var accumulated = ""
        for try await line in bytes.lines {
            if Task.isCancelled { throw LLMError.cancelled }
            guard let data = line.data(using: .utf8),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let msg = obj["message"] as? [String: Any],
                  let chunk = msg["content"] as? String else { continue }
            accumulated += chunk
            onToken(chunk)
        }
        return accumulated
    }

    /// Requests a structured JSON response and decodes it with retry & fenced-block extraction.
    public func requestStructuredJSON<T: Decodable>(
        _ type: T.Type,
        config: ModelRoutingConfiguration,
        role: ModelTaskRole,
        fallbackModel: String,
        systemPrompt: String,
        userPrompt: String,
        externalConsentGranted: Bool,
        maxRetries: Int = 2
    ) async throws -> T {
        var lastError: Error = LLMError.invalidJSONOutput("No attempts executed.")
        for attempt in 0...maxRetries {
            let messages = [
                ChatTurn(role: "system", content: systemPrompt + "\nReturn ONLY valid JSON with no markdown prose outside the JSON object."),
                ChatTurn(role: "user", content: attempt == 0 ? userPrompt : "\(userPrompt)\n\nPrevious attempt failed JSON validation. Return strictly valid JSON matching the exact schema.")
            ]
            do {
                let raw: String
                if config.activeProvider.isExternal {
                    guard externalConsentGranted else { throw LLMError.externalConsentRequired }
                    raw = try await completeExternalProvider(
                        provider: config.activeProvider,
                        model: config.externalModelName,
                        messages: messages
                    )
                } else {
                    let model = config.model(for: role, fallback: fallbackModel)
                    guard !model.isEmpty else { throw LLMError.noModelSelected }
                    raw = try await generateOllamaChat(
                        baseURL: config.ollamaBaseURL,
                        model: model,
                        messages: messages,
                        jsonMode: true
                    )
                }
                return try Self.decodeStructuredJSON(type, from: raw)
            } catch {
                lastError = error
            }
        }
        throw lastError
    }

    /// Deterministic JSON extractor supporting raw JSON or ```json fenced responses.
    public static func decodeStructuredJSON<T: Decodable>(_ type: T.Type, from rawOutput: String) throws -> T {
        let trimmed = rawOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        var candidate = trimmed

        if let fenceStart = trimmed.range(of: "```json"),
           let fenceEnd = trimmed.range(of: "```", range: fenceStart.upperBound..<trimmed.endIndex) {
            candidate = String(trimmed[fenceStart.upperBound..<fenceEnd.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let firstBrace = trimmed.firstIndex(of: "{"),
                  let lastBrace = trimmed.lastIndex(of: "}") {
            candidate = String(trimmed[firstBrace...lastBrace])
        }

        guard let data = candidate.data(using: .utf8) else {
            throw LLMError.invalidJSONOutput("Could not encode candidate JSON as UTF-8.")
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw LLMError.invalidJSONOutput(error.localizedDescription)
        }
    }

    private func generateOllamaChat(
        baseURL: String,
        model: String,
        messages: [ChatTurn],
        jsonMode: Bool
    ) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/chat") else { throw LLMError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 180

        var body: [String: Any] = [
            "model": model,
            "stream": false,
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        if jsonMode {
            body["format"] = "json"
        }
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, res) = try await session.data(for: req)
        guard let http = res as? HTTPURLResponse else {
            throw LLMError.serviceUnavailable("No HTTP response from Ollama.")
        }
        guard (200...299).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? ""
            throw LLMError.httpError(http.statusCode, text)
        }
        guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let msg = obj["message"] as? [String: Any],
              let content = msg["content"] as? String else {
            throw LLMError.invalidJSONOutput("Missing message.content from Ollama.")
        }
        return content
    }

    private func completeExternalProvider(
        provider: AIProviderKind,
        model: String,
        messages: [ChatTurn]
    ) async throws -> String {
        guard let apiKey = keychain.readSecret(account: provider.rawValue), !apiKey.isEmpty else {
            throw LLMError.missingAPIKey(provider.rawValue)
        }
        switch provider {
        case .openAI:
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { throw LLMError.invalidURL }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONSerialization.data(withJSONObject: [
                "model": model.isEmpty ? "gpt-4o-mini" : model,
                "messages": messages.map { ["role": $0.role, "content": $0.content] }
            ])
            let (data, res) = try await session.data(for: req)
            guard let http = res as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw LLMError.httpError((res as? HTTPURLResponse)?.statusCode ?? 0, String(data: data, encoding: .utf8) ?? "")
            }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let choices = json?["choices"] as? [[String: Any]]
            let msg = choices?.first?["message"] as? [String: Any]
            return msg?["content"] as? String ?? ""

        case .anthropic:
            guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { throw LLMError.invalidURL }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let sys = messages.filter { $0.role == "system" }.map(\.content).joined(separator: "\n")
            let nonSys = messages.filter { $0.role != "system" }.map { ["role": $0.role, "content": $0.content] }
            req.httpBody = try JSONSerialization.data(withJSONObject: [
                "model": model.isEmpty ? "claude-3-5-sonnet-latest" : model,
                "max_tokens": 1800,
                "system": sys,
                "messages": nonSys
            ])
            let (data, res) = try await session.data(for: req)
            guard let http = res as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw LLMError.httpError((res as? HTTPURLResponse)?.statusCode ?? 0, String(data: data, encoding: .utf8) ?? "")
            }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let content = json?["content"] as? [[String: Any]]
            return content?.first?["text"] as? String ?? ""

        case .gemini:
            let modelID = model.isEmpty ? "gemini-2.5-flash" : model
            guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(modelID):generateContent?key=\(apiKey)") else {
                throw LLMError.invalidURL
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let combined = messages.map { "\($0.role.uppercased()): \($0.content)" }.joined(separator: "\n\n")
            req.httpBody = try JSONSerialization.data(withJSONObject: [
                "contents": [["parts": [["text": combined]]]]
            ])
            let (data, res) = try await session.data(for: req)
            guard let http = res as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw LLMError.httpError((res as? HTTPURLResponse)?.statusCode ?? 0, String(data: data, encoding: .utf8) ?? "")
            }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let candidates = json?["candidates"] as? [[String: Any]]
            let content = candidates?.first?["content"] as? [String: Any]
            let parts = content?["parts"] as? [[String: Any]]
            return parts?.first?["text"] as? String ?? ""

        case .ollama:
            return ""
        }
    }

    private func inferFamily(name: String, reported: String?) -> String {
        if let reported, !reported.isEmpty { return reported.capitalized }
        let lower = name.lowercased()
        if lower.contains("qwen") { return "Qwen" }
        if lower.contains("llama") { return "Llama" }
        if lower.contains("gemma") { return "Gemma" }
        if lower.contains("deepseek") { return "DeepSeek" }
        if lower.contains("mistral") || lower.contains("mixtral") { return "Mistral" }
        return "Local LLM"
    }

    private func inferCapabilities(name: String, family: String) -> [String] {
        var caps = ["Chat", "Structured JSON", "Grammar"]
        let lower = name.lowercased()
        if lower.contains("qwen") || lower.contains("gemma") || lower.contains("llama") {
            caps.append("Arabic Support")
        }
        if lower.contains("embed") {
            caps = ["Embeddings"]
        }
        return caps
    }

    private func inferContextWindow(name: String, family: String) -> Int {
        let lower = name.lowercased()
        if lower.contains("qwen2.5") || lower.contains("qwen3") { return 32768 }
        if lower.contains("llama3") { return 8192 }
        if lower.contains("gemma") { return 8192 }
        if lower.contains("mistral") { return 32768 }
        return 8192
    }
}
