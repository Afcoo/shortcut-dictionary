import SwiftUI

final class DictionarySettingKeysManager: SettingKeysManagerBindable {
    @NotifyingAppStorage(SettingKeys.selectedDict.rawValue)
    var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @NotifyingAppStorage(SettingKeys.selectedPageMode.rawValue)
    var selectedPageMode = SettingKeys.selectedPageMode.defaultValue as! String

    @NotifyingAppStorage(SettingKeys.isMobileView.rawValue)
    var isMobileView = SettingKeys.isMobileView.defaultValue as! Bool

    static var shared = DictionarySettingKeysManager()

    private init() {}
}
