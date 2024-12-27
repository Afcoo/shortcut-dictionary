import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let dictShortcut = Self("dictShortcut", default: .init(.d, modifiers: [.command, .option]))
}

extension Notification.Name {
    static let updateText = Notification.Name("updateText")
    static let showSettings = Notification.Name("showSettings")
    static let reloadDict = Notification.Name("reloadDict")
}

enum UserKeys: String, CaseIterable { // UserKeys for settings
    case selectedDict = "selected_dictonary"
    case isGlobalShortcutEnabled = "enable_global_shortcut"
    case isCopyPasteEnabled = "enable_copy_paste"
    case isMenuItemEnabled = "enable_menu_item"
    case isAlwaysOnTop = "enable_always_on_top"
    case isToolbarEnabled = "enable_toolbar"
    case isEscToClose = "enable_close_with_esc"
    case isShowOnMousePos = "enable_show_on_mouse_position"
}

enum Dicts: String, CaseIterable {
    case daum = "https://small.dic.daum.net/top/search.do?dic=eng"
    case naver = "https://en.dict.naver.com"

    static func getURL(_ dict: Self) -> URL {
        return URL(string: dict.rawValue)!
    }

    static func getName(_ dict: Self) -> String {
        switch dict {
        case .daum:
            return "다음 사전"
        case .naver:
            return "네이버 사전"
        }
    }

    static func getPasteScript(_ dict: Self, value: String) -> String {
        switch dict {
        case .daum:
            return """
            q.value = "\(value)";
            q.select()
            if(document.getElementById("searchBar") !== null) {
                searchBar.click();
            }
            """
        case .naver:
            return """
            var input = jQuery('#ac_input');
            input[0].value = '\(value)';
            input.focus();
            """
        }
    }
}
