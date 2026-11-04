import AVFoundation
import Speech

/// Runs Apple's on-device SpeechTranscriber over a live audio source.
/// Finished phrases go to `text`; the phrase still being heard goes to
/// `pending` and is replaced as the recognizer revises it.
@MainActor
final class TranscriptionEngine: ObservableObject {
    @Published var text = ""
    @Published var pending = ""
    @Published var status = ""
    @Published var running = false

    /// Called with each finished phrase, after break words are applied.
    var onFinal: ((String) -> Void)?

    private var source: AudioSource?
    private var analyzer: SpeechAnalyzer?
    private var input: AsyncStream<AnalyzerInput>.Continuation?
    private var resultsTask: Task<Void, Never>?

    func start(_ kind: Source) async {
        guard !running else { return }
        running = true
        do {
            status = "Preparing speech recognition…"
            guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: Locale.current) else {
                throw CaptureError.failed("Speech recognition does not support \(Locale.current.identifier).")
            }
            let transcriber = SpeechTranscriber(
                locale: locale,
                transcriptionOptions: [],
                reportingOptions: [.volatileResults],
                attributeOptions: [])
            if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                status = "Downloading the speech model (one time)…"
                try await request.downloadAndInstall()
            }
            guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber]) else {
                throw CaptureError.failed("No audio format available for speech recognition.")
            }

            let (stream, continuation) = AsyncStream<AnalyzerInput>.makeStream()
            input = continuation
            let analyzer = SpeechAnalyzer(modules: [transcriber])
            self.analyzer = analyzer
            try await analyzer.prepareToAnalyze(in: format)

            resultsTask = Task { [weak self] in
                do {
                    for try await result in transcriber.results {
                        let phrase = String(result.text.characters)
                        self?.receive(phrase, final: result.isFinal)
                    }
                } catch {
                    self?.status = "Error: \(error.localizedDescription)"
                }
            }
            try await analyzer.start(inputSequence: stream)

            let converter = Converter(to: format)
            let source: AudioSource = kind == .mic ? MicSource() : SystemAudioSource()
            self.source = source
            try await source.start { buffer in
                if let converted = converter.convert(buffer) {
                    continuation.yield(AnalyzerInput(buffer: converted))
                }
            }
            status = kind == .mic ? "Listening to the microphone…" : "Listening to the Mac…"
        } catch {
            status = error.localizedDescription
            await stop()
        }
    }

    func stop() async {
        await source?.stop()
        source = nil
        input?.finish()
        input = nil
        try? await analyzer?.finalizeAndFinishThroughEndOfInput()
        analyzer = nil
        await resultsTask?.value
        resultsTask = nil
        if !pending.isEmpty { receive(pending, final: true) }
        running = false
        if !status.hasPrefix("Error") && !status.contains("is off") && !status.hasPrefix("No ") {
            status = "Stopped."
        }
    }

    func clear() {
        text = ""
        pending = ""
    }

    private func receive(_ phrase: String, final: Bool) {
        guard final else {
            pending = phrase
            return
        }
        pending = ""
        let cleaned = BreakWords.apply(phrase.trimmingCharacters(in: .whitespaces))
        guard !cleaned.isEmpty else { return }
        let joiner = text.isEmpty || text.hasSuffix("\n") || cleaned.hasPrefix("\n") ? "" : " "
        text += joiner + cleaned
        onFinal?(joiner + cleaned)
    }
}
