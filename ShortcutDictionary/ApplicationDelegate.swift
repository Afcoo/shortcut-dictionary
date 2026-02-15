import Cocoa
import KeyboardShortcuts
import SwiftUI

@main
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @AppStorage(SettingKeys.hasCompletedOnboarding.rawValue)
    private var hasCompletedOnboarding = SettingKeys.hasCompletedOnboarding.defaultValue as! Bool

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }

    /// 앱 실행 시
    func applicationDidFinishLaunching(_: Notification) {
        MenubarManager.shared.registerMenuBarItem()
//        MenubarManager.shared.setupMenu()

        ShortcutManager.shared.registerShortcut()

        NSApplication.shared.setActivationPolicy(.regular)

        if !hasCompletedOnboarding {
            WindowManager.shared.showOnboarding()
        } else {
            WindowManager.shared.showDict()
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
