import Cocoa
import KeyboardShortcuts
import LaunchAtLogin
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
        let wasLaunchedAtLogin = LaunchAtLogin.wasLaunchedAtLogin

        MenubarManager.shared.registerMenuBarItem()
        ShortcutManager.shared.registerShortcut()

        if !generalSettingKeysManager.hasCompletedOnboarding {
            NSApplication.shared.setActivationPolicy(.regular)
            WindowManager.shared.showOnboarding()
            return
        }

        WebDictManager.shared.normalizeState()
        WebViewManager.shared.preloadSelectedWebDictView()
        WebViewManager.shared.preloadSelectedChatWebDictView()

        if wasLaunchedAtLogin {
            NSApplication.shared.setActivationPolicy(.prohibited)
        } else {
            NSApplication.shared.setActivationPolicy(.regular)
            WindowManager.shared.showDict()
        }
    }

    /// 창 닫아도 세션 유지
    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        return false
    }

    /// 앱 재실행 시 사전 창 표시
    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        WindowManager.shared.showDict()
        return false
    }

    func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
