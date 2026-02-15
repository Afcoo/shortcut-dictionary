import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

struct SettingsView: View {
    @State private var selectedPage: SettingsPage = .general

    var body: some View {
        NavigationSplitView {
            settingsSidebar
        } detail: {
            settingsDetail
                .navigationTitle(selectedPage.title)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(width: 480, height: 320)
    }

    // MARK: - 사이드바

    private var settingsSidebar: some View {
        List(SettingsPage.allCases, selection: $selectedPage) { page in
            Label(page.title, systemImage: page.icon)
                .tag(page)
        }
        .navigationSplitViewColumnWidth(150)
        .listStyle(.sidebar)
    }

    // MARK: - 상세 뷰

    @ViewBuilder
    private var settingsDetail: some View {
        switch selectedPage {
        case .general:
            GeneralSettingsView()
        case .shortcut:
            ShortcutSettingsView()
        case .dictionary:
            DictionarySettingsView()
        case .chat:
            ChatSettingsView()
        case .appearance:
            AppearanceSettingsView()
        case .info:
            InfoSettingsView()
        }
    }
}

enum SettingsPage: String, CaseIterable, Identifiable {
    case general
    case shortcut
    case dictionary
    case chat
    case appearance
    case info

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .general: return "일반"
        case .shortcut: return "단축키"
        case .dictionary: return "사전"
        case .chat: return "채팅"
        case .appearance: return "외관"
        case .info: return "정보"
        }
    }

    var icon: String {
        switch self {
        case .general: return "switch.2"
        case .shortcut: return "keyboard"
        case .dictionary: return "character.book.closed.fill"
        case .chat: return "bubble.left.and.bubble.right"
        case .appearance: return "paintpalette"
        case .info: return "info.circle"
        }
    }
}
