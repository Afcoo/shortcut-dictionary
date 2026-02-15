import SwiftUI

extension Notification.Name {
    static let updateText = Notification.Name("updateText")
    static let reloadDict = Notification.Name("reloadDict")
    static let pageModeChanged = Notification.Name("pageModeChanged")
}

enum NotificationUserInfoKey {
    static let text = "text"
    static let mode = "mode"
}
