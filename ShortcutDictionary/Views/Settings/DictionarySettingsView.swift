import SwiftUI

struct DictionarySettingsView: View {
    @AppStorage("selected_dictonary") var selectedDict: Dicts = .daum
    @AppStorage("enable_always_on_top") var isAlwaysOnTop: Bool = false
    @AppStorage("enable_toolbar") var isToolbarEnabled: Bool = true
    @AppStorage("enable_show_on_mouse_position") var isShowOnMousePos: Bool = true
    @AppStorage("enable_close_with_esc") var isEscToClose: Bool = true
    @AppStorage("enable_close_with_out_click") var isOutClickToClose: Bool = true

    var body: some View {
        Form {
            // 사전 선택
            Picker("사전 종류", selection: $selectedDict) {
                ForEach(Dicts.allCases, id: \.self) { dict in
                    Text(Dicts.getName(dict)).tag(dict)
                }
            }.pickerStyle(.radioGroup)

            // 항상 위에 표시
            Toggle(isOn: $isAlwaysOnTop) {
                Text("항상 위에 표시")
            }

            // 툴바 표시
            Toggle(isOn: $isToolbarEnabled) {
                Text("툴바 표시")
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
