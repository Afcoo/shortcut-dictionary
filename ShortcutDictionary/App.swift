import SwiftUI

@main
struct ShortcutDictionaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .navigationTitle("설정")
        }
        .windowResizability(.contentSize)
    }
}
