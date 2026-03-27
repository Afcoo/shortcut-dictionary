import SwiftUI

struct DictionaryView: View {
    @ObservedObject private var dictionarySettingKeysManager = DictionarySettingKeysManager.shared
    @ObservedObject private var chatSettingKeysManager = ChatSettingKeysManager.shared
    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared

    @State private var postLastCopiedTextWorkItem: DispatchWorkItem?

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let currentWebDict {
                webContainer(
                    view: WebDictView(webDict: currentWebDict, mode: pageMode)
                )
            }

            // 툴바
            if appearanceSettingKeysManager.isToolbarEnabled {
                if #available(macOS 26.0, *), appearanceSettingKeysManager.isLiquidGlassEnabled {
                    // 신버전 툴바 (Liquid Glass)
                    DictToolbarV2()
                        .accessibilitySortPriority(1)
                        .gesture(WindowDragGesture()) // 툴바로도 윈도우를 움직일 수 있게 설정
                        .padding(.all, appearanceSettingKeysManager.dictViewPadding)
                } else {
                    DictToolbar()
                        .accessibilitySortPriority(1)
                        .padding(.all, 8.0)
                }
            }
        }
        .setViewColoredBackground() // 배경 색상 설정
        .setDictViewContextMenu() // Edge 우클릭 시 메뉴 표시
        .onChange(of: dictionarySettingKeysManager.selectedPageMode) {
            ShortcutManager.shared.postLastCopiedTextIfExists(mode: pageMode)
        }
        .onChange(of: dictionarySettingKeysManager.selectedDict) {
            guard pageMode == "dictionary" else { return }
            schedulePostLastCopiedText(mode: "dictionary")
        }
        .onChange(of: chatSettingKeysManager.selectedChat) {
            guard pageMode == "chat" else { return }
            schedulePostLastCopiedText(mode: "chat")
        }
        .onChange(of: chatSettingKeysManager.isChatEnabled) {
            WebDictManager.shared.normalizeState()
        }
        .onReceive(NotificationCenter.default.publisher(for: .pageModeChanged)) { notification in
            guard let mode = notification.object as? String,
                  mode != dictionarySettingKeysManager.selectedPageMode
            else { return }

            dictionarySettingKeysManager.selectedPageMode = mode
        }
        .onAppear {
            WebDictManager.shared.normalizeState()
        }
    }

    var pageMode: String {
        if dictionarySettingKeysManager.selectedPageMode == "chat", chatSettingKeysManager.isChatEnabled {
            return "chat"
        }

        return "dictionary"
    }

    var currentWebDict: WebDict? {
        return WebDictManager.shared.getSelectedWebDict(
            mode: pageMode,
            selectedDictID: dictionarySettingKeysManager.selectedDict,
            selectedChatID: chatSettingKeysManager.selectedChat
        )
    }

    func webContainer<Content: View>(view: Content) -> some View {
        view
            .clipShape(RoundedRectangle(cornerRadius:
                appearanceSettingKeysManager.isLiquidGlassEnabled
                    ? max(26.0 - appearanceSettingKeysManager.dictViewPadding, 14.0)
                    : max(15.0 - appearanceSettingKeysManager.dictViewPadding, 10.0)))
            .accessibilitySortPriority(2)
            .padding([.horizontal, .bottom], appearanceSettingKeysManager.dictViewPadding)
            .padding(.top, (!appearanceSettingKeysManager.isLiquidGlassEnabled && appearanceSettingKeysManager.isToolbarEnabled) ? 36.0 : appearanceSettingKeysManager.dictViewPadding)
            .id("\(appearanceSettingKeysManager.isToolbarEnabled)-\(appearanceSettingKeysManager.isLiquidGlassEnabled)")
    }

    private func schedulePostLastCopiedText(mode: String) {
        postLastCopiedTextWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            ShortcutManager.shared.postLastCopiedTextIfExists(mode: mode)
        }

        postLastCopiedTextWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}

#Preview {
    DictionaryView()
}
