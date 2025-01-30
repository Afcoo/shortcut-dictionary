import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("enable_toolbar") var isToolbarEnabled: Bool = true

    var body: some View {
        Form {
            // 툴바 표시
            Toggle(isOn: $isToolbarEnabled) {
                Text("툴바 표시")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }
}
