import Foundation
import SwiftData

@Model
final class CustomChatPromptEntity {
    @Attribute(.unique) var id: String
    var name: String
    var prefix: String
    var postfix: String

    init(from prompt: ChatPrompt) {
        id = prompt.id
        name = prompt.name
        prefix = prompt.prefix
        postfix = prompt.postfix
    }

    func update(from prompt: ChatPrompt) {
        name = prompt.name
        prefix = prompt.prefix
        postfix = prompt.postfix
    }

    func toChatPrompt() -> ChatPrompt {
        return ChatPrompt(
            id: id,
            name: name,
            prefix: prefix,
            postfix: postfix,
            isPreset: false
        )
    }
}

private final class SwiftDataCustomChatPromptStore {
    static let shared: SwiftDataCustomChatPromptStore? = try? SwiftDataCustomChatPromptStore()

    private let context: ModelContext

    private init() throws {
        let schema = Schema([CustomChatPromptEntity.self])
        let configuration = ModelConfiguration("CustomChatPrompt")
        let container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }

    func load() -> [ChatPrompt] {
        let descriptor = FetchDescriptor<CustomChatPromptEntity>(sortBy: [SortDescriptor(\CustomChatPromptEntity.name)])
        let entities = (try? context.fetch(descriptor)) ?? []
        return entities.map { $0.toChatPrompt() }
    }

    func upsert(_ prompt: ChatPrompt) {
        let descriptor = FetchDescriptor<CustomChatPromptEntity>()
        let existing = (try? context.fetch(descriptor))?.first { $0.id == prompt.id }

        if let existing {
            existing.update(from: prompt)
        } else {
            context.insert(CustomChatPromptEntity(from: prompt))
        }

        try? context.save()
    }

    func delete(id: String) {
        let descriptor = FetchDescriptor<CustomChatPromptEntity>()
        if let targets = (try? context.fetch(descriptor))?.filter({ $0.id == id }) {
            for target in targets {
                context.delete(target)
            }
        }

        try? context.save()
    }
}

final class CustomChatPromptStore {
    static let shared = CustomChatPromptStore()

    private init() {}

    func load() -> [ChatPrompt] {
        return SwiftDataCustomChatPromptStore.shared?.load() ?? []
    }

    func upsert(_ prompt: ChatPrompt) {
        SwiftDataCustomChatPromptStore.shared?.upsert(prompt)
    }

    func delete(id: String) {
        SwiftDataCustomChatPromptStore.shared?.delete(id: id)
    }
}
