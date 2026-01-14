import SwiftUI

extension Color {
    #if os(macOS)
        init(hexString: String) {
            let _nsColor = NSColor(hexString: hexString)

            self.init(_nsColor ?? NSColor.white)
        }

        func toHex() -> String {
            return NSColor(self).hexString
        }
    #endif
}
