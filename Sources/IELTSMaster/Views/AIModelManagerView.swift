import SwiftUI
import IELTSCore

public struct AIModelManagerView: View {
    @EnvironmentObject private var app: AppState
    @LocalState private var benchmarkOutput: [String: Double] = [:]
    @LocalState private var isBenchmarking: String?
    @LocalState private var externalAPIKeyInput: String = ""
    @LocalState private var keyStatusMessage: String = ""

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: IMTheme.sp300) {
                IMPageHeader(
                    title: "AI model manager",
                    subtitle: "Inspect local Ollama models, monitor 16 GB Apple Silicon unified memory fit, assign specialized models per task, and optionally configure Keychain-protected external providers.",
                    badgeText: app.modelRouting.activeProvider.rawValue
                )

                // Ollama Connection & Hardware Budget
                IMCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Local Ollama runtime").imText(.title2)
                            Text(app.ollamaStatus).imText(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Refresh local models") {
                            Task { await app.refreshOllamaModels() }
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    IMFlow(spacing: IMTheme.sp100) {
                        TextField("Ollama Base URL", text: $app.modelRouting.ollamaBaseURL)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 280)
                        Stepper("Max concurrent loaded models: \(app.modelRouting.maxConcurrentLoadedModels)", value: $app.modelRouting.maxConcurrentLoadedModels, in: 1...2)
                        Spacer()
                        Button("Save config") {
                            app.saveModelRoutingChanges()
                            app.statusBanner = "Model routing configuration saved."
                        }
                        .buttonStyle(.bordered)
                    }
                    Text("Optimized for MacBook Air M4 (16 GB unified memory): keep max concurrent loaded models at 1 to prevent unified memory pressure.")
                        .imText(.caption5)
                        .foregroundStyle(.secondary)
                }

                // Discovered Local Models
                IMCard {
                    Text("Discovered local models").imText(.title2)
                    if app.discoveredModels.isEmpty {
                        Text("No local Ollama models detected right now. Start Ollama (`ollama serve`) and install a 7B–9B model such as `ollama pull qwen2.5:7b` or `ollama pull llama3.1:8b`, then click Refresh.")
                            .imText(.body6)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(app.discoveredModels) { model in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(model.name).imText(.body4)
                                        IMBadge(text: model.family)
                                        IMBadge(
                                            text: model.fitsComfortablyIn16GB ? "16 GB Optimal" : "Heavy RAM",
                                            tint: model.fitsComfortablyIn16GB ? IMTheme.statusSuccess : IMTheme.statusWarning
                                        )
                                        if model.isLoaded {
                                            IMBadge(text: "Loaded", tint: IMTheme.accentPrimary)
                                        }
                                    }
                                    Text("Disk: \(model.formattedSize) • Est. RAM: ~\(String(format: "%.1f", model.estimatedRAMGB)) GB • Context: \(model.contextWindow) tokens • Capabilities: \(model.capabilities.joined(separator: ", "))")
                                        .imText(.caption5)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if let tps = benchmarkOutput[model.name] {
                                    IMBadge(text: "\(String(format: "%.1f", tps)) tok/s")
                                }
                                Button(isBenchmarking == model.name ? "Testing..." : "Benchmark") {
                                    Task {
                                        isBenchmarking = model.name
                                        if let speed = try? await app.llm.benchmarkModel(model.name, baseURL: app.modelRouting.ollamaBaseURL) {
                                            benchmarkOutput[model.name] = speed
                                        }
                                        isBenchmarking = nil
                                    }
                                }
                                .buttonStyle(.bordered)
                                .disabled(isBenchmarking != nil)
                            }
                            Divider()
                        }
                    }
                }

                // Per-Task Routing Matrix
                IMCard {
                    Text("Task-based model routing").imText(.title2)
                    ForEach(ModelTaskRole.allCases) { role in
                        HStack(alignment: .firstTextBaseline) {
                            Text(role.rawValue).imText(.body5)
                            Spacer()
                            Picker(role.rawValue, selection: Binding(
                                get: { app.modelRouting.roleAssignments[role.rawValue] ?? "" },
                                set: {
                                    app.modelRouting.roleAssignments[role.rawValue] = $0
                                    app.saveModelRoutingChanges()
                                }
                            )) {
                                Text("Automatic / Primary").tag("")
                                ForEach(app.discoveredModels) { m in
                                    Text(m.name).tag(m.name)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 260)
                        }
                    }
                }

                // Optional External Providers (Keychain + Explicit Consent)
                IMCard {
                    Text("Optional external AI providers").imText(.title2)
                    Picker("Active provider", selection: $app.modelRouting.activeProvider) {
                        ForEach(AIProviderKind.allCases) { p in
                            Text(p.rawValue).tag(p)
                        }
                    }
                    .frame(maxWidth: 340)
                    .onChange(of: app.modelRouting.activeProvider) { _, _ in
                        app.saveModelRoutingChanges()
                    }

                    Toggle("I explicitly consent to sending prompts/essays to the selected external AI provider", isOn: $app.profile.externalAIConsentGranted)
                        .onChange(of: app.profile.externalAIConsentGranted) { _, _ in
                            app.saveProfileChanges()
                        }

                    if app.modelRouting.activeProvider.isExternal {
                        HStack {
                            TextField("External model name (e.g. claude-3-5-sonnet-latest, gpt-4o-mini, gemini-2.5-flash)", text: $app.modelRouting.externalModelName)
                                .textFieldStyle(.roundedBorder)
                            Button("Save model") { app.saveModelRoutingChanges() }
                                .buttonStyle(.bordered)
                        }

                        HStack {
                            SecureField("API key for \(app.modelRouting.activeProvider.rawValue) (stored in macOS Keychain)", text: $externalAPIKeyInput)
                                .textFieldStyle(.roundedBorder)
                            Button("Store in Keychain") {
                                do {
                                    try app.keychain.saveSecret(externalAPIKeyInput, account: app.modelRouting.activeProvider.rawValue)
                                    externalAPIKeyInput = ""
                                    keyStatusMessage = "API key saved securely in macOS Keychain."
                                } catch {
                                    keyStatusMessage = error.localizedDescription
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(externalAPIKeyInput.isEmpty)

                            Button("Remove key") {
                                app.keychain.deleteSecret(account: app.modelRouting.activeProvider.rawValue)
                                keyStatusMessage = "API key removed from macOS Keychain."
                            }
                            .buttonStyle(.bordered)
                        }
                        if !keyStatusMessage.isEmpty {
                            Text(keyStatusMessage).imText(.caption4).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(IMTheme.sp400)
        }
    }
}
