import AVFoundation

/// The default microphone, through AVAudioEngine.
final class MicSource: AudioSource {
    private let engine = AVAudioEngine()

    func start(_ deliver: @escaping @Sendable (AVAudioPCMBuffer) -> Void) async throws {
        guard await AVCaptureDevice.requestAccess(for: .audio) else {
            throw CaptureError.denied("Microphone access is off. Turn on Transcriber in System Settings ▸ Privacy & Security ▸ Microphone.")
        }
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, _ in
            deliver(buffer)
        }
        engine.prepare()
        try engine.start()
    }

    func stop() async {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
    }
}

enum CaptureError: LocalizedError {
    case denied(String)
    case failed(String)
    var errorDescription: String? {
        switch self {
        case .denied(let s), .failed(let s): s
        }
    }
}
