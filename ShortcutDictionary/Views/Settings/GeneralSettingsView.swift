import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(SettingKeys.isMenuItemEnabled.rawValue)
    private var isMenuItemEnabled = SettingKeys.isMenuItemEnabled.defaultValue as! Bool

    var body: some View {
        Form {
            // 시작 시 실행
            LaunchAtLogin.Toggle("시작 시 실행")

            // 메뉴 아이템 표시
            Toggle(isOn: $isMenuItemEnabled) {
                Text("메뉴 바 아이템 표시")
            }
            .onChange(of: isMenuItemEnabled) { _ in
                setMenuItemEnabled()
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    func setMenuItemEnabled() {
        if isMenuItemEnabled {
            MenubarManager.shared.setupMenuBarItem()
        }
        else {
            MenubarManager.shared.removeMenuBarItem()
        }
    }
}
