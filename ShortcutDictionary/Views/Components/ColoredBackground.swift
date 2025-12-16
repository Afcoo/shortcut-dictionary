import SwiftUI

struct ColoredBackground: View {
    @Environment(\.colorScheme) var colorScheme

    @AppStorage(SettingKeys.backgroundColor.rawValue)
    private var backgroundColor = SettingKeys.backgroundColor.defaultValue as! String

    @AppStorage(SettingKeys.isBackgroundTransparent.rawValue)
    private var isBackgroundTransparent = SettingKeys.isBackgroundTransparent.defaultValue as! Bool

    var color: Color {
        Color(nsColor: NSColor(hexString: backgroundColor) ?? NSColor.windowBackgroundColor)
    }

    var body: some View {
        if isBackgroundTransparent {
            if #available(macOS 26.0, *) {
                Rectangle()
                    .glassEffect(.regular.tint(color.opacity(0.1)), in: .rect)
            }
            else {
                color
                    .opacity(colorScheme == .dark ? 0.3 : 0.15)
                    .background(Material.thin)
            }
        }
        else {
            color
        }
    }
}
