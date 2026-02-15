import Foundation
import SwiftData

@Model
final class CustomWebDictEntity {
    @Attribute(.unique) var id: String
    var mode: String
    var name: String
    var url: String
    var script: String
    var postScript: String
    var prefix: String
    var postfix: String

    init(from webDict: WebDict, mode: String) {
        id = webDict.id
        self.mode = mode
        name = webDict.name ?? ""
        url = webDict.url
        script = webDict.script
        postScript = webDict.postScript ?? ""
        prefix = webDict.prefix ?? ""
        postfix = webDict.postfix ?? ""
    }

    func update(from webDict: WebDict) {
        name = webDict.name ?? ""
        url = webDict.url
        script = webDict.script
        postScript = webDict.postScript ?? ""
        prefix = webDict.prefix ?? ""
        postfix = webDict.postfix ?? ""
    }

    func toWebDict() -> WebDict {
        return WebDict(
            id: id,
            name: name.isEmpty ? nil : name,
            url: url,
            script: script,
            postScript: postScript.isEmpty ? nil : postScript,
            prefix: prefix.isEmpty ? nil : prefix,
            postfix: postfix.isEmpty ? nil : postfix
        )
    }
}

private final class SwiftDataCustomWebDictStore {
    static let shared: SwiftDataCustomWebDictStore? = try? SwiftDataCustomWebDictStore()

    private let context: ModelContext

    private init() throws {
        let schema = Schema([CustomWebDictEntity.self])
        let configuration = ModelConfiguration("CustomWebDict")
        let container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }

    func load(mode: String) -> [WebDict] {
        let descriptor = FetchDescriptor<CustomWebDictEntity>(sortBy: [SortDescriptor(\CustomWebDictEntity.name)])

        let entities = (try? context.fetch(descriptor)) ?? []
        return entities
            .filter { $0.mode == mode }
            .map { $0.toWebDict() }
    }

    func upsert(_ webDict: WebDict, mode: String) {
        let descriptor = FetchDescriptor<CustomWebDictEntity>()
        let existing = (try? context.fetch(descriptor))?.first {
            $0.id == webDict.id && $0.mode == mode
        }

        if let existing {
            existing.update(from: webDict)
        } else {
            context.insert(CustomWebDictEntity(from: webDict, mode: mode))
        }

        try? context.save()
    }

    func delete(id: String, mode: String) {
        let descriptor = FetchDescriptor<CustomWebDictEntity>()

        if let targets = (try? context.fetch(descriptor))?.filter({ $0.id == id && $0.mode == mode }) {
            for target in targets {
                context.delete(target)
            }
        }

        try? context.save()
    }
}

final class CustomWebDictStore {
    static let shared = CustomWebDictStore()

    private init() {}

    func load(mode: String) -> [WebDict] {
        return SwiftDataCustomWebDictStore.shared?.load(mode: mode) ?? []
    }

    func upsert(_ webDict: WebDict, mode: String) {
        SwiftDataCustomWebDictStore.shared?.upsert(webDict, mode: mode)
    }

    func delete(id: String, mode: String) {
        SwiftDataCustomWebDictStore.shared?.delete(id: id, mode: mode)
    }
}
