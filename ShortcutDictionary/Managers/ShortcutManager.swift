import KeyboardShortcuts
import SwiftUI

class ShortcutManager {
    @AppStorage(SettingKeys.isGlobalShortcutEnabled.rawValue)
    private var isGlobalShortcutEnabled = SettingKeys.isGlobalShortcutEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.isCopyPasteEnabled.rawValue)
    private var isCopyPasteEnabled = SettingKeys.isCopyPasteEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.isChatShortcutEnabled.rawValue)
    private var isChatShortcutEnabled = SettingKeys.isChatShortcutEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.isChatEnabled.rawValue)
    private var isChatEnabled = SettingKeys.isChatEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.selectedPageMode.rawValue)
    private var selectedPageMode = SettingKeys.selectedPageMode.defaultValue as! String

    static var shared = ShortcutManager()

    private let pasteboard = NSPasteboard.general
    private(set) var lastCopiedText: String?

    var isCopying = false // 선택된 단어 복사가 진행중임을 나타내는 플래그
    private var checkCount = 0
    private let maxChecks = 10
    private let checkDelay = 0.03 // 0.03초 간격 10번 체크

    private init() {}

    /// register global keyboard shortcuts
    func registerShortcut() {
        KeyboardShortcuts.onKeyUp(for: .dictShortcut, action: { () in
            self.activate(mode: "dictionary")
        })

        KeyboardShortcuts.onKeyUp(for: .chatShortcut, action: { () in
            self.activate(mode: "chat")
        })

        if isGlobalShortcutEnabled {
            KeyboardShortcuts.enable(.dictShortcut)
        } else {
            KeyboardShortcuts.disable(.dictShortcut)
        }

        if isChatShortcutEnabled {
            KeyboardShortcuts.enable(.chatShortcut)
        } else {
            KeyboardShortcuts.disable(.chatShortcut)
        }
    }

    func activate(mode: String, doCopyPaste: Bool = true) {
        if mode == "chat", !isChatEnabled {
            return
        }

        selectedPageMode = mode
        NotificationCenter.default.post(name: .pageModeChanged, object: mode)

        // 이미 복사 중이면 무시
        guard !isCopying else {
            print("복사 작업이 이미 진행 중입니다")
            return
        }

        if isCopyPasteEnabled, doCopyPaste {
            isCopying = true

            getSelectedText { [weak self] selectedText in
                if let text = selectedText {
                    self?.lastCopiedText = text
                    self?.postUpdateText(text: text, mode: mode)

                    print(text)
                }
                // 사전 창 열기
                WindowManager.shared.showDict()

                self?.isCopying = false
            }
        } else {
            WindowManager.shared.showDict()
        }
    }

    func postLastCopiedTextIfExists(mode: String) {
        guard let lastCopiedText else { return }

        postUpdateText(text: lastCopiedText, mode: mode)
    }

    private func getSelectedText(completion: @escaping (String?) -> Void) {
        let oldCount = pasteboard.changeCount

        if sendCopyCommand() {
            checkCount = 0
            checkClipboardChange(oldCount: oldCount, completion: completion)
        } else {
            isCopying = false
            completion(nil)
        }
    }

    private func checkClipboardChange(oldCount: Int, completion: @escaping (String?) -> Void) {
        // 클립보드 변경 확인
        if pasteboard.changeCount != oldCount {
            let newText = pasteboard.string(forType: .string)
            completion(newText)
            return
        }

        checkCount += 1
        if checkCount < maxChecks {
            // 0.05초 후 다시 체크
            DispatchQueue.main.asyncAfter(deadline: .now() + checkDelay) { [weak self] in
                self?.checkClipboardChange(oldCount: oldCount, completion: completion)
            }
        } else {
            // 시간 초과
            isCopying = false
            completion(nil)
        }
    }

    private func sendCopyCommand() -> Bool {
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)

        let cmdKey: UInt16 = 0x37
        let cKey: UInt16 = 0x08

        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: true)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: false)
        let keyCDown = CGEvent(keyboardEventSource: source, virtualKey: cKey, keyDown: true)
        let keyCUp = CGEvent(keyboardEventSource: source, virtualKey: cKey, keyDown: false)

        guard let cmdDown = cmdDown,
              let cmdUp = cmdUp,
              let keyCDown = keyCDown,
              let keyCUp = keyCUp
        else {
            return false
        }

        // Command 키 플래그 설정
        let flags = CGEventFlags.maskCommand
        cmdDown.flags = flags
        cmdUp.flags = flags
        keyCDown.flags = flags
        keyCUp.flags = flags

        // 키 이벤트 발생
        let location = CGEventTapLocation.cghidEventTap
        cmdDown.post(tap: location)
        keyCDown.post(tap: location)
        keyCUp.post(tap: location)
        cmdUp.post(tap: location)

        return true
    }

    func sendEmptyCommand() {
        let source = CGEventSource(stateID: .hidSystemState)

        let event = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        event?.post(tap: .cghidEventTap)
    }

    private func postUpdateText(text: String, mode: String) {
        NotificationCenter.default.post(
            name: .updateText,
            object: nil,
            userInfo: [
                NotificationUserInfoKey.text: text,
                NotificationUserInfoKey.mode: mode,
            ]
        )
    }
}
