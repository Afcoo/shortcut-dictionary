import SwiftUI

final class WindowSettingKeysManager: SettingKeysManagerBindable {
    @NotifyingAppStorage(SettingKeys.isAlwaysOnTop.rawValue)
    var isAlwaysOnTop = SettingKeys.isAlwaysOnTop.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isShowOnScreenCenter.rawValue)
    var isShowOnScreenCenter = SettingKeys.isShowOnScreenCenter.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isShowOnMousePos.rawValue)
    var isShowOnMousePos = SettingKeys.isShowOnMousePos.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.dictWindowCursorPlacement.rawValue)
    var dictWindowCursorPlacement = SettingKeys.dictWindowCursorPlacement.defaultValue as! String

    @NotifyingAppStorage(SettingKeys.dictWindowCursorGap.rawValue)
    var dictWindowCursorGap = SettingKeys.dictWindowCursorGap.defaultValue as! Double

    @NotifyingAppStorage(SettingKeys.isDictWindowKeepInScreen.rawValue)
    var isDictWindowKeepInScreen = SettingKeys.isDictWindowKeepInScreen.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isEscToClose.rawValue)
    var isEscToClose = SettingKeys.isEscToClose.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.isOutClickToClose.rawValue)
    var isOutClickToClose = SettingKeys.isOutClickToClose.defaultValue as! Bool

    static var shared = WindowSettingKeysManager()

    private init() {}
}
