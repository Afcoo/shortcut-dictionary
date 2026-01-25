import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct ShortcutSettingsView: View {
    @AppStorage(SettingKeys.isGlobalShortcutEnabled.rawValue)
    private var isGlobalShortcutEnabled = SettingKeys.isGlobalShortcutEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.isCopyPasteEnabled.rawValue)
    private var isCopyPasteEnabled = SettingKeys.isCopyPasteEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.isFastSearchEnabled.rawValue)
    private var isFastSearchEnabled = SettingKeys.isFastSearchEnabled.defaultValue as! Bool

    @State var accessEnabled = AXIsProcessTrusted() // 손쉬운 사용 권한 유무

    var body: some View {
        Form {
            // 전역 단축키
            Toggle(isOn: $isGlobalShortcutEnabled) {
                Text("단축키 사용")
            }
            .onChange(of: isGlobalShortcutEnabled) { _ in
                setGlobalShortcutEnabled()
            }

            // 단축키 설정
            KeyboardShortcuts.Recorder("단축키", name: .dictShortcut)
                .disabled(!isGlobalShortcutEnabled)

            // 단축키 입력시 복사 유무 결정
            Toggle(isOn: $isCopyPasteEnabled) {
                Text("선택된 단어 바로 검색")
                if accessEnabled {
                    Text("단축키 입력시 자동으로 복사&붙여넣기를 합니다")
                }
                else {
                    Text("이 기능을 사용하려면 '시스템 설정 > 개인정보 보호 및 보안 > 손쉬운 사용'에서 단축키 사전을 허용해주세요")
                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                    }) {
                        Text("설정 열기").underline()
                    }
                    .buttonStyle(.borderless)
                }
            }
            .disabled(!isGlobalShortcutEnabled)
            .onChange(of: isCopyPasteEnabled) { value in
                // 처음 활성화 시 빈 키 입력을 발생시켜 손쉬운 사용 권한 설정 팝업 표시
                if value { ShortcutManager.shared.sendEmptyCommand() }
            }
            // 앱이 다시 Focus 되었을 때 손쉬운 사용 권한 재확인
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                self.accessEnabled = AXIsProcessTrusted()
            }

            // 빠른 검색 활성화 여부
            Toggle(isOn: $isFastSearchEnabled) {
                Text("빠른 검색 활성화")
                Text("이 기능을 활성화하면 복사된 단어를 바로 검색합니다")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    func setGlobalShortcutEnabled() {
        if isGlobalShortcutEnabled {
            KeyboardShortcuts.enable(.dictShortcut)
        }
        else {
            KeyboardShortcuts.disable(.dictShortcut)
        }
    }
}
