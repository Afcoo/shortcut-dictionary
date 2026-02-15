import SwiftUI

extension View {
    func setViewColoredBackground<S: Shape>(shape: S = .rect) -> some View {
        modifier(SetViewColoredBackground(shape: shape))
    }
}

struct SetViewColoredBackground<S: Shape>: ViewModifier {
    var shape: S

    @Environment(\.colorScheme) var colorScheme

    @AppStorage(SettingKeys.backgroundColor.rawValue)
    private var backgroundColor = SettingKeys.backgroundColor.defaultValue as! String

    @AppStorage(SettingKeys.backgroundDarkColor.rawValue)
    private var backgroundDarkColor = SettingKeys.backgroundDarkColor.defaultValue as! String

    @AppStorage(SettingKeys.isBackgroundTransparent.rawValue)
    private var isBackgroundTransparent = SettingKeys.isBackgroundTransparent.defaultValue as! Bool

    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    var color: Color {
        colorScheme == .light
            ? Color(hexString: backgroundColor)
            : Color(hexString: backgroundDarkColor)
    }

    var colorOpacity: Double {
        colorScheme == .light
            ? 0.15
            : 0.3
    }

    func body(content: Content) -> some View {
        content
            .background {
                // macOS 26.0 이상에서 Liquid Glass 디자인 활성화 가능
                if #available(macOS 26.0, *), isLiquidGlassEnabled {
                    Color.clear
                        .glassEffect(.regular.tint(color.opacity(colorOpacity)), in: shape)
                } else {
                    if isBackgroundTransparent {
                        color
                            .opacity(colorOpacity)
                            .background(Material.thin)
                            .ignoresSafeArea()
                    } else {
                        color
                    }
                }
            }
    }
}
