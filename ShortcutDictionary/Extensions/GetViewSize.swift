import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

/// View extension to read view height
extension View {
    func getViewSize(_ getSize: @escaping ((CGSize) -> Void)) -> some View {
        return background {
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { value in
                        getSize(value)
                    }
            }
        }
    }
}
