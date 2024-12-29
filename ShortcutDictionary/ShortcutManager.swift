import KeyboardShortcuts
import SwiftUI

class ShortcutManager {
    @AppStorage("enable_copy_paste") var isCopyPasteEnabled: Bool = true
    @AppStorage("enable_global_shortcut") var isGlobalShortcutEnabled: Bool = false

    static var shared = ShortcutManager()

    private init() {}

    // register global keyboard shortcuts
    func registerShortcut() {
        KeyboardShortcuts.onKeyDown(for: .dictShortcut, action: { () in self.activateDict() })

        if isGlobalShortcutEnabled {
            KeyboardShortcuts.enable(.dictShortcut)
        }
        else {
            KeyboardShortcuts.disable(.dictShortcut)
        }
    }

    func activateDict(_ doCopyPaste: Bool = true) {
        if isCopyPasteEnabled, doCopyPaste {
            // Copy & get clipboard
            sendCommandC()
            let clipboard = NSPasteboard.general.string(forType: .string)

            // send clipboard to dictionary
            NotificationCenter.default.post(name: .updateText, object: clipboard ?? "")
        }

        // 사전 창 열기
        WindowManager.shared.showDict()
    }

    private func sendCommandC() {
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)

        let cmdKey: UInt16 = 0x37
        let cKey: UInt16 = 0x08

        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: true)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: false)
        let keyCDown = CGEvent(keyboardEventSource: source, virtualKey: cKey, keyDown: true)
        let keyCUp = CGEvent(keyboardEventSource: source, virtualKey: cKey, keyDown: false)

        let loc = CGEventTapLocation.cghidEventTap

        cmdDown?.flags = CGEventFlags.maskCommand
        cmdUp?.flags = CGEventFlags.maskCommand
        keyCDown?.flags = CGEventFlags.maskCommand
        keyCUp?.flags = CGEventFlags.maskCommand

        cmdDown?.post(tap: loc)
        keyCDown?.post(tap: loc)
        cmdUp?.post(tap: loc)
        keyCUp?.post(tap: loc)

        usleep(200000)
    }
}
