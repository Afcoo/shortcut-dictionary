import SwiftUI

extension View {
    func setDictViewContextMenu() -> some View {
        self.modifier(DictViewContextMenu()
        )
    }
}

struct DictViewContextMenu: ViewModifier {
    @AppStorage(SettingKeys.isToolbarEnabled.rawValue)
    private var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button(action: {
                    self.isToolbarEnabled.toggle()
                }) {
                    HStack {
                        if self.isToolbarEnabled {
                            Image(systemName: "checkmark")
                                .imageScale(.small)
                        }
                        Text("툴바 표시")
                    }
                }
                .keyboardShortcut("T", modifiers: .command)

                Button("새로 고침") {
                    NotificationCenter.default.post(name: .reloadDict, object: "")
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
