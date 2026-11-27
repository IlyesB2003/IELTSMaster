import Foundation

/// Deterministic countdown timer engine for official IELTS timing rules.
public final class ExamTimerEngine: ObservableObject, @unchecked Sendable {
    public enum State: String, Sendable, Equatable {
        case idle
        case running
        case paused
        case finished
    }

    @Published public private(set) var totalSeconds: Int
    @Published public private(set) var remainingSeconds: Int
    @Published public private(set) var state: State = .idle
    public let allowsPause: Bool

    private var timerTask: Task<Void, Never>?
    private var onExpire: (@Sendable () -> Void)?

    public init(durationSeconds: Int, allowsPause: Bool = false) {
        self.totalSeconds = max(0, durationSeconds)
        self.remainingSeconds = max(0, durationSeconds)
        self.allowsPause = allowsPause
    }

    public var elapsedSeconds: Int {
        max(0, totalSeconds - remainingSeconds)
    }

    public var progress: Double {
        guard totalSeconds > 0 else { return 1.0 }
        return Double(elapsedSeconds) / Double(totalSeconds)
    }

    public var formattedRemaining: String {
        let hrs = remainingSeconds / 3600
        let mins = (remainingSeconds % 3600) / 60
        let secs = remainingSeconds % 60
        if hrs > 0 {
            return String(format: "%d:%02d:%02d", hrs, mins, secs)
        }
        return String(format: "%02d:%02d", mins, secs)
    }

    public func start(onExpire: (@Sendable () -> Void)? = nil) {
        guard state == .idle || state == .paused else { return }
        if let onExpire { self.onExpire = onExpire }
        state = .running
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                guard let self else { break }
                let finished = await MainActor.run { () -> Bool in
                    self.tick()
                }
                if finished { break }
            }
        }
    }

    /// Advances timer by 1 second deterministically (also callable directly in unit tests).
    @discardableResult
    public func tick() -> Bool {
        guard state == .running else { return false }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        }
        if remainingSeconds == 0 {
            state = .finished
            timerTask?.cancel()
            onExpire?()
            return true
        }
        return false
    }

    public func pause() {
        guard allowsPause, state == .running else { return }
        state = .paused
        timerTask?.cancel()
    }

    public func stop() {
        timerTask?.cancel()
        state = .finished
    }

    public func reset(durationSeconds: Int) {
        timerTask?.cancel()
        totalSeconds = max(0, durationSeconds)
        remainingSeconds = max(0, durationSeconds)
        state = .idle
    }

    deinit {
        timerTask?.cancel()
    }
}
