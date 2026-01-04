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
                DictToolbar()
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
        .setDictViewContextMenu() // Edge 우클릭 시 메뉴 표시
    }
}

#Preview {
    DictionaryView()
}
