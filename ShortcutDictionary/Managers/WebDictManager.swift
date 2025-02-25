import SwiftUI

class WebDictManager {
    static let shared = WebDictManager()

    private var customDict = WebDict(
        id: "custom",
        name: "커스텀 사전",
        url: "https://www.google.com",
        script: ""
    )

    private var activatedDicts = ["daum_eng"]

    private init() {
        self.loadCustomDict()
        self.loadActivatedDicts()
    }

    deinit {
        self.saveActivatedDicts()
    }

    func loadCustomDict() {
        guard let savedCustomDict = UserDefaults.standard.data(forKey: SettingKeys.customDictData.rawValue),
              let loadedCustomDict = try? JSONDecoder().decode(WebDict.self, from: savedCustomDict)
        else { return }

        self.customDict = loadedCustomDict
    }

    func saveCustomDict(_ dict: WebDict) {
        self.customDict = dict

        if let encoded = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.customDictData.rawValue)
        }
    }

    func loadActivatedDicts() {
        guard let savedActivatedDicts = UserDefaults.standard.data(forKey: SettingKeys.customDictData.rawValue),
              let loadedActivatedDicts = try? JSONDecoder().decode([String].self, from: savedActivatedDicts)
        else { return }

        self.activatedDicts = loadedActivatedDicts

        if self.activatedDicts.isEmpty { // 활성 사전이 0개인경우 다음 영어사전 강제 추가
            self.activatedDicts.append("daum_eng")
        }
    }

    func saveActivatedDicts() {
        if let encoded = try? JSONEncoder().encode(activatedDicts) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.activatedDicts.rawValue)
        }
    }

    func getActivation(dict: WebDict) -> Bool {
        return self.activatedDicts.contains(dict.id)
    }

    func addActivation(dict: WebDict) -> Bool {
        if self.activatedDicts.contains(dict.id) || self.getAllDicts().contains(dict) {
            return false
        }

        self.activatedDicts.append(dict.id)
        return true
    }

    func removeActivation(dict: WebDict) -> Bool {
        if !self.activatedDicts.contains(dict.id) || !self.getAllDicts().contains(dict) {
            return false
        }

        self.activatedDicts.removeAll { $0 == dict.id }
        return true
    }

    func getDict(_ dictId: String) -> WebDict? {
        return self.getAllDicts().first { $0.id == dictId }
    }

    func getAllDicts() -> [WebDict] {
        let allDicts = defaultWebDicts + [self.customDict]

        return allDicts
    }

    func getActivatedDicts() -> [WebDict] {
        return self.getAllDicts().filter { self.activatedDicts.contains($0.id) }
    }
}
