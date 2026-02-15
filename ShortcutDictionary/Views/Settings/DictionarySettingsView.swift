import SwiftUI

struct DictionarySettingsView: View {
    @ObservedObject private var dictionarySettingKeysManager = DictionarySettingKeysManager.shared
    @ObservedObject private var webDictManager = WebDictManager.shared

    @State private var showDictActivationSetting = false

    var body: some View {
        Form {
            // 사전 선택
            Picker("사전 종류", selection: dictionarySettingKeysManager.binding(\.selectedDict)) {
                ForEach(webDictManager.getActivatedDicts(), id: \.self) { dict in
                    Text(dict.wrappedName)
                        .tag(dict.id)
                }
            }
            .pickerStyle(.menu)
            .id(webDictManager.activatedDictIDs)

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
            Toggle(isOn: dictionarySettingKeysManager.binding(\.isMobileView)) {
                Text("모바일 뷰 사용")
                Text("설정을 적용하기 위해 재시작이 필요합니다")
            }
            .onChange(of: dictionarySettingKeysManager.isMobileView) { _ in
                NotificationCenter.default.post(name: .reloadDict, object: nil) // 사전 창 새로고침
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
