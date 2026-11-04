import SwiftUI

/// Help ▸ Speak2Transcribe Help: short usage notes, one section per control.
struct HelpView: View {
    private let sections: [(String, String)] = [
        ("Getting started",
         "Choose Mac to transcribe whatever this Mac is playing, or Mic to transcribe what you say into the microphone. Click Capture (or press ⌘Return). Words appear as they are heard — gray while the recognizer is still settling on them. Click Stop to finish."),
        ("First use",
         "The first Capture downloads Apple's on-device speech model for your Mac's language. That happens once."),
        ("Line breaks",
         "Say “new line” to start a new line, or “new paragraph” to leave a blank line."),
        ("Clear, Save…, Copy",
         "Clear empties the text. Save… writes it to a text file. Copy puts it on the clipboard."),
        ("Floating",
         "Swaps the window for a small panel that stays in front of other apps without taking focus from them. Click Full Window, or close the panel, to come back."),
        ("Type at cursor",
         "In the floating panel: click into a text field in another app, then Capture. Each finished phrase is typed there as if from the keyboard. Nothing is typed into Speak2Transcribe itself, and the clipboard is not used. Line breaks are sent as Shift-Return, so chat boxes don't send."),
        ("Permissions",
         "System Settings ▸ Privacy & Security:\n• Screen & System Audio Recording — for Mac\n• Microphone — for Mic\n• Device Control and Data Access — for Type at cursor\nAfter turning one on, quit and reopen Speak2Transcribe."),
        ("Privacy",
         "Everything is transcribed on this Mac by Apple's speech recognizer. Nothing is sent anywhere."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(sections, id: \.0) { title, text in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title).font(.headline)
                        Text(text).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .frame(minWidth: 380, minHeight: 300)
    }
}
