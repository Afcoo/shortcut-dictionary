import SwiftUI

extension View {
    func setViewColoredBackground<S: Shape>(
        shape: S = .rect,
        followsContainerCorners: Bool = false
    ) -> some View {
        modifier(SetViewColoredBackground(
            shape: shape,
            followsContainerCorners: followsContainerCorners
        ))
    }
}

struct SetViewColoredBackground<S: Shape>: ViewModifier {
    var shape: S
    var followsContainerCorners: Bool

    @Environment(\.colorScheme) var colorScheme

    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared

    var backgroundColor: Color {
        colorScheme == .light
            ? Color(hexString: appearanceSettingKeysManager.backgroundColor)
            : Color(hexString: appearanceSettingKeysManager.backgroundDarkColor)
    }

    var liquidGlassTintColor: Color? {
        let storedColor = colorScheme == .light
            ? appearanceSettingKeysManager.liquidGlassBackgroundColor
            : appearanceSettingKeysManager.liquidGlassBackgroundDarkColor

        guard storedColor != SettingKeys.nativeWindowBackgroundColorValue,
              let color = NSColor(hexString: storedColor)
        else {
            return nil
        }

        return Color(nsColor: color)
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
                if #available(macOS 26.0, *), appearanceSettingKeysManager.isLiquidGlassEnabled {
                    if followsContainerCorners {
                        Color.clear
                            .glassEffect(.regular.tint(liquidGlassTintColor), in: ConcentricRectangle())
                    } else {
                        Color.clear
                            .glassEffect(.regular.tint(liquidGlassTintColor), in: shape)
                    }
                } else {
                    if appearanceSettingKeysManager.isBackgroundTransparent {
                        backgroundColor
                            .opacity(colorOpacity)
                            .background(Material.thin)
                            .ignoresSafeArea()
                    } else {
                        backgroundColor
                    }
                }
            }
    }
}
