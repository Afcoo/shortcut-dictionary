import KeyboardShortcuts
import SwiftUI

class ShortcutManager {
    @AppStorage("enable_copy_paste") var isCopyPasteEnabled: Bool = true
    @AppStorage("enable_global_shortcut") var isGlobalShortcutEnabled: Bool = false

    static var shared = ShortcutManager()

    private let pasteboard = NSPasteboard.general

    var isCopying = false // 선택된 단어 복사가 진행중임을 나타내는 플래그
    private var checkCount = 0
    private let maxChecks = 10
    private let checkDelay = 0.03 // 0.03초 간격 10번 체크

    private init() {}

    // register global keyboard shortcuts
    func registerShortcut() {
        KeyboardShortcuts.onKeyDown(for: .dictShortcut, action: { () in self.activateDict() })

        if isGlobalShortcutEnabled {
            KeyboardShortcuts.enable(.dictShortcut)
        } else {
            KeyboardShortcuts.disable(.dictShortcut)
        }
    }

    func activateDict(_ doCopyPaste: Bool = true) {
        // 이미 복사 중이면 무시
        guard !isCopying else {
            print("복사 작업이 이미 진행 중입니다")
            return
        }

        if isCopyPasteEnabled, doCopyPaste {
            isCopying = true

            getSelectedText { [weak self] selectedText in
                if let text = selectedText {
                    // 복사된 텍스트를 사전으로 전달
                    NotificationCenter.default.post(name: .updateText, object: text)
                }

                // 사전 창 열기
                WindowManager.shared.showDict()

                self?.isCopying = false
            }
        } else {
            WindowManager.shared.showDict()
        }
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
        cmdUp.post(tap: location)
        keyCUp.post(tap: location)

        return true
    }
}
