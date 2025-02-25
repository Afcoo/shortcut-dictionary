import SwiftUI

struct DictionaryView: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @AppStorage(SettingKeys.isToolbarEnabled.rawValue)
    private var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    var _padding = 8.0

    var body: some View {
        VStack {
            // 툴바
            if isToolbarEnabled {
                Toolbar()
                    .accessibilitySortPriority(1)
                Spacer()
                    .frame(height: _padding)
            }

            // 사전 웹 뷰
            if WebDictManager.shared.getDict(selectedDict) != nil {
                WebDictView(webDict: WebDictManager.shared.getDict(selectedDict)!)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilitySortPriority(2) // 사전에 우선적 포커스
            }
        }
        .padding(_padding)
        .background { ColoredBackground().ignoresSafeArea() }
        .contextMenu { // Edge 우클릭시 표시
            Button(action: {
                isToolbarEnabled.toggle()
            }) {
                HStack {
                    if isToolbarEnabled {
                        Image(systemName: "checkmark")
                            .imageScale(.small)
                    }
                    Text("툴바 표시")
                }
            }
            .keyboardShortcut("T", modifiers: .command)

            Button("새로 고침") {
                NotificationCenter.default.post(name: .reloadDict, object: "")
            }
            .keyboardShortcut("R", modifiers: .command)

            Button("창 닫기") {
                WindowManager.shared.closeDict()
            }
            .keyboardShortcut("W", modifiers: .command)

            Divider()

            Button("종료") {
                NSApplication.shared.terminate(self)
            }
            .keyboardShortcut("Q", modifiers: .command)
        }
    }
}

#Preview {
    DictionaryView()
}
