import SwiftUI

struct DictionarySettingsView: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @AppStorage(SettingKeys.isAlwaysOnTop.rawValue)
    private var isAlwaysOnTop = SettingKeys.isAlwaysOnTop.defaultValue as! Bool

    @AppStorage(SettingKeys.isShowOnMousePos.rawValue)
    private var isShowOnMousePos = SettingKeys.isShowOnMousePos.defaultValue as! Bool

    @AppStorage(SettingKeys.isEscToClose.rawValue)
    private var isEscToClose = SettingKeys.isEscToClose.defaultValue as! Bool

    @AppStorage(SettingKeys.isOutClickToClose.rawValue)
    private var isOutClickToClose = SettingKeys.isOutClickToClose.defaultValue as! Bool

    @State private var showCustomDictSetting = false

    var body: some View {
        Form {
            // 사전 선택
            Picker("사전 종류", selection: $selectedDict) {
                ForEach(WebDictManager.shared.getAllDicts(), id: \.self) { dict in
                    Text(dict.getName())
                        .tag(dict.id)
                }
            }.pickerStyle(.menu)

            if selectedDict == "custom" {
                LabeledContent("") {
                    Button("커스텀 사전 설정") {
                        showCustomDictSetting = true
                    }
                    .sheet(isPresented: $showCustomDictSetting) {
                        CustomDictSettingSheet(isPresented: $showCustomDictSetting)
                    }
                }
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
