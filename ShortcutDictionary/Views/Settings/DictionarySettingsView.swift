import SwiftUI

struct DictionarySettingsView: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @AppStorage(SettingKeys.isMobileView.rawValue)
    private var isMobileView = SettingKeys.isMobileView.defaultValue as! Bool

    @AppStorage(SettingKeys.isAlwaysOnTop.rawValue)
    private var isAlwaysOnTop = SettingKeys.isAlwaysOnTop.defaultValue as! Bool

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

    @AppStorage(SettingKeys.activatedDicts.rawValue)
    private var activatedDicts = SettingKeys.activatedDicts.defaultValue as! String

    @State private var showDictActivationSetting = false

    var body: some View {
        Form {
            // 사전 선택
            Picker("사전 종류", selection: $selectedDict) {
                ForEach(WebDictManager.shared.getActivatedDicts(), id: \.self) { dict in
                    Text(dict.wrappedName)
                        .tag(dict.id)
                }
            }
            .pickerStyle(.menu)
            .id(activatedDicts)

            // 사전 종류 관리
            LabeledContent("") {
                Button("사전 종류 관리") {
                    showDictActivationSetting = true
                }
                .sheet(isPresented: $showDictActivationSetting) {
                    DictActivationSettingSheet(isPresented: $showDictActivationSetting)
                }
            }

            // 모바일/PC 뷰 설정
            Toggle(isOn: $isMobileView) {
                Text("모바일 뷰 사용")
                Text("설정을 적용하기 위해 재시작이 필요합니다")
            }
            .onChange(of: isMobileView) { _ in
                NotificationCenter.default.post(name: .reloadDict, object: "") // 사전 창 새로고침
            }

            Section("사전 표시 설정") {
                // 항상 위에 표시
                Toggle(isOn: $isAlwaysOnTop) {
                    Text("항상 위에 표시")
                }
                .onChange(of: isAlwaysOnTop) { toValue in
                    WindowManager.shared.setDictAlwaysOnTop(toValue)
                }

                // 마우스 위치에 사전 표시
                Toggle(isOn: $isShowOnMousePos) {
                    Text("마우스 위치에 사전 표시")
                }

                if isShowOnMousePos {
                    // 마우스 기준 표시 위치
                    Picker("마우스 기준 표시 위치", selection: $dictWindowCursorPlacement) {
                        ForEach(DictWindowCursorPlacement.allCases) { placement in
                            Text(placement.displayName)
                                .tag(placement.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    // 마우스와 화면 간격
                    Slider(
                        value: $dictWindowCursorGap,
                        in: 0.0 ... 48.0,
                        step: 12.0
                    ) {
                        Text("마우스와 화면 간격")
                    }

                    // 화면 안에만 사전 표시
                    Toggle(isOn: $isDictWindowKeepInScreen) {
                        Text("화면 안에서만 사전 표시")
                    }
                }
            }

            Section("사전 닫기 설정") {
                // ESC키로 사전 닫기
                Toggle(isOn: $isEscToClose) {
                    Text("ESC키로 사전 닫기")
                }

                // 사전 밖 클릭 시 닫기
                Toggle(isOn: $isOutClickToClose) {
                    Text("사전 밖 클릭 시 닫기")
                }
                .onChange(of: isOutClickToClose) { toValue in
                    WindowManager.shared.setOutClickToClose(toValue)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }
}
