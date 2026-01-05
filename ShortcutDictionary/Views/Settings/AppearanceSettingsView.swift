import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage(SettingKeys.isToolbarEnabled.rawValue)
    private var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.backgroundColor.rawValue)
    private var backgroundColor = SettingKeys.backgroundColor.defaultValue as! String

    @AppStorage(SettingKeys.isBackgroundTransparent.rawValue)
    private var isBackgroundTransparent = SettingKeys.isBackgroundTransparent.defaultValue as! Bool

    @AppStorage(SettingKeys.dictViewPadding.rawValue)
    private var dictViewPadding = SettingKeys.dictViewPadding.defaultValue as! Double

    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    @State private var bgColor = NSColor.windowBackgroundColor

    var body: some View {
        Form {
            // 툴바 표시
            Toggle(isOn: $isToolbarEnabled) {
                Text("툴바 표시")
            }

            // 사전 뷰 Padding 조절
            Slider(value: $dictViewPadding, in: 0.0 ... 28.0, step: 4.0) {
                Text("배경 두께 설정")
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

            if #available(macOS 26.0, *) {
                // Liquid Glass 효과
                Toggle(isOn: $isLiquidGlassEnabled) {
                    Text("Liquid Glass 디자인 사용")
                }
                .onChange(of: isLiquidGlassEnabled) { value in
                    if value {
                        dictViewPadding = 0.0 // padding 제거 (기본값으로 변경)
                        isBackgroundTransparent = true // 배경 투명 효과 강제 활성화
                        WindowManager.shared.setDictWindowLiquidGlass(true)
                    }
                    else {
                        WindowManager.shared.setDictWindowLiquidGlass(false)
                    }
                }
            }
            else {
                Toggle(isOn: $isLiquidGlassEnabled) {
                    Text("Liquid Glass 디자인 사용").foregroundStyle(.secondary)
                    Text("macOS Tahoe 이상이 필요합니다").foregroundStyle(.tertiary)
                }
                .disabled(true)
            }

            // 배경 투명 효과
            Toggle(isOn: $isBackgroundTransparent) {
                Text("배경 투명 효과")
            }
            .disabled(isLiquidGlassEnabled)
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }
}
