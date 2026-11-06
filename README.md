# Speak2Transcribe

Speech to text on your Mac, live and private. Choose **Mic** (what you say)
or **Mac** (whatever your Mac is playing), and the words appear in the window
or are typed straight into the app you're using.

- **Type at cursor** from a small floating panel that never takes focus
- Say "new line" or "new paragraph" for line breaks
- Apple's on-device speech recognition: audio and text never leave your Mac
- Copy, Save and Clear the transcript
- Requires macOS 26 or later, Apple silicon

Mac App Store: submitted, awaiting Apple's review (link to follow).
Support and privacy: https://spurious-cox.github.io/speak2transcribe-support/

## Also: MyTranscribe

[MyTranscribe](https://github.com/spurious-cox/MyTranscribe) is the earlier,
open Python version with the same icon and features. It uses OpenAI Whisper
instead of Apple's engine and adds speaker labels. It installs from Homebrew
or a disk image rather than the App Store. See the table in its README.

## Also: iPhone

[Speak2Transcribe for iPhone](https://github.com/spurious-cox/speak2transcribe-ios) ("s2t") is a separate iOS app with a dictation keyboard that types into any app. Not in the App Store yet.

## Building

Needs Xcode 26 and [XcodeGen](https://github.com/yonaskolb/XcodeGen). Run
`./build.sh`: it generates the Xcode project, builds, and installs to
/Applications (`./build.sh --no-install` builds only). Signing uses the team in
`project.yml`; change it to your own.

## License

MIT — see [LICENSE](LICENSE).
