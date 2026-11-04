# Speak2Transcribe.app — Swift rewrite plan (sketch)

A native, sandboxed, App Store–eligible successor to MyTranscribe. Separate app, separate bundle id; MyTranscribe stays as it is.

## Goals

- Same features as MyTranscribe 2.7.0: Mac / Mic sources, Capture, floating non-activating panel, Type at cursor, spoken "new line" / "new paragraph", Copy and Save.
- Self-contained: no Python, no source folder, no downloaded code.
- Small: no bundled 1 GB model.
- Passes App Store review: App Sandbox, Hardened Runtime, own preferences domain.

## Stack

| Piece | MyTranscribe | Speak2Transcribe |
|---|---|---|
| Language / UI | Python + PyObjC (AppKit) | Swift + SwiftUI, AppKit NSPanel for the floater |
| Speech-to-text | Whisper (torch), 10 s chunks | Apple SpeechAnalyzer + SpeechTranscriber (macOS 26), on-device, live results |
| Mac audio | ScreenCaptureKit via PyObjC | ScreenCaptureKit (`SCStream`, audio only) |
| Mic | AVFoundation via PyObjC | `AVAudioEngine` input tap |
| Typing | CGEvent unicode keystrokes | same, gated by `CGRequestPostEventAccess()` |
| Prefs | `com.apple.python3` domain | `@AppStorage` (own container) |
| Build | build.sh + launcher.c | Xcode project, Swift Package for the engine |

Fallback if SpeechTranscriber accuracy or languages fall short: whisper.cpp (Core ML / Metal) with a small model (base.en, ~150 MB) downloaded on first use as data, not code.

## Structure

```
Speak2Transcribe/
  Speak2Transcribe.xcodeproj
  Sources/
    App/          Speak2TranscribeApp.swift, MainWindow.swift, FloatingPanel.swift
    Capture/      SystemAudioSource.swift (SCStream), MicSource.swift (AVAudioEngine)
    Transcribe/   Transcriber.swift (SpeechAnalyzer), BreakWords.swift ("new line")
    Output/       Typist.swift (CGEvent), Transcript.swift (copy/save)
  Resources/      Assets.xcassets (icon), Speak2Transcribe.entitlements
```

Data flow: `AudioSource` (protocol; system or mic) → `AsyncStream<AVAudioPCMBuffer>` → `Transcriber` → finalized text → `BreakWords` → transcript view + `Typist` (when Type at cursor is on and Speak2Transcribe isn't frontmost).

## Entitlements and permissions

- `com.apple.security.app-sandbox`
- `com.apple.security.device.audio-input` — microphone
- `com.apple.security.files.user-selected.read-write` — Save
- Screen & System Audio Recording — prompted by ScreenCaptureKit
- Post-event access — `CGRequestPostEventAccess()` for Type at cursor

## Milestones

1. Mic → SpeechTranscriber → text in a window (proves the engine).
2. System audio via ScreenCaptureKit; Mac / Mic switch.
3. Floating non-activating panel; remembered frames.
4. Type at cursor with Shift-Return line breaks; spoken break words.
5. Copy / Save; icon; settings.
6. Sandbox + review pass: App Store Connect record, privacy labels (no data collected), screenshots, TestFlight.

## Risks / open questions

- **Type at cursor in review** — sandboxed apps can post events with user permission, but review may question it. Test early (milestone 4); if rejected, ship the App Store build without it and keep a Developer ID build with it.
- **Accuracy vs Whisper** — compare on the same recordings in milestone 1.
- **Speaker labels** — SpeechTranscriber has none; drop or defer.
- **Minimum macOS** — SpeechAnalyzer needs macOS 26; arm64 only.
- **Name** — Speak2Transcribe (no App Store app by that name, checked 2026-11-04).
