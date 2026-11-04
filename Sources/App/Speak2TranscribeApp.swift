import SwiftUI

@main
struct Speak2TranscribeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        Window("Speak2Transcribe", id: "main") {
            MainView()
                .environmentObject(delegate.engine)
                .frame(minWidth: 480, minHeight: 300)
        }
        // MyTranscribe's window: 640 × 420 of content under a 32-point title bar.
        .defaultSize(width: 640, height: 452)
        .commands {
            CommandGroup(replacing: .help) { HelpMenuItem() }
        }

        Window("Speak2Transcribe Help", id: "help") {
            HelpView()
        }
        .defaultSize(width: 480, height: 560)
    }
}

/// Help ▸ Speak2Transcribe Help (⌘?).
struct HelpMenuItem: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Button("Speak2Transcribe Help") {
            openWindow(id: "help")
            NSApp.activate()
        }
        .keyboardShortcut("?", modifiers: .command)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let engine = TranscriptionEngine()

    override init() {
        super.init()
        PanelController.shared.engine = engine
        // Each finished phrase is typed at the cursor when that is switched on.
        engine.onFinal = { text in
            if UserDefaults.standard.bool(forKey: "typeAtCursor") { Typist.type(text) }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        !UserDefaults.standard.bool(forKey: "floating")
    }
}
