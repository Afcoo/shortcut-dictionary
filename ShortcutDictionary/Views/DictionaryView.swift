import SwiftUI

struct DictionaryView: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @AppStorage(SettingKeys.isToolbarEnabled.rawValue)
    private var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.dictViewPadding.rawValue)
    private var dictViewPadding = SettingKeys.dictViewPadding.defaultValue as! Double

    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 사전 웹 뷰
            if WebDictManager.shared.getDict(selectedDict) != nil {
                WebDictView(webDict: WebDictManager.shared.getDict(selectedDict)!)
                    .clipShape(RoundedRectangle(cornerRadius:
                        isLiquidGlassEnabled
                            ? max(26.0 - dictViewPadding, 14.0)
                            : max(15.0 - dictViewPadding, 10.0)
                    ))
                    .accessibilitySortPriority(2) // 사전에 우선적 포커스
                    .padding([.horizontal, .bottom], dictViewPadding)
                    .padding(.top, (!isLiquidGlassEnabled && isToolbarEnabled) ? 36.0 : dictViewPadding)
                    .id([isToolbarEnabled, isLiquidGlassEnabled]) // 해당 값이 바뀔 때 뷰 새로고침
            }

            // 툴바
            if isToolbarEnabled {
                if #available(macOS 26.0, *), isLiquidGlassEnabled {
                    // 신버전 툴바 (Liquid Glass)
                    DictToolbarV2()
                        .accessibilitySortPriority(1)
                        .gesture(WindowDragGesture()) // 툴바로도 윈도우를 움직일 수 있게 설정
                        .padding(.all, dictViewPadding)
                } else {
                    DictToolbar()
                        .accessibilitySortPriority(1)
                        .padding(.all, 8.0)
                }
            }
        }
        .setViewColoredBackground() // 배경 색상 설정
        .setDictViewContextMenu() // Edge 우클릭 시 메뉴 표시
    }
}

#Preview {
    DictionaryView()
}
