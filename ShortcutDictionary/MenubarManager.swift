import Cocoa
import SwiftUI

class MenubarManager {
    @AppStorage("enable_menu_item") var isMenuItemEnabled: Bool = true
    @AppStorage("enable_toolbar") var isToolbarEnabled: Bool = true

    static var shared = MenubarManager()

    var statusBarItem: NSStatusItem!
    var statusBarMenu: NSMenu!

    private init() {}

    func registerMenuBarItem() {
        if isMenuItemEnabled {
            setupMenuBarItem()
        } else {
            removeMenuBarItem()
        }
    }
}

// 앱 메뉴 관련
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

            // View 메뉴 (sidebar 대체)
            let viewMenuItem = NSMenuItem()
            let viewMenu = NSMenu(title: "보기")
            viewMenuItem.submenu = viewMenu
            mainMenu.addItem(viewMenuItem)

            // 툴바 표시 메뉴
            let toolbarMenuItem = NSMenuItem(title: "툴바 표시",
                                             action: #selector(toggleToolbar),
                                             keyEquivalent: "t")
            toolbarMenuItem.target = self
            viewMenu.addItem(toolbarMenuItem)

            // 새로 고침 메뉴
            let reloadMenuItem = NSMenuItem(title: "새로 고침",
                                            action: #selector(reloadDict),
                                            keyEquivalent: "r")
            reloadMenuItem.target = self
            viewMenu.addItem(reloadMenuItem)

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

// 메뉴바 아이템 (MenubarExtra) 관련
extension MenubarManager {
    public func setupMenuBarItem() {
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
            NSMenuItem(title: "종료", action: #selector(quitApp), keyEquivalent: "q")
        ]

        for index in menuItems.indices {
            menuItems[index].target = self
            menu.addItem(menuItems[index])
        }

        statusBarMenu = menu
    }

    public func removeMenuBarItem() {
        statusBarItem = nil
    }

    @objc func statusBarButtonClicked(_ sender: Any?) {
        let event = NSApp.currentEvent!

        if event.type == NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = statusBarMenu
            statusBarItem.button?.performClick(nil)
            statusBarItem.menu = nil

        } else {
            ShortcutManager.shared.activateDict(false)
        }
    }
}

// objc functions
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
        isToolbarEnabled.toggle()
    }

    @objc func reloadDict() {
        NotificationCenter.default.post(name: .reloadDict, object: "")
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
