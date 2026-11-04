import AVFoundation
import ScreenCaptureKit

/// Everything the Mac is playing, through ScreenCaptureKit. Speak2Transcribe's own
/// sound is left out. Needs Screen & System Audio Recording permission.
final class SystemAudioSource: NSObject, AudioSource, SCStreamOutput, SCStreamDelegate, @unchecked Sendable {
    private var stream: SCStream?
    private var deliver: (@Sendable (AVAudioPCMBuffer) -> Void)?
    private let queue = DispatchQueue(label: "Speak2Transcribe.SystemAudio")

    func start(_ deliver: @escaping @Sendable (AVAudioPCMBuffer) -> Void) async throws {
        self.deliver = deliver
        let content: SCShareableContent
        do {
            content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        } catch {
            throw CaptureError.denied("Screen & System Audio Recording is off. Turn on Speak2Transcribe in System Settings ▸ Privacy & Security, then try again.")
        }
        guard let display = content.displays.first else {
            throw CaptureError.failed("No display found to capture audio from.")
        }
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        config.capturesAudio = true
        config.excludesCurrentProcessAudio = true
        config.sampleRate = 48_000
        config.channelCount = 1
        // Video is required by the API; keep it tiny and rare.
        config.width = 2
        config.height = 2
        config.minimumFrameInterval = CMTime(value: 1, timescale: 1)
        let stream = SCStream(filter: filter, configuration: config, delegate: self)
        try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: queue)
        try await stream.startCapture()
        self.stream = stream
    }

    func stop() async {
        try? await stream?.stopCapture()
        stream = nil
        deliver = nil
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sample: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio, sample.isValid, let buffer = Self.pcmBuffer(from: sample) else { return }
        deliver?(buffer)
    }

    static func pcmBuffer(from sample: CMSampleBuffer) -> AVAudioPCMBuffer? {
        guard let description = sample.formatDescription else { return nil }
        let format = AVAudioFormat(cmAudioFormatDescription: description)
        let frames = AVAudioFrameCount(sample.numSamples)
        guard frames > 0, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames) else { return nil }
        buffer.frameLength = frames
        let status = CMSampleBufferCopyPCMDataIntoAudioBufferList(
            sample, at: 0, frameCount: Int32(frames), into: buffer.mutableAudioBufferList)
        return status == noErr ? buffer : nil
    }
}
