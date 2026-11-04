import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct MainView: View {
    @EnvironmentObject private var engine: TranscriptionEngine
    @AppStorage("source") private var source: Source = .mac

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Picker("Source", selection: $source) {
                    ForEach(Source.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 140)
                .disabled(engine.running)

                Button(engine.running ? "Stop" : "Capture") {
                    Task {
                        if engine.running { await engine.stop() } else { await engine.start(source) }
                    }
                }
                .keyboardShortcut(.return, modifiers: .command)
                .frame(width: 80)

                Spacer()

                Button("Copy") { copy() }.disabled(engine.text.isEmpty)
                Button("Save…") { save() }.disabled(engine.text.isEmpty)
                Button("Clear") { engine.clear() }.disabled(engine.running || engine.text.isEmpty)
            }

            ScrollViewReader { proxy in
                ScrollView {
                    Text("\(engine.text)\(Text(engine.pending.isEmpty ? "" : " " + engine.pending).foregroundStyle(.secondary))")
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                    Color.clear.frame(height: 1).id("end")
                }
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.separator))
                .onChange(of: engine.text + engine.pending) { proxy.scrollTo("end") }
            }

            Text(engine.status.isEmpty ? source.readyText : engine.status)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .onChange(of: source) { if !engine.running { engine.status = "" } }
    }

    private func copy() {
        let board = NSPasteboard.general
        board.clearContents()
        board.setString(engine.text, forType: .string)
    }

    private func save() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.nameFieldStringValue = "Transcript.txt"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try engine.text.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            engine.status = "Could not save: \(error.localizedDescription)"
        }
    }
}
