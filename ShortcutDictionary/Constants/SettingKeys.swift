import SwiftUI

enum SettingKeys: String, CaseIterable {
    case isGlobalShortcutEnabled = "enable_global_shortcut"
    case isCopyPasteEnabled = "enable_copy_paste"
    case isMenuItemEnabled = "enable_menu_item"
    case isAlwaysOnTop = "enable_always_on_top"
    case isToolbarEnabled = "enable_toolbar"
    case isEscToClose = "enable_close_with_esc"
    case isOutClickToClose = "enable_close_with_out_click"
    case isShowOnMousePos = "enable_show_on_mouse_position"

    case hasCompletedOnboarding

    // Appearance
    case backgroundColor
    case isBackgroundTransparent

    // 사전 종류
    case selectedDict
    case customDictData

    var defaultValue: Any {
        switch self {
        case .isGlobalShortcutEnabled: return false
        case .isCopyPasteEnabled: return true
        case .isMenuItemEnabled: return true
        case .isAlwaysOnTop: return false
        case .isToolbarEnabled: return true
        case .isEscToClose: return true
        case .isOutClickToClose: return true
        case .isShowOnMousePos: return true
        case .hasCompletedOnboarding: return false
        // Appearance
        case .backgroundColor: return "0xE7E7E7"
        case .isBackgroundTransparent: return true
        // 사전 종류
        case .selectedDict: return DictType.daum
        case .customDictData: return ""
        }
    }
}

// 설정 초기화 관련
extension UserDefaults {
    func resetKeys() {
        for item in SettingKeys.allCases {
            if item == .hasCompletedOnboarding { continue } // onboarding 세팅은 초기화 X

            removeObject(forKey: item.rawValue)
        }
    }

    func resetKey(_ key: SettingKeys) {
        removeObject(forKey: key.rawValue)
    }
}
