import Cocoa
import SwiftUI

class MenubarManager {
    private let generalSettingKeysManager = GeneralSettingKeysManager.shared
    private let appearanceSettingKeysManager = AppearanceSettingKeysManager.shared
    private let dictionarySettingKeysManager = DictionarySettingKeysManager.shared
    private let chatSettingKeysManager = ChatSettingKeysManager.shared

    static var shared = MenubarManager()

    var statusBarItem: NSStatusItem!
    var statusBarMenu: NSMenu!

    private init() {}

    func registerMenuBarItem() {
        if generalSettingKeysManager.isMenuItemEnabled {
            setupMenuBarItem()
        } else {
            removeMenuBarItem()
        }
    }
}

/// 앱 메뉴 관련
extension MenubarManager {
    func setupMenu() {
        if let mainMenu = NSApp.mainMenu {
            // 기존 메뉴 아이템들을 모두 제거
            mainMenu.removeAllItems()

            // 앱 메뉴 (좌측 첫번째 메뉴)
            let appMenuItem = NSMenuItem()
            let appMenu = NSMenu()
            appMenuItem.submenu = appMenu
            mainMenu.addItem(appMenuItem)

            // About 메뉴
            let aboutMenuItem = NSMenuItem(title: "단축키 사전에 관하여",
                                           action: #selector(showAbout),
                                           keyEquivalent: "")
            aboutMenuItem.target = self
            appMenu.addItem(aboutMenuItem)

            appMenu.addItem(NSMenuItem.separator())

            // Settings 메뉴
            let settingsMenuItem = NSMenuItem(title: "설정",
                                              action: #selector(showSettings),
                                              keyEquivalent: ",")
            settingsMenuItem.target = self
            appMenu.addItem(settingsMenuItem)

            appMenu.addItem(NSMenuItem.separator())

            // Quit 메뉴
            let quitMenuItem = NSMenuItem(title: "단축키 사전 종료",
                                          action: #selector(quitApp),
                                          keyEquivalent: "q")
            quitMenuItem.target = self
            appMenu.addItem(quitMenuItem)

            // 편집 메뉴 추가
            let editMenuItem = NSMenuItem()
            let editMenu = NSMenu(title: "편집")
            editMenuItem.submenu = editMenu
            mainMenu.addItem(editMenuItem)

            // Undo/Redo
            let undoMenuItem = NSMenuItem(title: "실행 취소",
                                          action: Selector("undo:"),
                                          keyEquivalent: "z")
            editMenu.addItem(undoMenuItem)

            let redoMenuItem = NSMenuItem(title: "실행 복귀",
                                          action: Selector("redo:"),
                                          keyEquivalent: "Z")
            editMenu.addItem(redoMenuItem)

            editMenu.addItem(NSMenuItem.separator())

            // Cut/Copy/Paste
            let cutMenuItem = NSMenuItem(title: "오려두기",
                                         action: Selector("cut:"),
                                         keyEquivalent: "x")
            editMenu.addItem(cutMenuItem)

            let copyMenuItem = NSMenuItem(title: "복사하기",
                                          action: Selector("copy:"),
                                          keyEquivalent: "c")
            editMenu.addItem(copyMenuItem)

            let pasteMenuItem = NSMenuItem(title: "붙여넣기",
                                           action: Selector("paste:"),
                                           keyEquivalent: "v")
            editMenu.addItem(pasteMenuItem)

            let deleteMenuItem = NSMenuItem(title: "삭제",
                                            action: Selector("delete:"),
                                            keyEquivalent: "\u{8}")
            editMenu.addItem(deleteMenuItem)

            editMenu.addItem(NSMenuItem.separator())

            // Select All
            let selectAllMenuItem = NSMenuItem(title: "모두 선택",
                                               action: Selector("selectAll:"),
                                               keyEquivalent: "a")
            editMenu.addItem(selectAllMenuItem)

            let dictionaryMenuItem = NSMenuItem()
            let dictionaryMenu = NSMenu(title: "사전")
            dictionaryMenuItem.submenu = dictionaryMenu
            mainMenu.addItem(dictionaryMenuItem)

            let shouldUseDictionaryQuickShortcuts = dictionarySettingKeysManager.selectedPageMode != "chat"
            let activatedDicts = WebDictManager.shared.getActivatedDicts()
            for index in activatedDicts.indices {
                let dictQuickChangeMenuItem: NSMenuItem

                if index < 9, shouldUseDictionaryQuickShortcuts {
                    dictQuickChangeMenuItem = NSMenuItem(
                        title: activatedDicts[index].name ?? "",
                        action: #selector(changeDictionary(_:)),
                        keyEquivalent: String(index + 1)
                    )
                } else {
                    dictQuickChangeMenuItem = NSMenuItem(
                        title: activatedDicts[index].name ?? "",
                        action: #selector(changeDictionary(_:)),
                        keyEquivalent: ""
                    )
                }

                dictQuickChangeMenuItem.target = self
                dictQuickChangeMenuItem.representedObject = activatedDicts[index].id
                dictQuickChangeMenuItem.state = dictionarySettingKeysManager.selectedDict == activatedDicts[index].id ? .on : .off
                dictionaryMenu.addItem(dictQuickChangeMenuItem)
            }

            let chatMenuItem = NSMenuItem()
            let chatMenu = NSMenu(title: "채팅")
            chatMenuItem.submenu = chatMenu
            mainMenu.addItem(chatMenuItem)

            let shouldUseChatQuickShortcuts = chatSettingKeysManager.isChatEnabled && dictionarySettingKeysManager.selectedPageMode == "chat"
            if chatSettingKeysManager.isChatEnabled {
                let activatedChats = WebDictManager.shared.getActivatedChats()
                for index in activatedChats.indices {
                    let chatQuickChangeMenuItem: NSMenuItem

                    if index < 9, shouldUseChatQuickShortcuts {
                        chatQuickChangeMenuItem = NSMenuItem(
                            title: activatedChats[index].name ?? "",
                            action: #selector(changeChat(_:)),
                            keyEquivalent: String(index + 1)
                        )
                    } else {
                        chatQuickChangeMenuItem = NSMenuItem(
                            title: activatedChats[index].name ?? "",
                            action: #selector(changeChat(_:)),
                            keyEquivalent: ""
                        )
                    }

                    chatQuickChangeMenuItem.target = self
                    chatQuickChangeMenuItem.representedObject = activatedChats[index].id
                    chatQuickChangeMenuItem.state = chatSettingKeysManager.selectedChat == activatedChats[index].id ? .on : .off
                    chatMenu.addItem(chatQuickChangeMenuItem)
                }
            }

            // View 메뉴 (sidebar 대체)
            let viewMenuItem = NSMenuItem()
            let viewMenu = NSMenu(title: "보기")
            viewMenuItem.submenu = viewMenu
            mainMenu.addItem(viewMenuItem)

            // 툴바 표시 메뉴
            let toolbarMenuItem = NSMenuItem(title: "툴바 표시",
                                             action: #selector(toggleToolbar),
                                             keyEquivalent: "t")
            toolbarMenuItem.state = appearanceSettingKeysManager.isToolbarEnabled ? .on : .off
            toolbarMenuItem.target = self
            viewMenu.addItem(toolbarMenuItem)

            // 새로 고침 메뉴
            let reloadMenuItem = NSMenuItem(title: "새로 고침",
                                            action: #selector(reloadDict),
                                            keyEquivalent: "r")
            reloadMenuItem.target = self
            viewMenu.addItem(reloadMenuItem)

            viewMenu.addItem(NSMenuItem.separator())

            let dictionaryModeMenuItem = NSMenuItem(
                title: "사전 모드",
                action: #selector(changeDictionaryMode),
                keyEquivalent: ""
            )
            dictionaryModeMenuItem.target = self
            dictionaryModeMenuItem.state = dictionarySettingKeysManager.selectedPageMode == "dictionary" ? .on : .off
            viewMenu.addItem(dictionaryModeMenuItem)

            let chatModeMenuItem = NSMenuItem(
                title: "채팅 모드",
                action: #selector(changeChatMode),
                keyEquivalent: ""
            )
            chatModeMenuItem.target = self
            chatModeMenuItem.state = dictionarySettingKeysManager.selectedPageMode == "chat" ? .on : .off
            chatModeMenuItem.isEnabled = chatSettingKeysManager.isChatEnabled
            viewMenu.addItem(chatModeMenuItem)

            viewMenu.addItem(NSMenuItem.separator())

            // 창 닫기 메뉴
            let closeMenuItem = NSMenuItem(title: "창 닫기",
                                           action: #selector(closeWindow),
                                           keyEquivalent: "w")
            closeMenuItem.target = self
            viewMenu.addItem(closeMenuItem)
        }
    }
}

/// 메뉴바 아이템 (MenubarExtra) 관련
extension MenubarManager {
    func setupMenuBarItem() {
        if statusBarItem != nil {
            return
        }
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {
            let image: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 18
                $0.size.width = 18 / ratio
                return $0
            }(NSImage(named: "icon_flat")!)

            image.isTemplate = true // 색상 변경을 위한 템플릿 이미지로 설정

            button.image = image
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp]) // 좌/우클릭 모두 감지
            button.target = self
        }

        let menu = NSMenu(title: "단축어 사전")

        let menuItems = [
            NSMenuItem(title: "사전 열기", action: #selector(showDict), keyEquivalent: "1"),
            NSMenuItem(title: "설정", action: #selector(showSettings), keyEquivalent: "2"),
            NSMenuItem.separator(),
            NSMenuItem(title: "종료", action: #selector(quitApp), keyEquivalent: "q"),
        ]

        for index in menuItems.indices {
            menuItems[index].target = self
            menu.addItem(menuItems[index])
        }

        statusBarMenu = menu
    }

    func removeMenuBarItem() {
        statusBarItem = nil
    }

    @objc func statusBarButtonClicked(_: Any?) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
            statusBarItem.menu = nil

        } else {
            if dictionarySettingKeysManager.selectedPageMode == "chat" {
                ShortcutManager.shared.activate(mode: "chat", doCopyPaste: false)
            } else {
                ShortcutManager.shared.activate(mode: "dictionary", doCopyPaste: false)
            }
        }
    }
}

/// objc functions
extension MenubarManager {
    @objc func showDict() {
        WindowManager.shared.showDict()
    }

    @objc func showSettings() {
        WindowManager.shared.showSettings()
    }

    @objc func showAbout() {
        WindowManager.shared.showAbout()
    }

    @objc func toggleToolbar() {
        appearanceSettingKeysManager.isToolbarEnabled.toggle()
        setupMenu()
    }

    @objc func changeDictionary(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else {
            return
        }

        dictionarySettingKeysManager.selectedDict = id
        setupMenu()
    }

    @objc func changeChat(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else {
            return
        }

        chatSettingKeysManager.selectedChat = id
        setupMenu()
    }

    @objc func changeDictionaryMode() {
        dictionarySettingKeysManager.selectedPageMode = "dictionary"
        setupMenu()
    }

    @objc func changeChatMode() {
        guard chatSettingKeysManager.isChatEnabled else {
            return
        }

        dictionarySettingKeysManager.selectedPageMode = "chat"
        setupMenu()
    }

    @objc func reloadDict() {
        NotificationCenter.default.post(
            name: .reloadDict,
            object: nil,
            userInfo: [NotificationUserInfoKey.mode: dictionarySettingKeysManager.selectedPageMode]
        )
    }

    @objc func closeWindow() {
        if let window = NSApplication.shared.keyWindow {
            if window == WindowManager.shared.dictWindow {
                WindowManager.shared.closeDict()
            } else {
                window.close()
            }
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
