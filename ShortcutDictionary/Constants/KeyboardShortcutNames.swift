import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let dictShortcut = Self("dictShortcut", default: .init(.d, modifiers: [.control, .shift]))
    static let chatShortcut = Self("chatShortcut", default: .init(.c, modifiers: [.control, .shift]))
}
