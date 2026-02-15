import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject private var generalSettingKeysManager = GeneralSettingKeysManager.shared

    var body: some View {
        Form {
            // 시작 시 실행
            LaunchAtLogin.Toggle("시작 시 실행")

            // 메뉴 아이템 표시
            Toggle(isOn: generalSettingKeysManager.binding(\.isMenuItemEnabled)) {
                Text("메뉴 바 아이템 표시")
            }
            .onChange(of: generalSettingKeysManager.isMenuItemEnabled) { _ in
                setMenuItemEnabled()
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    func setMenuItemEnabled() {
        if generalSettingKeysManager.isMenuItemEnabled {
            MenubarManager.shared.setupMenuBarItem()
        } else {
            MenubarManager.shared.removeMenuBarItem()
        }
    }
}
