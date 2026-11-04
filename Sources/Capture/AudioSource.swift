import AVFoundation

/// Where audio comes from: the sound the Mac is playing, or the microphone.
enum Source: String, CaseIterable, Identifiable {
    case mac = "Mac"
    case mic = "Mic"
    var id: String { rawValue }

    var readyText: String {
        switch self {
        case .mac: "Ready. Captures whatever the Mac is playing."
        case .mic: "Ready. Captures what you say into the microphone."
        }
    }
}

/// A running capture. Buffers are delivered in whatever format the hardware
/// gives; `Converter` turns them into the format the transcriber wants.
protocol AudioSource: AnyObject {
    func start(_ deliver: @escaping @Sendable (AVAudioPCMBuffer) -> Void) async throws
    func stop() async
}

/// Converts buffers to one fixed format, e.g. 16 kHz mono for speech.
final class Converter: @unchecked Sendable {
    let output: AVAudioFormat
    private var converter: AVAudioConverter?
    private var inputFormat: AVAudioFormat?

    init(to output: AVAudioFormat) { self.output = output }

    func convert(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        if buffer.format == output { return buffer }
        if inputFormat != buffer.format {
            converter = AVAudioConverter(from: buffer.format, to: output)
            inputFormat = buffer.format
        }
        guard let converter else { return nil }
        let ratio = output.sampleRate / buffer.format.sampleRate
        let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio + 1024)
        guard let out = AVAudioPCMBuffer(pcmFormat: output, frameCapacity: capacity) else { return nil }
        var fed = false
        var error: NSError?
        converter.convert(to: out, error: &error) { _, status in
            if fed {
                status.pointee = .noDataNow
                return nil
            }
            fed = true
            status.pointee = .haveData
            return buffer
        }
        return error == nil && out.frameLength > 0 ? out : nil
    }
}
