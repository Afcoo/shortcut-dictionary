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
