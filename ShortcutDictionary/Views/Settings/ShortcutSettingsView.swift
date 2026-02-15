import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct ShortcutSettingsView: View {
    @ObservedObject private var shortcutSettingKeysManager = ShortcutSettingKeysManager.shared

    @State var accessEnabled = AXIsProcessTrusted() // 손쉬운 사용 권한 유무

    var body: some View {
        Form {
            // 전역 단축키
            Toggle(isOn: shortcutSettingKeysManager.binding(\.isGlobalShortcutEnabled)) {
                Text("사전 단축키 사용")
            }
            .onChange(of: shortcutSettingKeysManager.isGlobalShortcutEnabled) { _ in
                setShortcutEnabled()
            }

            KeyboardShortcuts.Recorder("사전 단축키", name: .dictShortcut)
                .disabled(!shortcutSettingKeysManager.isGlobalShortcutEnabled)

            Toggle(isOn: shortcutSettingKeysManager.binding(\.isChatShortcutEnabled)) {
                Text("채팅 단축키 사용")
            }
            .onChange(of: shortcutSettingKeysManager.isChatShortcutEnabled) { _ in
                setShortcutEnabled()
            }

            KeyboardShortcuts.Recorder("채팅 단축키", name: .chatShortcut)
                .disabled(!shortcutSettingKeysManager.isChatShortcutEnabled)

            // 단축키 입력시 복사 유무 결정
            Toggle(isOn: shortcutSettingKeysManager.binding(\.isCopyPasteEnabled)) {
                Text("선택한 항목 자동 입력")
                if accessEnabled {
                    Text("단축키 입력시 자동으로 복사&붙여넣기를 합니다")
                } else {
                    Text("이 기능을 사용하려면 '시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용'에서 단축키 사전을 허용해주세요")
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }) {
                        Text("설정 열기").underline()
                    }
                    .buttonStyle(.borderless)
                }
            }
            .disabled(!shortcutSettingKeysManager.isGlobalShortcutEnabled && !shortcutSettingKeysManager.isChatShortcutEnabled)
            .onChange(of: shortcutSettingKeysManager.isCopyPasteEnabled) { value in
                // 처음 활성화 시 빈 키 입력을 발생시켜 손쉬운 사용 권한 설정 팝업 표시
                if value { ShortcutManager.shared.sendEmptyCommand() }
            }
            // 앱이 다시 Focus 되었을 때 손쉬운 사용 권한 재확인
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                self.accessEnabled = AXIsProcessTrusted()
            }

            // 빠른 검색 활성화 여부
            Toggle(isOn: shortcutSettingKeysManager.binding(\.isFastSearchEnabled)) {
                Text("즉시 검색 확성화")
                Text("이 기능을 활성화하면 복사된 단어를 바로 검색합니다")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    func setShortcutEnabled() {
        if shortcutSettingKeysManager.isGlobalShortcutEnabled {
            KeyboardShortcuts.enable(.dictShortcut)
        } else {
            KeyboardShortcuts.disable(.dictShortcut)
        }

        if shortcutSettingKeysManager.isChatShortcutEnabled {
            KeyboardShortcuts.enable(.chatShortcut)
        } else {
            KeyboardShortcuts.disable(.chatShortcut)
        }
    }
}
