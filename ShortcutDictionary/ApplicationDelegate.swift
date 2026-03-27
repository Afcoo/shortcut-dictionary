import Cocoa
import KeyboardShortcuts
import SwiftUI

@main
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private let generalSettingKeysManager = GeneralSettingKeysManager.shared
    private let shortcutSettingKeysManager = ShortcutSettingKeysManager.shared

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    /// 앱 실행 시
    func applicationDidFinishLaunching(_: Notification) {
        MenubarManager.shared.registerMenuBarItem()
        ShortcutManager.shared.registerShortcut()

        if !generalSettingKeysManager.isMenuItemEnabled,
           !shortcutSettingKeysManager.isGlobalShortcutEnabled,
           !shortcutSettingKeysManager.isChatShortcutEnabled
        {
            NSApplication.shared.setActivationPolicy(.regular)
        } else {
            NSApplication.shared.setActivationPolicy(.prohibited)
        }

        if !generalSettingKeysManager.hasCompletedOnboarding {
            NSApplication.shared.setActivationPolicy(.regular)
            WindowManager.shared.showOnboarding()
        } else {
            WebDictManager.shared.normalizeState()
            WebViewManager.shared.preloadSelectedWebDictView()
            WebViewManager.shared.preloadSelectedChatWebDictView()
        }
    }

    /// 창 닫아도 세션 유지
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return false
    }

    /// Dock 아이콘 클릭 시 창 표시
    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        WindowManager.shared.showDict()
        return false
    }

    func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
