import Foundation
import AVFoundation
import Speech

/// Native macOS audio recording, playback, waveform metering, acoustic pause analysis,
/// multi-accent AVSpeechSynthesizer TTS, and optional on-device SFSpeechRecognizer transcription.
public final class AudioEngineService: NSObject, ObservableObject, @unchecked Sendable {
    @Published public private(set) var isRecording: Bool = false
    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var isSpeakingTTS: Bool = false
    @Published public private(set) var waveformSamples: [Float] = []
    @Published public private(set) var lastRecordingDuration: Double = 0
    @Published public private(set) var lastPauseRatio: Double = 0
    @Published public private(set) var liveTranscript: String = ""
    @Published public private(set) var audioStatusMessage: String = "Audio system ready."

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()
    private var meteringTask: Task<Void, Never>?
    private var recordingStartDate: Date?
    private var activeRecordingURL: URL?
    private var silentSampleCount: Int = 0
    private var totalSampleCount: Int = 0

    public override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Multi-Accent Native TTS

    public func speak(text: String, accent: EnglishAccent = .british, rate: Float = 0.49) {
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = bestVoice(for: accent)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        DispatchQueue.main.async {
            self.isSpeakingTTS = true
            self.audioStatusMessage = "Playing \(accent.displayName) audio."
        }
        synthesizer.speak(utterance)
    }

    public func speakDialogue(_ turns: [DialogueTurn], rate: Float = 0.49) {
        stopSpeaking()
        guard !turns.isEmpty else { return }
        DispatchQueue.main.async {
            self.isSpeakingTTS = true
            self.audioStatusMessage = "Playing multi-speaker IELTS Listening recording."
        }
        for (idx, turn) in turns.enumerated() {
            let utterance = AVSpeechUtterance(string: turn.text)
            utterance.voice = bestVoice(for: turn.accent)
            utterance.rate = rate
            // Subtle pitch differentiation between speakers
            utterance.pitchMultiplier = idx % 2 == 0 ? 1.0 : 1.08
            utterance.postUtteranceDelay = 0.45
            synthesizer.speak(utterance)
        }
    }

    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        DispatchQueue.main.async {
            self.isSpeakingTTS = false
        }
    }

    private func bestVoice(for accent: EnglishAccent) -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.lowercased().hasPrefix(accent.rawValue.lowercased()) }
        if let enhanced = voices.first(where: { $0.quality == .enhanced }) {
            return enhanced
        }
        return voices.first ?? AVSpeechSynthesisVoice(language: accent.rawValue) ?? AVSpeechSynthesisVoice(language: "en-GB")
    }

    // MARK: - Microphone Recording & Waveform Metering

    public func recordingsDirectory() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let dir = appSupport.appendingPathComponent("IELTSMaster/Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    public func startRecording(prefix: String = "speaking") -> URL? {
        stopSpeaking()
        stopPlayback()

        let fileName = "\(prefix)_\(Int(Date().timeIntervalSince1970)).m4a"
        let url = recordingsDirectory().appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.isMeteringEnabled = true
            guard recorder.record() else {
                DispatchQueue.main.async {
                    self.audioStatusMessage = "Microphone recording could not start. Check macOS Microphone permissions in System Settings."
                }
                return nil
            }
            self.audioRecorder = recorder
            self.activeRecordingURL = url
            self.recordingStartDate = Date()
            self.silentSampleCount = 0
            self.totalSampleCount = 0

            DispatchQueue.main.async {
                self.waveformSamples = []
                self.isRecording = true
                self.audioStatusMessage = "Recording audio..."
            }

            meteringTask?.cancel()
            meteringTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 80_000_000)
                    guard let self, let rec = self.audioRecorder, rec.isRecording else { break }
                    rec.updateMeters()
                    let power = rec.averagePower(forChannel: 0) // -160 .. 0 dB
                    let normalized = max(0.02, min(1.0, (power + 55.0) / 55.0))
                    self.totalSampleCount += 1
                    if power < -42.0 {
                        self.silentSampleCount += 1
                    }
                    await MainActor.run {
                        self.waveformSamples.append(normalized)
                        if self.waveformSamples.count > 80 {
                            self.waveformSamples.removeFirst()
                        }
                    }
                }
            }
            return url
        } catch {
            DispatchQueue.main.async {
                self.audioStatusMessage = "Recording unavailable: \(error.localizedDescription)"
            }
            return nil
        }
    }

    public func stopRecording() -> (url: URL?, duration: Double, pauseRatio: Double) {
        meteringTask?.cancel()
        audioRecorder?.stop()
        let duration = recordingStartDate.map { Date().timeIntervalSince($0) } ?? 0
        let pauseRatio = totalSampleCount > 0 ? Double(silentSampleCount) / Double(totalSampleCount) : 0.0
        let url = activeRecordingURL

        DispatchQueue.main.async {
            self.isRecording = false
            self.lastRecordingDuration = duration
            self.lastPauseRatio = pauseRatio
            self.audioStatusMessage = String(format: "Recording saved (%.1fs).", duration)
        }
        return (url, duration, pauseRatio)
    }

    // MARK: - Playback

    public func playRecording(at url: URL) {
        stopSpeaking()
        stopPlayback()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.play()
            self.audioPlayer = player
            DispatchQueue.main.async {
                self.isPlaying = true
                self.audioStatusMessage = "Playing recorded audio."
            }
        } catch {
            DispatchQueue.main.async {
                self.audioStatusMessage = "Could not play audio file: \(error.localizedDescription)"
            }
        }
    }

    public func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }

    // MARK: - On-Device Speech Transcription (Apple Speech)

    public func transcribeAudioFile(at url: URL, localeIdentifier: String = "en-US") async -> String {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)), recognizer.isAvailable else {
            return ""
        }
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        if authStatus == .denied || authStatus == .restricted {
            return ""
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        return await withCheckedContinuation { continuation in
            var resumed = false
            recognizer.recognitionTask(with: request) { result, error in
                guard !resumed else { return }
                if let result, result.isFinal {
                    resumed = true
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else if error != nil {
                    resumed = true
                    continuation.resume(returning: "")
                }
            }
        }
    }
}

extension AudioEngineService: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !synthesizer.isSpeaking {
            DispatchQueue.main.async {
                self.isSpeakingTTS = false
            }
        }
    }
}

extension AudioEngineService: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
