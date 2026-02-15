import SwiftUI

struct DictionaryView: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @AppStorage(SettingKeys.selectedChat.rawValue)
    private var selectedChat = SettingKeys.selectedChat.defaultValue as! String

    @AppStorage(SettingKeys.selectedPageMode.rawValue)
    private var selectedPageMode = SettingKeys.selectedPageMode.defaultValue as! String

    @AppStorage(SettingKeys.isChatEnabled.rawValue)
    private var isChatEnabled = SettingKeys.isChatEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.isToolbarEnabled.rawValue)
    private var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.dictViewPadding.rawValue)
    private var dictViewPadding = SettingKeys.dictViewPadding.defaultValue as! Double

    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    @State private var postLastCopiedTextWorkItem: DispatchWorkItem?

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let currentWebDict {
                webContainer(
                    view: WebDictView(webDict: currentWebDict, mode: pageMode)
                )
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
        .onChange(of: selectedPageMode) { _ in
            ShortcutManager.shared.postLastCopiedTextIfExists(mode: pageMode)
        }
        .onChange(of: selectedDict) { _ in
            guard pageMode == "dictionary" else { return }
            schedulePostLastCopiedText(mode: "dictionary")
        }
        .onChange(of: selectedChat) { _ in
            guard pageMode == "chat" else { return }
            schedulePostLastCopiedText(mode: "chat")
        }
        .onChange(of: isChatEnabled) { enabled in
            if !enabled, selectedPageMode == "chat" {
                selectedPageMode = "dictionary"
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .pageModeChanged)) { notification in
            guard let mode = notification.object as? String,
                  mode != selectedPageMode
            else { return }

            selectedPageMode = mode
        }
        .onAppear {
            if WebDictManager.shared.getDict(selectedDict) == nil {
                selectedDict = WebDictManager.shared.getActivatedDicts().first?.id ?? "daum_eng"
            }

            if WebDictManager.shared.getChat(selectedChat) == nil {
                selectedChat = WebDictManager.shared.getActivatedChats().first?.id ?? "chatgpt"
            }
        }
    }

    var pageMode: String {
        if selectedPageMode == "chat", isChatEnabled {
            return "chat"
        }

        return "dictionary"
    }

    var currentWebDict: WebDict? {
        return WebDictManager.shared.getSelectedWebDict(
            mode: pageMode,
            selectedDictID: selectedDict,
            selectedChatID: selectedChat
        )
    }

    func webContainer<Content: View>(view: Content) -> some View {
        view
            .clipShape(RoundedRectangle(cornerRadius:
                isLiquidGlassEnabled
                    ? max(26.0 - dictViewPadding, 14.0)
                    : max(15.0 - dictViewPadding, 10.0)))
            .accessibilitySortPriority(2)
            .padding([.horizontal, .bottom], dictViewPadding)
            .padding(.top, (!isLiquidGlassEnabled && isToolbarEnabled) ? 36.0 : dictViewPadding)
            .id("\(isToolbarEnabled)-\(isLiquidGlassEnabled)")
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
