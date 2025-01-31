import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(SettingKeys.isToolbarEnabled.rawValue)
    private var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.backgroundColor.rawValue)
    private var backgroundColor = SettingKeys.backgroundColor.defaultValue as! String

    @AppStorage(SettingKeys.isBackgroundTransparent.rawValue)
    private var isBackgroundTransparent = SettingKeys.isBackgroundTransparent.defaultValue as! Bool

    @State private var bgColor = NSColor.windowBackgroundColor

    var body: some View {
        Form {
            // 툴바 표시
            Toggle(isOn: $isToolbarEnabled) {
                Text("툴바 표시")
            }

            // 배경 색상
            HStack {
                Text("배경 색상")
                Spacer()
                ToolbarButton(
                    action: { bgColor = NSColor.windowBackgroundColor }, // 배경 색상 리셋
                    systemName: "arrow.trianglehead.2.clockwise",
                    scale: .medium
                )
                ColorWell(selectedColor: $bgColor)
                    .frame(maxWidth: 40)
                    .onAppear {
                        bgColor = NSColor(hexString: backgroundColor) ?? NSColor.windowBackgroundColor
                    }
                    .onChange(of: bgColor) { value in
                        backgroundColor = value.hexString
                    }
            }

            // 배경 투명 효과
            Toggle(isOn: $isBackgroundTransparent) {
                Text("배경 투명 효과")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }
}
