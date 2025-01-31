import SwiftUI

struct ColoredBackground: View {
    @Environment(\.colorScheme) var colorScheme

    @AppStorage(SettingKeys.backgroundColor.rawValue)
    private var backgroundColor = SettingKeys.backgroundColor.defaultValue as! String

    @AppStorage(SettingKeys.isBackgroundTransparent.rawValue)
    private var isBackgroundTransparent = SettingKeys.isBackgroundTransparent.defaultValue as! Bool

    var body: some View {
        if isBackgroundTransparent {
            Color(nsColor: NSColor(hexString: backgroundColor) ?? NSColor.windowBackgroundColor)
                .opacity(colorScheme == .dark ? 0.3 : 0.15)
                .background(Material.thin)
        }
        else {
            Color(nsColor: NSColor(hexString: backgroundColor) ?? NSColor.windowBackgroundColor)
        }
    }
}
