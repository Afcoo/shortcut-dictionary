import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared

    var body: some View {
        Form {
            // 툴바 표시
            Toggle(isOn: appearanceSettingKeysManager.binding(\.isToolbarEnabled)) {
                Text("툴바 표시")
            }

            // 사전 뷰 Padding 조절
            Slider(value: appearanceSettingKeysManager.binding(\.dictViewPadding), in: 0.0 ... 28.0, step: 4.0) {
                Text("배경 두께 설정")
            }

            // 배경 색상
            HStack {
                Text("배경 색상")
                Spacer()

                // 리셋 버튼
                Button(
                    action: {
                        appearanceSettingKeysManager.backgroundColor = SettingKeys.backgroundColor.defaultValue as! String
                        appearanceSettingKeysManager.backgroundDarkColor = SettingKeys.backgroundDarkColor.defaultValue as! String
                    },
                    label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                    }
                )
                .buttonStyle(.borderless)

                // 라이트 모드 색상 선택
                ColorPicker("라이트 모드 색상",
                            selection: Binding(
                                get: { Color(hexString: appearanceSettingKeysManager.backgroundColor) },
                                set: { newColor in appearanceSettingKeysManager.backgroundColor = newColor.toHex() }
                            ),
                            supportsOpacity: false)
                    .labelsHidden()
                    .overlay {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.init(white: 0.2))
                            .font(.system(size: 14))
                            .allowsHitTesting(false)
                    }

                // 다크 모드 색상 선택
                ColorPicker("다크 모드 색상",
                            selection: Binding(
                                get: { Color(hexString: appearanceSettingKeysManager.backgroundDarkColor) },
                                set: { newColor in appearanceSettingKeysManager.backgroundDarkColor = newColor.toHex() }
                            ),
                            supportsOpacity: false)
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
                .onChange(of: appearanceSettingKeysManager.isLiquidGlassEnabled) { value in
                    if value {
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
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
