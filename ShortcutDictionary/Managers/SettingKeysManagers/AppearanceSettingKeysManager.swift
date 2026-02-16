import SwiftUI

final class AppearanceSettingKeysManager: SettingKeysManagerBindable {
    @NotifyingAppStorage(SettingKeys.isToolbarEnabled.rawValue)
    var isToolbarEnabled = SettingKeys.isToolbarEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isToolbarBackForwardButtonEnabled.rawValue)
    var isToolbarBackForwardButtonEnabled = SettingKeys.isToolbarBackForwardButtonEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isToolbarReloadButtonEnabled.rawValue)
    var isToolbarReloadButtonEnabled = SettingKeys.isToolbarReloadButtonEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.backgroundColor.rawValue)
    var backgroundColor = SettingKeys.backgroundColor.defaultValue as! String

    @NotifyingAppStorage(SettingKeys.backgroundDarkColor.rawValue)
    var backgroundDarkColor = SettingKeys.backgroundDarkColor.defaultValue as! String

    @NotifyingAppStorage(SettingKeys.isBackgroundTransparent.rawValue)
    var isBackgroundTransparent = SettingKeys.isBackgroundTransparent.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.dictViewPadding.rawValue)
    var dictViewPadding = SettingKeys.dictViewPadding.defaultValue as! Double

    @NotifyingAppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    static var shared = AppearanceSettingKeysManager()

    private init() {}
}
