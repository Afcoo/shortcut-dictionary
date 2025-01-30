import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI
import WebKit

struct SettingsView: View {
    @State private var currentView = 0
    @State private var viewHeight: CGFloat = 0

    var body: some View {
        TabView(selection: $currentView) {
            GeneralSettingsView()
                .getViewSize { size in
                    viewHeight = size.height
                }
                .tabItem {
                    Label("일반", systemImage: "switch.2")
                }
                .tag(0)
            ShortcutSettingsView()
                .getViewSize { size in
                    viewHeight = size.height
                }
                .tabItem {
                    Label("단축키", systemImage: "keyboard")
                }
                .tag(1)
            DictionarySettingsView()
                .getViewSize { size in
                    viewHeight = size.height
                }
                .tabItem {
                    Label("사전", systemImage: "character.book.closed.fill")
                }
                .tag(2)
            AppearanceSettingsView()
                .getViewSize { size in
                    viewHeight = size.height
                }
                .tabItem {
                    Label("보기", systemImage: "paintpalette")
                }
                .tag(3)
            InfoSettingsView()
                .getViewSize { size in
                    viewHeight = size.height
                }
                .tabItem {
                    Label("정보", systemImage: "info.circle")
                }
                .tag(4)
        }
        .frame(width: 350, height: viewHeight)
//        .frame(height: viewHeights[currentView])
        .onDisappear {
            if !WindowManager.shared.dictWindow.isVisible {
                NSApplication.shared.setActivationPolicy(.prohibited)
            }
        }
    }
}
