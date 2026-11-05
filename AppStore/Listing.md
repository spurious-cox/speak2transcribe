# Speak2Transcribe — App Store Connect listing (draft)

Character limits are App Store Connect's. Paste each field as is.

## App information

| Field | Value |
|---|---|
| Name (30) | Speak2Transcribe |
| Subtitle (30) | Speech to text, at your cursor |
| Bundle ID | com.timmccoy.speak2transcribe |
| SKU | SPEAK2TRANSCRIBE-MAC |
| Primary language | English (U.S.) |
| Primary category | Productivity |
| Secondary category | Utilities |
| Content rights | Does not contain, show or access third-party content |
| Age rating | 4+ (answer "None" to every question) |
| Copyright | 2026 Tim McCoy |
| Price | _to decide_ |
| Privacy policy URL | _to decide_ |
| Support URL | _to decide_ |

## Promotional text (170)

Talk, and your words appear — in the window, or typed straight into whatever app you're using. Private by design: everything is transcribed on your Mac.

## Description (4000)

Speak2Transcribe turns speech into text on your Mac, live, and privately.

Choose what to listen to:
• Mic — what you say into the microphone
• Mac — whatever your Mac is playing: a video, a podcast, a meeting

Words appear as they're heard and settle as the recognizer becomes sure of them.

TYPE AT CURSOR
Switch to the small floating panel and turn on Type at cursor. Click into any text field — Mail, Messages, Notes, a chat box, a document — and start talking. Each phrase is typed right where your cursor is, as if from the keyboard. The panel stays in front without taking focus, and the clipboard is never touched.

SPOKEN LINE BREAKS
Say "new line" or "new paragraph". In chat boxes they're sent as Shift-Return, so nothing gets sent early.

PRIVATE
Transcription uses Apple's on-device speech recognition. Your audio and text never leave your Mac. No account, no subscription, no tracking.

ALSO
• Copy, Save and Clear the transcript
• Remembers your choices and window positions
• Follows light and dark mode
• Built-in help (⌘?) and tips on every control

Requires macOS 26 or later on Apple silicon.

## Keywords (100, comma-separated, no spaces)

dictation,transcribe,transcription,speech,voice,typing,captions,notes,meeting,podcast,microphone

## What's New (first version)

First release.

## App Privacy ("nutrition label")

Data collection: **No, we do not collect data from this app.**

## App Review information

Sign-in required: No.

Notes for the reviewer:

> Speak2Transcribe transcribes audio on-device with Apple's SpeechAnalyzer / SpeechTranscriber. Nothing is sent off the Mac.
>
> Permissions and why:
> • Microphone — the Mic source.
> • Screen & System Audio Recording — the Mac source, through ScreenCaptureKit, audio only. No screen images are captured or stored.
> • Post-event access (Device Control and Data Access / Accessibility) — the optional "Type at cursor" feature in the floating panel types the user's own transcribed words into the frontmost app's text field, using CGEvent keyboard events. It types nothing else, never reads other apps' content, and is off until the user turns it on.
>
> To try it: choose Mic, click Capture and speak. For Type at cursor: check Floating, check Type at cursor, click into TextEdit, then Capture and speak.

## Screenshots

Artwork/AppStore/Speak2Transcribe-2880x1800.png (any one of the four sizes is accepted).

## Before uploading a build

- Register the bundle ID com.timmccoy.speak2transcribe (Certificates, Identifiers & Profiles).
- Apple Distribution certificate + Mac App Store provisioning profile; `CODE_SIGN_IDENTITY` in project.yml → Apple Distribution.
- Archive (Release) and upload with Xcode Organizer or `xcodebuild -exportArchive` + `xcrun altool`/Transporter.
- `ITSAppUsesNonExemptEncryption = NO` in Info.plist (no encryption beyond Apple's).
