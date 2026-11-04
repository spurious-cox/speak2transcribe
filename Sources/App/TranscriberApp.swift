import SwiftUI

@main
struct TranscriberApp: App {
    @StateObject private var engine = TranscriptionEngine()

    var body: some Scene {
        Window("Transcriber", id: "main") {
            MainView()
                .environmentObject(engine)
                .frame(minWidth: 480, minHeight: 300)
        }
        .defaultSize(width: 640, height: 420)
    }
}
