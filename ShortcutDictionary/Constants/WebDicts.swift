import SwiftUI

enum DictType: String, CaseIterable {
    case daum
    case naver
    case custom
}

struct WebDict: Identifiable, Codable {
    let id: UUID
    var name: String
    var url: String
    var script: String

    init(name: String, url: String, script: String) {
        self.id = UUID()
        self.name = name
        self.url = url
        self.script = script
    }
}

class WebDicts {
    static let shared = WebDicts()

    private var dictionaries: [DictType: WebDict] = [
        .daum: WebDict(
            name: "다음 사전",
            url: "https://small.dic.daum.net/top/search.do?dic=eng",
            script: """
            q.value = SD_clipboard_value;
            q.select();
            if(document.getElementById("searchBar") !== null) {
                searchBar.click();
            }
            """
        ),
        .naver: WebDict(
            name: "네이버 사전",
            url: "https://en.dict.naver.com",
            script: """
            var input = jQuery('#ac_input');
            input[0].value = SD_clipboard_value;
            input.focus();
            """
        ),
        .custom: WebDict(
            name: "커스텀 사전",
            url: "https://m.daum.net",
            script: """
            document.querySelector("header").className = "_search_on search_on";
            q.value = SD_clipboard_value;
            const inputEvent = new Event('input', {
                bubbles: true,
                cancelable: true
              });
            q.dispatchEvent(inputEvent);
            """
        ),
    ]

    private init() {
        loadCustomDict()
    }

    func loadCustomDict() {
        guard let savedCustomDict = UserDefaults.standard.data(forKey: SettingKeys.customDictData.rawValue),
              let loadedCustomDict = try? JSONDecoder().decode(WebDict.self, from: savedCustomDict)
        else { return }

        dictionaries[.custom] = loadedCustomDict
    }

    func saveCustomDict(_ dict: WebDict) {
        dictionaries[.custom] = dict

        if let encoded = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(encoded, forKey: SettingKeys.customDictData.rawValue)
        }
    }

    func getDict(_ dictType: DictType) -> WebDict? {
        guard let dict = dictionaries[dictType] else { return nil }

        return dict
    }

    func getName(_ dictType: DictType) -> String {
        guard let dict = dictionaries[dictType] else { return "" }

        return dict.name
    }

    func getURL(_ dictType: DictType) -> URL {
        guard let dict = dictionaries[dictType] else { return URL(string: "https://small.dic.daum.net")! }

        return URL(string: dict.url)!
    }

    func getPasteScript(_ dictType: DictType, value: String) -> String {
        guard let dict = dictionaries[dictType] else { return "" }

        return """
        (() => {
            let SD_clipboard_value = `\(value)`;
            \(dict.script)
        })();
        """
    }
}
