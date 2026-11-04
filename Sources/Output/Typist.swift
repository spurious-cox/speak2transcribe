import AppKit
import CoreGraphics

/// Types text as keystrokes into whatever app is frontmost, at its cursor.
/// The clipboard is not used. Line breaks are sent as Shift-Return, which chat
/// boxes take as a new line rather than Send.
///
/// Posting keystrokes needs the user's permission (listed under Privacy &
/// Security ▸ Device Control and Data Access — Accessibility before macOS 27).
enum Typist {
    private static let queue = DispatchQueue(label: "Speak2Transcribe.Typist")
    private static let returnKey: CGKeyCode = 36

    static var allowed: Bool { CGPreflightPostEventAccess() }

    /// Shows the system prompt the first time; returns whether access is on.
    @discardableResult
    static func requestAccess() -> Bool { CGRequestPostEventAccess() }

    /// Never type into ourselves: the window or panel would receive it.
    static var targetIsElsewhere: Bool {
        NSWorkspace.shared.frontmostApplication?.processIdentifier
            != ProcessInfo.processInfo.processIdentifier
    }

    static func type(_ text: String) {
        guard allowed, targetIsElsewhere, !text.isEmpty else { return }
        queue.async {
            let source = CGEventSource(stateID: .hidSystemState)
            for (index, line) in text.components(separatedBy: "\n").enumerated() {
                if index > 0 { press(returnKey, flags: .maskShift, source: source) }
                typeChunks(line, source: source)
            }
        }
    }

    private static func typeChunks(_ line: String, source: CGEventSource?) {
        // A keyboard event carries at most 20 UTF-16 units.
        var units = Array(line.utf16)[...]
        while !units.isEmpty {
            let chunk = Array(units.prefix(20))
            units = units.dropFirst(chunk.count)
            for down in [true, false] {
                guard let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: down) else { continue }
                event.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: chunk)
                event.post(tap: .cghidEventTap)
            }
            usleep(3_000)
        }
    }

    private static func press(_ key: CGKeyCode, flags: CGEventFlags, source: CGEventSource?) {
        for down in [true, false] {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: down) else { continue }
            event.flags = flags
            event.post(tap: .cghidEventTap)
        }
        usleep(3_000)
    }
}
