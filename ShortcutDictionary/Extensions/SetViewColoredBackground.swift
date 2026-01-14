import SwiftUI

extension View {
    @ViewBuilder
    func setViewColoredBackground<S: Shape>(shape: S = .rect) -> some View {
        modifier(SetViewColoredBackground(shape: shape))
    }
}

struct SetViewColoredBackground<S: Shape>: ViewModifier {
    var shape: S

    @Environment(\.colorScheme) var colorScheme

    @AppStorage(SettingKeys.backgroundColor.rawValue)
    private var backgroundColor = SettingKeys.backgroundColor.defaultValue as! String

    @AppStorage(SettingKeys.isBackgroundTransparent.rawValue)
    private var isBackgroundTransparent = SettingKeys.isBackgroundTransparent.defaultValue as! Bool

    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    var color: Color {
        Color(nsColor: NSColor(hexString: backgroundColor) ?? NSColor.windowBackgroundColor)
    }

    func body(content: Content) -> some View {
        // macOS 26.0 이상에서 Liquid Glass 디자인 활성화 가능
        if #available(macOS 26.0, *), isLiquidGlassEnabled {
            content
                .glassEffect(.regular.tint(color.opacity(0.1)), in: shape)
        }
        else {
            content
                .background {
                    if isBackgroundTransparent {
                        color
                            .opacity(colorScheme == .dark ? 0.3 : 0.15)
                            .background(Material.thin)
                            .ignoresSafeArea()
                    }
                    else {
                        color
                    }
                }
        }
    }
}
