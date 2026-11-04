import AppKit
import SwiftUI

/// A small panel that floats above other apps on every Space and never takes
/// focus from them, so Type at cursor lands in the app you were using.
final class FloatingPanel: NSPanel {
    init<Content: View>(@ViewBuilder content: () -> Content) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 360, height: 194),
                   styleMask: [.titled, .closable, .nonactivatingPanel, .utilityWindow, .fullSizeContentView],
                   backing: .buffered, defer: false)
        title = "Speak2Transcribe"
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        isReleasedWhenClosed = false
        contentView = FirstClickHostingView(rootView: content())
        setFrameAutosaveName("Speak2TranscribePanel")
        if !setFrameUsingName("Speak2TranscribePanel") { center() }
    }

    // Staying non-key is what keeps the other app's text field focused.
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

/// Buttons respond to the first click even though the panel is never key.
final class FirstClickHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

/// Switches between the main window and the floating panel.
@MainActor
final class PanelController: NSObject, NSWindowDelegate {
    static let shared = PanelController()
    weak var mainWindow: NSWindow?
    private var panel: FloatingPanel?
    var engine: TranscriptionEngine?

    func setFloating(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: "floating")
        if on {
            if panel == nil, let engine {
                panel = FloatingPanel { PanelView().environmentObject(engine) }
                panel?.delegate = self
            }
            panel?.orderFrontRegardless()
            mainWindow?.orderOut(nil)
        } else {
            panel?.orderOut(nil)
            mainWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate()
        }
    }

    /// Closing the panel brings the main window back.
    func windowWillClose(_ notification: Notification) {
        if UserDefaults.standard.bool(forKey: "floating") { setFloating(false) }
    }
}

/// Hands SwiftUI's window to the panel controller, once it exists.
struct WindowAccessor: NSViewRepresentable {
    let found: (NSWindow) -> Void
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { if let window = view.window { found(window) } }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
