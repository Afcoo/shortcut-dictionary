import SwiftUI

final class ShortcutSettingKeysManager: SettingKeysManagerBindable {
    @NotifyingAppStorage(SettingKeys.isGlobalShortcutEnabled.rawValue)
    var isGlobalShortcutEnabled = SettingKeys.isGlobalShortcutEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isCopyPasteEnabled.rawValue)
    var isCopyPasteEnabled = SettingKeys.isCopyPasteEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isChatShortcutEnabled.rawValue)
    var isChatShortcutEnabled = SettingKeys.isChatShortcutEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isFastSearchEnabled.rawValue)
    var isFastSearchEnabled = SettingKeys.isFastSearchEnabled.defaultValue as! Bool

    static var shared = ShortcutSettingKeysManager()

    private init() {}
}
