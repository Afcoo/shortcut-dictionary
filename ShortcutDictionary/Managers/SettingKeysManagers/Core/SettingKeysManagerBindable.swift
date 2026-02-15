import SwiftUI

protocol SettingKeysManagerBindable: ObservableObject {}

extension SettingKeysManagerBindable where Self: AnyObject {
    func binding<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}
