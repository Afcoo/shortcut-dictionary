import SwiftUI

final class ChatSettingKeysManager: SettingKeysManagerBindable {
    @NotifyingAppStorage(SettingKeys.isChatEnabled.rawValue)
    var isChatEnabled = SettingKeys.isChatEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.selectedChat.rawValue)
    var selectedChat = SettingKeys.selectedChat.defaultValue as! String

    @NotifyingAppStorage(SettingKeys.selectedChatPromptID.rawValue)
    var selectedChatPromptID = SettingKeys.selectedChatPromptID.defaultValue as! String

    static var shared = ChatSettingKeysManager()

    private init() {}
}
