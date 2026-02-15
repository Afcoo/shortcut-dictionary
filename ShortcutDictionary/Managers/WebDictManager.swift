import SwiftUI

class WebDictManager: ObservableObject {
    private let dictionarySettingKeysManager = DictionarySettingKeysManager.shared
    private let chatSettingKeysManager = ChatSettingKeysManager.shared

    static let shared = WebDictManager()

    @Published var customDicts: [WebDict] = []
    @Published var customChats: [WebDict] = []

    @Published var activatedDictIDs: Set<String> = ["daum_eng"]
    @Published var activatedChatIDs: Set<String> = ["chatgpt"]
    @Published var customChatPrompts: [ChatPrompt] = []

    private init() {
        loadCustomWebDicts()
        loadActivatedDicts()
        loadActivatedChats()
        loadCustomChatPrompts()
    }

    deinit {
        self.saveActivatedDicts()
        self.saveActivatedChats()
        self.saveCustomChatPrompts()
    }
}

extension WebDictManager {
    func loadCustomWebDicts() {
        customDicts = CustomWebDictStore.shared.load(mode: "dictionary")
        customChats = CustomWebDictStore.shared.load(mode: "chat")
    }

    @discardableResult
    func addCustomWebDict(mode: String) -> WebDict {
        let defaultName = mode == "chat" ? "새 커스텀 서비스" : "새 커스텀 사전"
        let webDict = WebDict(
            id: UUID().uuidString,
            name: defaultName,
            url: "https://www.google.com",
            script: ""
        )

        CustomWebDictStore.shared.upsert(webDict, mode: mode)
        if mode == "chat" {
            customChats.append(webDict)
        } else {
            customDicts.append(webDict)
        }

        return webDict
    }

    func updateCustomWebDict(_ dict: WebDict, mode: String) {
        CustomWebDictStore.shared.upsert(dict, mode: mode)

        if mode == "chat" {
            if let index = customChats.firstIndex(where: { $0.id == dict.id }) {
                customChats[index] = dict
            }
        } else {
            if let index = customDicts.firstIndex(where: { $0.id == dict.id }) {
                customDicts[index] = dict
            }
        }
    }

    func deleteCustomWebDict(id: String, mode: String) {
        CustomWebDictStore.shared.delete(id: id, mode: mode)

        if mode == "chat" {
            customChats.removeAll { $0.id == id }
            activatedChatIDs.remove(id)

            if activatedChatIDs.isEmpty {
                activatedChatIDs = ["chatgpt"]
            }

            if chatSettingKeysManager.selectedChat == id {
                chatSettingKeysManager.selectedChat = activatedChatIDs.first ?? "chatgpt"
            }

            saveActivatedChats()
        } else {
            customDicts.removeAll { $0.id == id }
            activatedDictIDs.remove(id)

            if activatedDictIDs.isEmpty {
                activatedDictIDs = ["daum_eng"]
            }

            if dictionarySettingKeysManager.selectedDict == id {
                dictionarySettingKeysManager.selectedDict = activatedDictIDs.first ?? "daum_eng"
            }

            saveActivatedDicts()
        }
    }

    @discardableResult
    func importLegacyCustomDictFromAppStorage() -> Bool {
        guard let data = UserDefaults.standard.data(forKey: SettingKeys.customDictData.rawValue),
              let decoded = try? JSONDecoder().decode(WebDict.self, from: data)
        else {
            return false
        }

        if customDicts.contains(where: { $0.url == decoded.url && $0.script == decoded.script }) {
            return false
        }

        var importedDict = decoded
        importedDict.id = UUID().uuidString
        importedDict.name = importedDict.name?.isEmpty == false ? importedDict.name : "기존 커스텀 사전"

        CustomWebDictStore.shared.upsert(importedDict, mode: "dictionary")
        customDicts.append(importedDict)
        activatedDictIDs.insert(importedDict.id)

        if dictionarySettingKeysManager.selectedDict == "custom" || getDict(dictionarySettingKeysManager.selectedDict) == nil {
            dictionarySettingKeysManager.selectedDict = importedDict.id
        }

        saveActivatedDicts()
        UserDefaults.standard.removeObject(forKey: SettingKeys.customDictData.rawValue)
        return true
    }

    func loadActivatedDicts() {
        guard let data = UserDefaults.standard.data(forKey: SettingKeys.activatedDicts.rawValue),
              let decoded = try? JSONDecoder().decode([String].self, from: data)
        else { return }

        let validIDs = Set(decoded).intersection(Set(getAllSelectableDicts().map { $0.id }))

        if validIDs.isEmpty {
            activatedDictIDs = ["daum_eng"] // 활성 사전이 0개인경우 다음 영어사전 강제 추가
        } else {
            activatedDictIDs = validIDs
        }
    }

    func saveActivatedDicts() {
        if let encoded = try? JSONEncoder().encode(activatedDictIDs) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.activatedDicts.rawValue)
        }
    }

    func loadActivatedChats() {
        guard let data = UserDefaults.standard.data(forKey: SettingKeys.activatedChats.rawValue),
              let decoded = try? JSONDecoder().decode([String].self, from: data)
        else { return }

        let validIDs = Set(decoded).intersection(Set(getAllSelectableChats().map { $0.id }))
        if validIDs.isEmpty {
            activatedChatIDs = ["chatgpt"]
        } else {
            activatedChatIDs = validIDs
        }
    }

    func saveActivatedChats() {
        if let encoded = try? JSONEncoder().encode(activatedChatIDs) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.activatedChats.rawValue)
        }
    }

    func loadCustomChatPrompts() {
        guard let data = UserDefaults.standard.data(forKey: SettingKeys.customChatPromptsData.rawValue),
              let decoded = try? JSONDecoder().decode([ChatPrompt].self, from: data)
        else { return }

        customChatPrompts = decoded
    }

    func saveCustomChatPrompts() {
        if let encoded = try? JSONEncoder().encode(customChatPrompts) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.customChatPromptsData.rawValue)
        }
    }

    func addCustomChatPrompt(name: String, prefix: String, postfix: String) {
        let prompt = ChatPrompt(
            id: UUID().uuidString,
            name: name,
            prefix: prefix,
            postfix: postfix,
            isPreset: false
        )

        customChatPrompts.append(prompt)
        saveCustomChatPrompts()
    }

    func deleteCustomChatPrompt(id: String) {
        customChatPrompts.removeAll { $0.id == id }

        if chatSettingKeysManager.selectedChatPromptID == id {
            chatSettingKeysManager.selectedChatPromptID = ChatPromptPresets.none.id
        }

        saveCustomChatPrompts()
    }
}

extension WebDictManager {
    func isActivated(id: String) -> Bool {
        return activatedDictIDs.contains(id)
    }

    func setActivation(_ to: Bool, id: String) {
        if to {
            activatedDictIDs.insert(id)
        } else {
            activatedDictIDs.remove(id)

            if id == dictionarySettingKeysManager.selectedDict {
                dictionarySettingKeysManager.selectedDict = activatedDictIDs.first ?? ""
            }
        }

        saveActivatedDicts()
    }

    func isActivatedChat(id: String) -> Bool {
        return activatedChatIDs.contains(id)
    }

    func setChatActivation(_ to: Bool, id: String) {
        if to {
            activatedChatIDs.insert(id)
        } else {
            activatedChatIDs.remove(id)

            if id == chatSettingKeysManager.selectedChat {
                chatSettingKeysManager.selectedChat = activatedChatIDs.first ?? "chatgpt"
            }
        }

        saveActivatedChats()
    }
}

extension WebDictManager {
    static let chatIDs = DefaultChatServices.all.map { $0.id }

    func getDict(_ id: String) -> WebDict? {
        return getAllSelectableDicts().first { $0.id == id }
    }

    func getChat(_ id: String) -> WebDict? {
        return getAllSelectableChats().first { $0.id == id }
    }

    func getAllDicts() -> [WebDict] {
        return DefaultWebDicts.dictionaries + customDicts
    }

    func getAllChats() -> [WebDict] {
        return DefaultChatServices.all + customChats
    }

    func getAllSelectableDicts() -> [WebDict] {
        let filtered = DefaultWebDicts.dictionaries.flatMap { rootDict in
            rootDict.filterRecursively { dict in !dict.isEmptyParent }
        }

        return filtered + customDicts
    }

    func getAllSelectableChats() -> [WebDict] {
        return DefaultChatServices.all + customChats
    }

    func getActivatedDicts() -> [WebDict] {
        let allDicts = getAllSelectableDicts()

        return allDicts.filter { dict in
            self.activatedDictIDs.contains(dict.id)
        }
    }

    func getActivatedChats() -> [WebDict] {
        let allChats = getAllSelectableChats()

        return allChats.filter { dict in
            activatedChatIDs.contains(dict.id)
        }
    }

    func getChatPrompts() -> [ChatPrompt] {
        return ChatPromptPresets.all + customChatPrompts
    }

    func getSelectedChatPrompt() -> ChatPrompt {
        return getChatPrompts().first(where: { $0.id == chatSettingKeysManager.selectedChatPromptID }) ?? ChatPromptPresets.none
    }

    func getSelectedWebDict(mode: String, selectedDictID: String, selectedChatID: String) -> WebDict? {
        if mode == "chat" {
            return getChat(selectedChatID)
        }

        return getDict(selectedDictID)
    }
}
