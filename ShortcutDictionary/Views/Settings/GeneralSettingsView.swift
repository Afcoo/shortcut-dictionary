import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("enable_menu_item") var isMenuItemEnabled: Bool = true

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
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
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
