import SwiftUI

class WebDictManager {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    static let shared = WebDictManager()

    var customDict = WebDict(
        id: "custom",
        name: "커스텀 사전",
        url: "https://www.google.com",
        script: ""
    )

    var activatedDictIDs: Set<String> = ["daum_eng"]

    private init() {
        self.loadCustomDict()
        self.loadActivatedDicts()
    }

    deinit {
        self.saveActivatedDicts()
    }
}

extension WebDictManager {
    func loadCustomDict() {
        guard let data = UserDefaults.standard.data(forKey: SettingKeys.customDictData.rawValue),
              let decoded = try? JSONDecoder().decode(WebDict.self, from: data)
        else { return }

        self.customDict = decoded
    }

    func saveCustomDict(_ dict: WebDict) {
        self.customDict = dict

        if let encoded = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.customDictData.rawValue)
        }
    }

    func loadActivatedDicts() {
        guard let data = UserDefaults.standard.data(forKey: SettingKeys.activatedDicts.rawValue),
              let decoded = try? JSONDecoder().decode([String].self, from: data)
        else { return }

        if decoded.isEmpty {
            self.activatedDictIDs = ["daum_eng"] // 활성 사전이 0개인경우 다음 영어사전 강제 추가
        } else {
            self.activatedDictIDs = Set(decoded)
        }
    }

    func saveActivatedDicts() {
        if let encoded = try? JSONEncoder().encode(activatedDictIDs) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.activatedDicts.rawValue)
        }
    }
}

extension WebDictManager {
    func isActivated(id: String) -> Bool {
        return self.activatedDictIDs.contains(id)
    }

    func setActivation(_ to: Bool, id: String) {
        if to {
            self.activatedDictIDs.insert(id)
        } else {
            self.activatedDictIDs.remove(id)

            if id == self.selectedDict {
                self.selectedDict = self.activatedDictIDs.first ?? ""
            }
        }

        self.saveActivatedDicts()
    }
}

extension WebDictManager {
    func getDict(_ id: String) -> WebDict? {
        return self.getAllSelectableDicts().first { $0.id == id }
    }

    func getAllDicts() -> [WebDict] {
        return DefaultWebDicts.all + [self.customDict]
    }

    func getAllSelectableDicts() -> [WebDict] {
        let filtered = DefaultWebDicts.all.flatMap { rootDict in
            rootDict.filterRecursively { dict in !dict.isEmptyParent }
        }

        return filtered + [self.customDict]
    }

    func getActivatedDicts() -> [WebDict] {
        let allDicts = self.getAllSelectableDicts()

        return allDicts.filter { dict in
            self.activatedDictIDs.contains(dict.id)
        }
    }
}
