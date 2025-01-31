import SwiftUI

@main
struct ShortcutDictionaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage(SettingKeys.isToolbarEnabled.rawValue)
    private var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    var body: some Scene {
        if #available(macOS 14.0, *) {
            Window("Dummy", id: "dummy") {
                DummyView()
                    .frame(width: 0, height: 0)
            }
            .windowResizability(.contentSize)
            .windowStyle(.hiddenTitleBar)
            .commandsRemoved()
        }

        Settings {
            SettingsView()
                .navigationTitle("설정")
                .onAppear {
                    MenubarManager.shared.setupMenu()
                    print("setup appear")
                }
        }
        .commandsRemoved()
        .windowResizability(.contentSize)
    }
}
