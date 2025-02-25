import SwiftUI

struct WebDict: Hashable, Codable {
    var id: String // 고유 id
    var name: String? // 표시 이름

    var url: String

    var script: String
    var postScript: String? // 즉시 검색 함수

    // 검색 단어 전/후 추가 문자열
    var prefix: String?
    var postfix: String?

    func getName() -> String {
        return self.name ?? self.id
    }

    func getPasteScript(value: String) -> String? {
        return """
        (() => {
            let SD_clipboard_value = `\(value)`;
            \((self.prefix ?? "") + self.script + (self.postfix ?? ""))
        })();
        """ + (self.postScript ?? "")
    }

    func getURL() -> URL? {
        return URL(string: self.url)
    }
}

class WebDicts {
    static let shared = WebDicts()

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
