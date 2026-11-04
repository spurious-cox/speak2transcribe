import SwiftUI

/// Mac / Mic as two buttons; the chosen one is filled with the accent color.
/// (A segmented control draws its selection dim in a panel that is never key.)
struct SourceSwitch: View {
    @Binding var source: Source
    var disabled: Bool

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Source.allCases) { item in
                let chosen = item == source
                Button { source = item } label: {
                    Text(item.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(chosen ? Color.white : Color.secondary)
                        .frame(width: 48, height: 22)
                        .background(RoundedRectangle(cornerRadius: 5)
                            .fill(chosen ? Color.accentColor : Color.primary.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
        }
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1)
    }
}

/// The floating panel: source, Capture, Type at cursor, and the latest text.
struct PanelView: View {
    @EnvironmentObject private var engine: TranscriptionEngine
    @AppStorage("source") private var source: Source = .mac
    @AppStorage("typeAtCursor") private var typeAtCursor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(engine.running ? "Stop" : "Capture") {
                    Task {
                        if engine.running { await engine.stop() } else { await engine.start(source) }
                    }
                }
                .frame(width: 72)
                SourceSwitch(source: $source, disabled: engine.running)
                Spacer()
                Button("Full Window") { PanelController.shared.setFloating(false) }
            }
            Toggle("Type at cursor", isOn: $typeAtCursor)
                .toggleStyle(.checkbox)
                .onChange(of: typeAtCursor) { _, on in
                    // The switch stays on either way. macOS reports a grant
                    // made while the app is running only after a relaunch.
                    if on && !Typist.requestAccess() {
                        engine.status = "Type at cursor needs Speak2Transcribe turned on in System Settings ▸ Privacy & Security ▸ Device Control and Data Access. If it already is, quit and reopen Speak2Transcribe."
                    }
                }
            // A small text box, as in MyTranscribe's panel.
            ScrollView {
                Text(latest)
                    .font(.callout)
                    .foregroundStyle(engine.pending.isEmpty ? .primary : .secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
            }
            .defaultScrollAnchor(.bottom)
            .frame(maxHeight: .infinity)
            .background(Color(nsColor: .textBackgroundColor))
            Text(engine.status.isEmpty ? source.readyText : engine.status)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(engine.status)
        }
        .padding(.horizontal, 12)
        .padding(.top, 30)       // under the panel's title bar
        .padding(.bottom, 8)
        // MyTranscribe's panel size, title bar included.
        .frame(width: 360, height: 194)
    }

    /// The phrase being heard, or else the end of the transcript.
    private var latest: String {
        if !engine.pending.isEmpty { return engine.pending }
        return String(engine.text.suffix(600))
    }
}
