import SwiftUI

// dummy view with openSettings Notification
@available(macOS 14.0, *)
struct DummyView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        EmptyView()
            .onReceive(
                NotificationCenter.default.publisher(for: .showSettings),
                perform: { _ in
                    openSettings()
                }
            )
            .onAppear {
                dismissWindow(id: "dummy")
            }
    }
}

@available(macOS, obsoleted: 14.0)
struct LegacyDummyView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            view.window?.close()
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
