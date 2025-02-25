import SwiftUI

class WebDictManager {
    static let shared = WebDictManager()

    private var customDict = WebDict(
        id: "custom",
        name: "커스텀 사전",
        url: "https://www.google.com",
        script: ""
    )

    private init() {
        self.loadCustomDict()
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

    func getDict(_ dictId: String) -> WebDict? {
        return self.getAllDicts().first { $0.id == dictId }
    }

    func getAllDicts() -> [WebDict] {
        return defaultWebDicts + [self.customDict]
    }
}
