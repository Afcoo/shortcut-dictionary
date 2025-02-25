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
                    Text(dict.getName())
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
            }
            .onChange(of: isMobileView) { _ in
                NotificationCenter.default.post(name: .reloadDict, object: "") // 사전 창 새로고침
            }

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

            // ESC로 사전 닫기
            Toggle(isOn: $isEscToClose) {
                Text("ESC키로 사전 닫기")
            }

            // 사전 바깥 클릭 시 닫기
            Toggle(isOn: $isOutClickToClose) {
                Text("사전 밖 클릭 시 닫기")
            }
            .onChange(of: isOutClickToClose) { toValue in
                WindowManager.shared.setOutClickToClose(toValue)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }
}
