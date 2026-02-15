import SwiftUI

extension View {
    func setDictViewContextMenu() -> some View {
        modifier(DictViewContextMenu())
    }
}

struct DictViewContextMenu: ViewModifier {
    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared
    @ObservedObject private var dictionarySettingKeysManager = DictionarySettingKeysManager.shared

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button(action: {
                    appearanceSettingKeysManager.isToolbarEnabled.toggle()
                }) {
                    HStack {
                        if appearanceSettingKeysManager.isToolbarEnabled {
                            Image(systemName: "checkmark")
                                .imageScale(.small)
                        }
                        Text("툴바 표시")
                    }
                }
                .keyboardShortcut("T", modifiers: .command)

                Button("새로 고침") {
                    NotificationCenter.default.post(
                        name: .reloadDict,
                        object: nil,
                        userInfo: [NotificationUserInfoKey.mode: dictionarySettingKeysManager.selectedPageMode]
                    )
                }
                .keyboardShortcut("R", modifiers: .command)

                Button("창 닫기") {
                    WindowManager.shared.closeDict()
                }
                .keyboardShortcut("W", modifiers: .command)

                Divider()

                Button("종료") {
                    NSApplication.shared.terminate(self)
                }
                .keyboardShortcut("Q", modifiers: .command)
            }
    }
}
