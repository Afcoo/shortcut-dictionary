import Combine
import Foundation
import SwiftUI

@propertyWrapper
struct NotifyingAppStorage<Value> {
    private let key: String
    private let defaultValue: Value
    private let store: UserDefaults

    init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store ?? .standard
    }

    @available(*, unavailable, message: "@NotifyingAppStorage can only be used on ObservableObject classes")
    var wrappedValue: Value {
        get { fatalError("Unavailable") }
        set { fatalError("Unavailable") }
    }

    static subscript<EnclosingSelf: ObservableObject>(
        _enclosingInstance observed: EnclosingSelf,
        wrapped _: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, NotifyingAppStorage<Value>>
    ) -> Value where EnclosingSelf.ObjectWillChangePublisher == ObservableObjectPublisher {
        get {
            observed[keyPath: storageKeyPath].readValue()
        }
        set {
            observed.objectWillChange.send()
            observed[keyPath: storageKeyPath].writeValue(newValue)
        }
    }

    private func readValue() -> Value {
        (store.object(forKey: key) as? Value) ?? defaultValue
    }

    private func writeValue(_ value: Value) {
        store.set(value, forKey: key)
    }
}
