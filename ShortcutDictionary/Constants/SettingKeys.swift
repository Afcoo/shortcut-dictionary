import SwiftUI

enum SettingKeys: String, CaseIterable {
    case isGlobalShortcutEnabled = "enable_global_shortcut"
    case isChatShortcutEnabled = "enable_chat_shortcut"
    case isCopyPasteEnabled = "enable_copy_paste"
    case isMenuItemEnabled = "enable_menu_item"
    case isAlwaysOnTop = "enable_always_on_top"
    case isToolbarEnabled = "enable_toolbar"
    case isToolbarBackForwardButtonEnabled = "enable_toolbar_back_forward_button"
    case isToolbarReloadButtonEnabled = "enable_toolbar_reload_button"
    case isEscToClose = "enable_close_with_esc"
    case isOutClickToClose = "enable_close_with_out_click"
    case isShowOnMousePos = "enable_show_on_mouse_position"
    case isShowOnScreenCenter

    // 마우스 위치에 사전 표시 상세 설정
    case dictWindowCursorPlacement
    case dictWindowCursorGap
    case isDictWindowKeepInScreen

    /// 빠른 검색 활성화
    case isFastSearchEnabled

    case hasCompletedOnboarding

    // Appearance
    case backgroundColor
    case backgroundDarkColor
    case isBackgroundTransparent
    case dictViewPadding
    case isLiquidGlassEnabled

    // 사전 종류
    case selectedDict
    case selectedChat
    case selectedPageMode
    case customDictData
    case activatedDicts // 사용 활성화한 사전
    case activatedChats
    case isChatEnabled

    case selectedChatPromptID
    case customChatPromptsData

    /// 모바일 뷰 사용 여부
    case isMobileView

    var defaultValue: Any {
        switch self {
        case .isGlobalShortcutEnabled: return false
        case .isChatShortcutEnabled: return false
        case .isCopyPasteEnabled: return false
        case .isMenuItemEnabled: return true
        case .isAlwaysOnTop: return false
        case .isToolbarEnabled: return true
        case .isToolbarBackForwardButtonEnabled: return false
        case .isToolbarReloadButtonEnabled: return true
        case .isEscToClose: return true
        case .isOutClickToClose: return true
        case .isShowOnMousePos: return true
        case .isShowOnScreenCenter: return false
        case .dictWindowCursorPlacement: return DictWindowCursorPlacement.center.rawValue
        case .dictWindowCursorGap: return 12.0
        case .isDictWindowKeepInScreen: return true
        case .hasCompletedOnboarding: return false
        // 빠른 검색 활성화
        case .isFastSearchEnabled: return false
        // Appearance
        case .backgroundColor: return "#FFFFFF" // 라이트 모드 배경 색상
        case .backgroundDarkColor: return "#1E1E1E" // 다크 모드 배경 색상
        case .isBackgroundTransparent: return true
        case .dictViewPadding: return if #available(macOS 26.0, *) { 0.0 } else { 8.0 }
        case .isLiquidGlassEnabled: return if #available(macOS 26.0, *) { true } else { false } // macOS Tahoe에서만 기본 설정
        // 사전 종류
        case .selectedDict: return "daum_eng"
        case .selectedChat: return "chatgpt"
        case .selectedPageMode: return "dictionary"
        case .customDictData: return ""
        case .activatedDicts: return ""
        case .activatedChats: return ""
        case .isChatEnabled: return true
        case .selectedChatPromptID: return "preset_all_words"
        case .customChatPromptsData: return ""
        case .isMobileView: return true
        }
    }
}

/// 설정 초기화 관련
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

enum DictWindowCursorPlacement: String, CaseIterable, Identifiable {
    case topLeading
    case top
    case topTrailing
    case leading
    case center
    case trailing
    case bottomLeading
    case bottom
    case bottomTrailing

    var id: Self {
        self
    }

    var displayName: String {
        switch self {
        // displayName is where the window appears relative to cursor
        case .topLeading: return "오른쪽 아래"
        case .top: return "아래"
        case .topTrailing: return "왼쪽 아래"
        case .leading: return "오른쪽"
        case .center: return "가운데"
        case .trailing: return "왼쪽"
        case .bottomLeading: return "오른쪽 위"
        case .bottom: return "위"
        case .bottomTrailing: return "왼쪽 위"
        }
    }
}
