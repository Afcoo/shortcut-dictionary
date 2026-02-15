import SwiftUI

struct WindowSettingsView: View {
    @AppStorage(SettingKeys.isAlwaysOnTop.rawValue)
    private var isAlwaysOnTop = SettingKeys.isAlwaysOnTop.defaultValue as! Bool

    @AppStorage(SettingKeys.isShowOnScreenCenter.rawValue)
    private var isShowOnScreenCenter = SettingKeys.isShowOnScreenCenter.defaultValue as! Bool

    @AppStorage(SettingKeys.isShowOnMousePos.rawValue)
    private var isShowOnMousePos = SettingKeys.isShowOnMousePos.defaultValue as! Bool

    @AppStorage(SettingKeys.dictWindowCursorPlacement.rawValue)
    private var dictWindowCursorPlacement = SettingKeys.dictWindowCursorPlacement.defaultValue as! String

    @AppStorage(SettingKeys.dictWindowCursorGap.rawValue)
    private var dictWindowCursorGap = SettingKeys.dictWindowCursorGap.defaultValue as! Double

    @AppStorage(SettingKeys.isDictWindowKeepInScreen.rawValue)
    private var isDictWindowKeepInScreen = SettingKeys.isDictWindowKeepInScreen.defaultValue as! Bool

    @AppStorage(SettingKeys.isEscToClose.rawValue)
    private var isEscToClose = SettingKeys.isEscToClose.defaultValue as! Bool

    @AppStorage(SettingKeys.isOutClickToClose.rawValue)
    private var isOutClickToClose = SettingKeys.isOutClickToClose.defaultValue as! Bool

    var body: some View {
        Form {
            Section("표시 설정") {
                Toggle(isOn: $isAlwaysOnTop) {
                    Text("항상 위에 표시")
                }
                .onChange(of: isAlwaysOnTop) { toValue in
                    WindowManager.shared.setDictAlwaysOnTop(toValue)
                }

                Toggle(isOn: $isShowOnScreenCenter) {
                    Text("항상 화면 중앙에 표시")
                }
                .onChange(of: isShowOnScreenCenter) { newValue in
                    if newValue { isShowOnMousePos = false }
                }

                Toggle(isOn: $isShowOnMousePos) {
                    Text("마우스 위치에 창 표시")
                }
                .onChange(of: isShowOnMousePos) { newValue in
                    if newValue { isShowOnScreenCenter = false }
                }

                if isShowOnMousePos {
                    Picker("마우스 기준 표시 위치", selection: $dictWindowCursorPlacement) {
                        ForEach(DictWindowCursorPlacement.allCases) { placement in
                            Text(placement.displayName)
                                .tag(placement.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    Slider(
                        value: $dictWindowCursorGap,
                        in: 0.0 ... 48.0,
                        step: 12.0
                    ) {
                        Text("마우스와 화면 간격")
                    }

                    Toggle(isOn: $isDictWindowKeepInScreen) {
                        Text("화면 안에서만 창 표시")
                    }
                }
            }

            Section("닫기 설정") {
                Toggle(isOn: $isEscToClose) {
                    Text("ESC키로 창 닫기")
                }

                Toggle(isOn: $isOutClickToClose) {
                    Text("창 밖 클릭 시 닫기")
                }
                .onChange(of: isOutClickToClose) { toValue in
                    WindowManager.shared.setOutClickToClose(toValue)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
