import AppKit
import SwiftUI

/// macOS Tahoe 부터 사용 가능한 Liquid Glass 툴바
@available(macOS 26.0, *)
struct DictToolbarV2: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @AppStorage(SettingKeys.selectedChat.rawValue)
    private var selectedChat = SettingKeys.selectedChat.defaultValue as! String

    @AppStorage(SettingKeys.selectedPageMode.rawValue)
    private var selectedPageMode = SettingKeys.selectedPageMode.defaultValue as! String

    @AppStorage(SettingKeys.isChatEnabled.rawValue)
    private var isChatEnabled = SettingKeys.isChatEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.selectedChatPromptID.rawValue)
    private var selectedChatPromptID = SettingKeys.selectedChatPromptID.defaultValue as! String

    @State private var showChevron = false
    @State private var showPromptChevron = false
    @State private var showMenu = false
    @State private var showDictActivationSetting = false
    @State private var showPromptMenu = false
    @State private var ellipsisMenuBridge = DictToolbarV2EllipsisMenuBridge()

    @Namespace private var namespace

    var body: some View {
        HStack {
            // 닫기 버튼
            ToolbarButtonV2(
                action: { WindowManager.shared.closeDict() },
                systemName: "xmark"
            )

            Spacer()

            HStack(spacing: 20) {
                HStack {
                    Button(action: { showMenu.toggle() }) {
                        ZStack(alignment: .trailing) {
                            Text(currentWebName)
                                .lineLimit(1)
                                .font(.system(size: 14))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 8)
                                .offset(x: showChevron || showMenu ? -6 : 0)

                            if showChevron || showMenu {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .offset(x: 6)
                            }
                        }
                    }
                    .popover(
                        isPresented: $showMenu,
                        arrowEdge: .bottom
                    ) {
                        VStack {
                            ForEach(activeWebs, id: \.self) { dict in
                                Button(
                                    dict.wrappedName,
                                    action: {
                                        if pageMode == "chat" {
                                            selectedChat = dict.id
                                        } else {
                                            selectedDict = dict.id
                                        }
                                        showMenu.toggle()
                                    }
                                )
                                .buttonStyle(.borderless)
                            }

                            Button(pageMode == "chat" ? "채팅 서비스 관리" : "사전 종류 관리") {
                                showDictActivationSetting = true
                            }
                            .buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                        }
                        .padding(.all, 8)
                        .frame(maxWidth: 180)
                    }
                    .buttonStyle(.borderless)
                    .glassEffect(.identity)
                    .onHover { isHover in
                        withAnimation {
                            showChevron = isHover
                        }
                    }
                }

                if pageMode == "chat" {
                    HStack {
                        Button(action: { showPromptMenu.toggle() }) {
                            ZStack(alignment: .trailing) {
                                Text(WebDictManager.shared.getSelectedChatPrompt().name)
                                    .lineLimit(1)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 8)
                                    .offset(x: showPromptChevron || showPromptMenu ? -6 : 0)

                                if showPromptChevron || showPromptMenu {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.secondary)
                                        .offset(x: 6)
                                }
                            }
                        }
                        .popover(
                            isPresented: $showPromptMenu,
                            arrowEdge: .bottom
                        ) {
                            VStack {
                                ForEach(WebDictManager.shared.getChatPrompts(), id: \.self) { prompt in
                                    Button(prompt.name) {
                                        selectedChatPromptID = prompt.id
                                        showPromptMenu.toggle()
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                            .padding(.all, 8)
                            .frame(maxWidth: 180)
                        }
                        .buttonStyle(.borderless)
                        .glassEffect(.identity)
                        .onHover { isHover in
                            withAnimation {
                                showPromptChevron = isHover
                            }
                        }
                    }
                }
            }

            Spacer()

//            TODO: 뒤로/앞으로 버튼 구현
//            GlassEffectContainer {
//                HStack(spacing: 0.0) {
//                    ToolbarButtonV2(
//                        action: {},
//                        systemName: "chevron.left"
//                    )
//                    .glassEffectUnion(id: "bnf", namespace: namespace)
//
//                    Divider()
//                        .frame(height: 20)
//                        .glassEffect()
//                        .glassEffectUnion(id: "bnf", namespace: namespace)
//
//                    ToolbarButtonV2(
//                        action: {},
//                        systemName: "chevron.right"
//                    )
//                    .glassEffectUnion(id: "bnf", namespace: namespace)
//                }
//            }

            // 새로고침 버튼
            ToolbarButtonV2(
                action: {
                    NotificationCenter.default.post(
                        name: .reloadDict,
                        object: nil,
                        userInfo: [NotificationUserInfoKey.mode: pageMode]
                    )
                },
                systemName: "arrow.trianglehead.clockwise"
            )

            // 설정 버튼
            ToolbarButtonV2(
                action: { showEllipsisContextMenu() },
                systemName: "ellipsis"
            )
        }
        .padding(8)
        .contentShape(.rect) // 툴바 공간을 클릭 가능하게
        .setDictViewContextMenu() // 툴바 우클릭 시 메뉴 표시
        .sheet(isPresented: $showDictActivationSetting) {
            DictActivationSettingSheet(isPresented: $showDictActivationSetting, mode: pageMode)
        }
    }

    var pageMode: String {
        if selectedPageMode == "chat", isChatEnabled {
            return "chat"
        }

        return "dictionary"
    }

    var activeWebs: [WebDict] {
        if pageMode == "chat" {
            return WebDictManager.shared.getActivatedChats()
        }

        return WebDictManager.shared.getActivatedDicts()
    }

    var currentWebName: String {
        if pageMode == "chat" {
            return WebDictManager.shared.getChat(selectedChat)?.wrappedName ?? "error"
        }

        return WebDictManager.shared.getDict(selectedDict)?.wrappedName ?? "error"
    }

    func showEllipsisContextMenu() {
        ellipsisMenuBridge.onSelectDictionary = {
            selectedPageMode = "dictionary"
        }
        ellipsisMenuBridge.onSelectChat = {
            selectedPageMode = "chat"
        }
        ellipsisMenuBridge.onOpenSettings = {
            WindowManager.shared.showSettings()
        }

        let menu = NSMenu()

        let dictionaryItem = NSMenuItem(title: "사전 모드", action: #selector(DictToolbarV2EllipsisMenuBridge.selectDictionary), keyEquivalent: "")
        dictionaryItem.target = ellipsisMenuBridge
        dictionaryItem.state = pageMode == "dictionary" ? .on : .off
        menu.addItem(dictionaryItem)

        let chatItem = NSMenuItem(title: "채팅 모드", action: #selector(DictToolbarV2EllipsisMenuBridge.selectChat), keyEquivalent: "")
        chatItem.target = ellipsisMenuBridge
        chatItem.state = pageMode == "chat" ? .on : .off
        chatItem.isEnabled = isChatEnabled
        menu.addItem(chatItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "설정 열기", action: #selector(DictToolbarV2EllipsisMenuBridge.openSettings), keyEquivalent: "")
        settingsItem.target = ellipsisMenuBridge
        menu.addItem(settingsItem)

        guard let event = NSApp.currentEvent else { return }
        NSMenu.popUpContextMenu(menu, with: event, for: NSApp.keyWindow?.contentView ?? NSView())
    }
}

final class DictToolbarV2EllipsisMenuBridge: NSObject {
    var onSelectDictionary: (() -> Void)?
    var onSelectChat: (() -> Void)?
    var onOpenSettings: (() -> Void)?

    @objc func selectDictionary() {
        onSelectDictionary?()
    }

    @objc func selectChat() {
        onSelectChat?()
    }

    @objc func openSettings() {
        onOpenSettings?()
    }
}

@available(macOS 26.0, *)
struct ToolbarButtonV2: View {
    let action: () -> Void
    let systemName: String

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(Color(.tertiaryLabelColor))
                .font(.system(size: 18))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.accessoryBar)
        .buttonBorderShape(.circle)
        .setViewColoredBackground(shape: .circle)
    }
}
