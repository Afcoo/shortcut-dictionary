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

    var color: Color {
        colorScheme == .light
            ? Color(hexString: appearanceSettingKeysManager.backgroundColor)
            : Color(hexString: appearanceSettingKeysManager.backgroundDarkColor)
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
                            .glassEffect(.regular.tint(color), in: ConcentricRectangle())
                    } else {
                        Color.clear
                            .glassEffect(.regular.tint(color), in: shape)
                    }
                } else {
                    if appearanceSettingKeysManager.isBackgroundTransparent {
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
