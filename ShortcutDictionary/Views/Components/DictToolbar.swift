import AppKit
import SwiftUI

struct DictToolbar: View {
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

    @State private var showMenu = false
    @State private var showDictActivationSetting = false
    @State private var showPromptMenu = false
    @State private var ellipsisMenuBridge = DictToolbarEllipsisMenuBridge()

    var body: some View {
        HStack {
            // 닫기 버튼
            ToolbarButton(
                action: { WindowManager.shared.closeDict() },
                systemName: "xmark.circle"
            )

            // 좌우 간격 맞추기용
            Image(systemName: "space")
                .foregroundStyle(.clear)
                .imageScale(.large)

            Spacer()

            HStack(spacing: 20) {
                HStack {
                    Button(action: { showMenu.toggle() }) {
                        HStack {
                            Text(currentWebName)
                                .lineLimit(1)

                            Image(systemName: "chevron.down")
                                .imageScale(.small)
                                .foregroundColor(Color(.tertiaryLabelColor))
                        }
                        .frame(alignment: .center)
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
                        }
                        .padding(.all, 8)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: 150)
                }

                if pageMode == "chat" {
                    HStack {
                        Button(action: { showPromptMenu.toggle() }) {
                            HStack {
                                Text(WebDictManager.shared.getSelectedChatPrompt().name)
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .imageScale(.small)
                                    .foregroundColor(Color(.tertiaryLabelColor))
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
                            .padding(8)
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: 150)
                    }
                }
            }

            Spacer()

            // 새로고침 버튼
            ToolbarButton(
                action: {
                    NotificationCenter.default.post(
                        name: .reloadDict,
                        object: nil,
                        userInfo: [NotificationUserInfoKey.mode: pageMode]
                    )
                },
                systemName: "arrow.clockwise.circle"
            )

            // 설정 버튼
            ToolbarButton(
                action: { showEllipsisContextMenu() },
                systemName: "ellipsis.circle"
            )
        }
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

        let dictionaryItem = NSMenuItem(title: "사전 모드", action: #selector(DictToolbarEllipsisMenuBridge.selectDictionary), keyEquivalent: "")
        dictionaryItem.target = ellipsisMenuBridge
        dictionaryItem.state = pageMode == "dictionary" ? .on : .off
        menu.addItem(dictionaryItem)

        let chatItem = NSMenuItem(title: "채팅 모드", action: #selector(DictToolbarEllipsisMenuBridge.selectChat), keyEquivalent: "")
        chatItem.target = ellipsisMenuBridge
        chatItem.state = pageMode == "chat" ? .on : .off
        chatItem.isEnabled = isChatEnabled
        menu.addItem(chatItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "설정 열기", action: #selector(DictToolbarEllipsisMenuBridge.openSettings), keyEquivalent: "")
        settingsItem.target = ellipsisMenuBridge
        menu.addItem(settingsItem)

        guard let event = NSApp.currentEvent else { return }
        NSMenu.popUpContextMenu(menu, with: event, for: NSApp.keyWindow?.contentView ?? NSView())
    }
//
//    private func openDict() {
//        WindowManager.shared.showDict()
//    }
//
//    private func reloadDict() {
//        NotificationCenter.default.post(name: .reloadDict, object: "")
//    }
//
//    private func closeDict() {
//        WindowManager.shared.closeDict()
//    }
//
//    private func openSettingPage() {
//        WindowManager.shared.showSettings()
//    }
}

final class DictToolbarEllipsisMenuBridge: NSObject {
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

#Preview {
    DictToolbar()
}
