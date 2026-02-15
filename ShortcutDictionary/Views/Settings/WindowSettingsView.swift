import SwiftUI

struct WindowSettingsView: View {
    @ObservedObject private var windowSettingKeysManager = WindowSettingKeysManager.shared

    var body: some View {
        Form {
            Section("표시 설정") {
                Toggle(isOn: windowSettingKeysManager.binding(\.isAlwaysOnTop)) {
                    Text("항상 위에 표시")
                }
                .onChange(of: windowSettingKeysManager.isAlwaysOnTop) { toValue in
                    WindowManager.shared.setDictAlwaysOnTop(toValue)
                }

                Toggle(isOn: windowSettingKeysManager.binding(\.isShowOnScreenCenter)) {
                    Text("항상 화면 중앙에 표시")
                }
                .onChange(of: windowSettingKeysManager.isShowOnScreenCenter) { newValue in
                    if newValue { windowSettingKeysManager.isShowOnMousePos = false }
                }

                Toggle(isOn: windowSettingKeysManager.binding(\.isShowOnMousePos)) {
                    Text("마우스 위치에 창 표시")
                }
                .onChange(of: windowSettingKeysManager.isShowOnMousePos) { newValue in
                    if newValue { windowSettingKeysManager.isShowOnScreenCenter = false }
                }

                if windowSettingKeysManager.isShowOnMousePos {
                    Picker("마우스 기준 표시 위치", selection: windowSettingKeysManager.binding(\.dictWindowCursorPlacement)) {
                        ForEach(DictWindowCursorPlacement.allCases) { placement in
                            Text(placement.displayName)
                                .tag(placement.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    Slider(
                        value: windowSettingKeysManager.binding(\.dictWindowCursorGap),
                        in: 0.0 ... 48.0,
                        step: 12.0
                    ) {
                        Text("마우스와 화면 간격")
                    }

                    Toggle(isOn: windowSettingKeysManager.binding(\.isDictWindowKeepInScreen)) {
                        Text("화면 안에서만 창 표시")
                    }
                }
            }

            Section("닫기 설정") {
                Toggle(isOn: windowSettingKeysManager.binding(\.isEscToClose)) {
                    Text("ESC키로 창 닫기")
                }

                Toggle(isOn: windowSettingKeysManager.binding(\.isOutClickToClose)) {
                    Text("창 밖 클릭 시 닫기")
                }
                .onChange(of: windowSettingKeysManager.isOutClickToClose) { toValue in
                    WindowManager.shared.setOutClickToClose(toValue)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
