import SwiftUI

final class GeneralSettingKeysManager: SettingKeysManagerBindable {
    @NotifyingAppStorage(SettingKeys.isMenuItemEnabled.rawValue)
    var isMenuItemEnabled = SettingKeys.isMenuItemEnabled.defaultValue as! Bool

    @NotifyingAppStorage(SettingKeys.hasCompletedOnboarding.rawValue)
    var hasCompletedOnboarding = SettingKeys.hasCompletedOnboarding.defaultValue as! Bool

    static var shared = GeneralSettingKeysManager()

    private init() {}
}
