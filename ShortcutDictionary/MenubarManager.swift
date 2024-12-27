import Cocoa
import SwiftUI

class MenubarManager {
    @AppStorage("enable_menu_item") var isMenuItemEnabled: Bool = true

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
//            if !icon.isEmpty {
//                button.image = NSImage(named: icon,)
//            } else {
//                button.image = NSImage(systemSymbolName: "character.book.closed.fill", accessibilityDescription: "Menu Icon")
//            }
            button.image = image
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp]) // 좌/우클릭 모두 감지
            button.target = self
        }

        let menu = NSMenu(title: "단축어 사전")

        let menuItems = [
            NSMenuItem(title: "사전 열기", action: #selector(menuItemClicked(_:)), keyEquivalent: "1"),
            NSMenuItem(title: "설정", action: #selector(menuItemClicked(_:)), keyEquivalent: "2"),
            NSMenuItem.separator(),
            NSMenuItem(title: "종료", action: #selector(quitApp(_:)), keyEquivalent: "q")
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

    @objc func menuItemClicked(_ sender: NSMenuItem) {
        if sender.title == "사전 열기" {
            ShortcutManager.shared.activateDict(false)
        } else if sender.title == "설정" {
            WindowManager.shared.showSettings()
        }
    }

    @objc func quitApp(_ sender: Any?) {
        NSApplication.shared.terminate(self)
    }
}
