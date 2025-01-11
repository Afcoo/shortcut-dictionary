import SwiftUI

@main
struct ShortcutDictionaryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("enable_toolbar") var isToolbarEnabled: Bool = true

    var body: some Scene {
        Window("", id: "dummy") {
            if #available(macOS 14.0, *) {
                DummyView()
                    .frame(width: 0, height: 0)
            } else {
                LegacyDummyView()
                    .frame(width: 0, height: 0)
            }
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commandsRemoved()
        
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
                        Image(systemName: "checkmark")
                            .imageScale(.small)
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
//                    WindowManager.shared.closeDict()
                    NSApplication.shared.keyWindow?.close()
                }
                .keyboardShortcut("W", modifiers: .command)
                
                Divider()
            }
        }
        .windowResizability(.contentSize)
    }
}
