import Cocoa
import KeyboardShortcuts
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    // 앱 실행 시
    func applicationDidFinishLaunching(_ notification: Notification) {
        MenubarManager.shared.registerMenuBarItem()

        ShortcutManager.shared.registerShortcut()

        if !hasCompletedOnboarding {
            NSApplication.shared.setActivationPolicy(.regular)
            WindowManager.shared.showOnboarding()
        }
        else {
            NSApplication.shared.setActivationPolicy(.prohibited)
        }
    }

    // 창 닫아도 세션 유지
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    // Dock 아이콘 클릭 시 창 표시
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            WindowManager.shared.showDict()
        }
        return true
    }

    func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
