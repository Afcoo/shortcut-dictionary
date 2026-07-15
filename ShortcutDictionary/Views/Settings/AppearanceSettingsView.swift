import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared

    var body: some View {
        Form {
            // 사전 뷰 Padding 조절
            Slider(value: appearanceSettingKeysManager.binding(\.dictViewPadding), in: 0.0 ... 28.0, step: 4.0) {
                Text("배경 두께 설정")
            }

            HStack {
                Text("배경 색상")
                Spacer()

                Button(action: resetBackgroundColors) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("배경 색상 초기화")

                ColorPicker(
                    "라이트 모드 색상",
                    selection: Binding(
                        get: { backgroundColor(isDarkMode: false) },
                        set: { setBackgroundColor($0, isDarkMode: false) }
                    ),
                    supportsOpacity: false
                )
                .labelsHidden()
                .overlay {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.init(white: 0.2))
                        .font(.system(size: 14))
                        .allowsHitTesting(false)
                }

                ColorPicker(
                    "다크 모드 색상",
                    selection: Binding(
                        get: { backgroundColor(isDarkMode: true) },
                        set: { setBackgroundColor($0, isDarkMode: true) }
                    ),
                    supportsOpacity: false
                )
                .labelsHidden()
                .overlay {
                    Image(systemName: "moon.fill")
                        .foregroundColor(.init(white: 0.9))
                        .font(.system(size: 10))
                        .allowsHitTesting(false)
                }
            }

            if #available(macOS 26.0, *) {
                // Liquid Glass 효과
                Toggle(isOn: appearanceSettingKeysManager.binding(\.isLiquidGlassEnabled)) {
                    Text("Liquid Glass 디자인 사용")
                }
                .onChange(of: appearanceSettingKeysManager.isLiquidGlassEnabled) { _, newValue in
                    if newValue {
                        appearanceSettingKeysManager.dictViewPadding = 0.0 // padding 제거 (기본값으로 변경)
                        appearanceSettingKeysManager.isBackgroundTransparent = true // 배경 투명 효과 강제 활성화
                        WindowManager.shared.setDictWindowLiquidGlass(true)
                    } else {
                        WindowManager.shared.setDictWindowLiquidGlass(false)
                    }
                }
            } else {
                Toggle(isOn: appearanceSettingKeysManager.binding(\.isLiquidGlassEnabled)) {
                    Text("Liquid Glass 디자인 사용").foregroundStyle(.secondary)
                    Text("macOS Tahoe 이상이 필요합니다").foregroundStyle(.tertiary)
                }
                .disabled(true)
            }

            // 배경 투명 효과
            Toggle(isOn: appearanceSettingKeysManager.binding(\.isBackgroundTransparent)) {
                Text("배경 투명 효과")
            }
            .disabled(appearanceSettingKeysManager.isLiquidGlassEnabled)

            Section("툴바") {
                Toggle(isOn: appearanceSettingKeysManager.binding(\.isToolbarEnabled)) {
                    Text("툴바 표시")
                }

                Toggle(isOn: appearanceSettingKeysManager.binding(\.isToolbarBackForwardButtonEnabled)) {
                    Text("앞/뒤로가기 버튼 표시")
                }
                .disabled(!appearanceSettingKeysManager.isLiquidGlassEnabled)

                Toggle(isOn: appearanceSettingKeysManager.binding(\.isToolbarReloadButtonEnabled)) {
                    Text("새로고침 버튼 표시")
                }
                .disabled(!appearanceSettingKeysManager.isLiquidGlassEnabled)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    private var usesLiquidGlassColors: Bool {
        if #available(macOS 26.0, *) {
            return appearanceSettingKeysManager.isLiquidGlassEnabled
        }

        return false
    }

    private func backgroundColor(isDarkMode: Bool) -> Color {
        if usesLiquidGlassColors {
            let storedColor = isDarkMode
                ? appearanceSettingKeysManager.liquidGlassBackgroundDarkColor
                : appearanceSettingKeysManager.liquidGlassBackgroundColor

            guard storedColor != SettingKeys.nativeWindowBackgroundColorValue,
                  let color = NSColor(hexString: storedColor)
            else {
                return Color(nsColor: NSColor.resolvedWindowBackgroundColor(
                    for: isDarkMode ? .darkAqua : .aqua
                ))
            }

            return Color(nsColor: color)
        }

        return Color(hexString: isDarkMode
            ? appearanceSettingKeysManager.backgroundDarkColor
            : appearanceSettingKeysManager.backgroundColor)
    }

    private func setBackgroundColor(_ color: Color, isDarkMode: Bool) {
        if usesLiquidGlassColors {
            if isDarkMode {
                appearanceSettingKeysManager.liquidGlassBackgroundDarkColor = color.toHex()
            } else {
                appearanceSettingKeysManager.liquidGlassBackgroundColor = color.toHex()
            }
        } else if isDarkMode {
            appearanceSettingKeysManager.backgroundDarkColor = color.toHex()
        } else {
            appearanceSettingKeysManager.backgroundColor = color.toHex()
        }
    }

    private func resetBackgroundColors() {
        if usesLiquidGlassColors {
            appearanceSettingKeysManager.liquidGlassBackgroundColor = SettingKeys.liquidGlassBackgroundColor.defaultValue as! String
            appearanceSettingKeysManager.liquidGlassBackgroundDarkColor = SettingKeys.liquidGlassBackgroundDarkColor.defaultValue as! String
        } else {
            appearanceSettingKeysManager.backgroundColor = SettingKeys.backgroundColor.defaultValue as! String
            appearanceSettingKeysManager.backgroundDarkColor = SettingKeys.backgroundDarkColor.defaultValue as! String
        }
    }
}
