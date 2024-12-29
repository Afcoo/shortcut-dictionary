import Cocoa
import KeyboardShortcuts
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    // 앱 실행 시
    func applicationDidFinishLaunching(_ notification: Notification) {
        if #available(macOS 14.0, *) {
            NSApp.windows.first?.close()
        }

        MenubarManager.shared.registerMenuBarItem()

        ShortcutManager.shared.registerShortcut()

        WindowManager.shared.showOnboarding()

//        WindowManager.shared.showDict()
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
