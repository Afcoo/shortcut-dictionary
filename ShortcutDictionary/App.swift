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
        }
        .commandsRemoved()
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("단축키 사전에 관하여") {
                    WindowManager.shared.showAbout()
                }
                
                Divider()
                
                Button("설정") {
                    WindowManager.shared.showSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
                
                Divider()
                
                Button("단축키 사전 종료") {
                    appDelegate.quitApp()
                }
                .keyboardShortcut("Q", modifiers: .command)
            }
            
            CommandGroup(replacing: .sidebar) {
                Button(action: {
                    isToolbarEnabled.toggle()
                }) {
                    HStack {
                        if isToolbarEnabled {
                            Image(systemName: "checkmark")
                                .imageScale(.small)
                        }
                        Text("툴바 표시")
                    }
                }
                .keyboardShortcut("T", modifiers: .command)
                
                Button("새로 고침") {
                    NotificationCenter.default.post(name: .reloadDict, object: "")
                }
                .keyboardShortcut("R", modifiers: .command)
                
                Divider()
                
                Button("창 닫기") {
                    if let window = NSApplication.shared.keyWindow {
                        if window == WindowManager.shared.dictWindow {
                            WindowManager.shared.closeDict()
                        } else {
                            NSApplication.shared.keyWindow?.close()
                        }
                    }
                }
                .keyboardShortcut("W", modifiers: .command)
                
                Divider()
            }
        }
        .windowResizability(.contentSize)
    }
}
