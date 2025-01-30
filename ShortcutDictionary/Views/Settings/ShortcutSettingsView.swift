import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct ShortcutSettingsView: View {
    @AppStorage("enable_global_shortcut") var isGlobalShortcutEnabled: Bool = false
    @AppStorage("enable_copy_paste") var isCopyPasteEnabled: Bool = true

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
                //                .padding(.leading, 20)
                .disabled(!isGlobalShortcutEnabled)

            // 단축키 입력시 복사 유무 결정
            Toggle(isOn: $isCopyPasteEnabled) {
                Text("선택된 단어 바로 검색")
                Text("단축키 입력시 자동으로 복사&붙여넣기를 합니다")
            }
            //                .padding(.leading, 20)
            .disabled(!isGlobalShortcutEnabled)
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
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
