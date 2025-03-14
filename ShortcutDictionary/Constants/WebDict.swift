import SwiftUI

struct WebDict: Hashable, Codable {
    var id: String // 고유 id
    var name: String? // 표시 이름

    var url: String

    var script: String
    var postScript: String? // 즉시 검색 스크립트

    // 검색 단어 전/후 추가 문자열
    var prefix: String?
    var postfix: String?

    func getName() -> String {
        return self.name ?? self.id
    }

    func getPasteScript(value: String, fastSearch: Bool = false) -> String? {
        return """
        (() => {
            let SD_clipboard_value = `\(value)`;
            \((self.prefix ?? "") + self.script + (self.postfix ?? ""))
        })();
        """ + (fastSearch ? (self.postScript ?? "") : "")
    }

    func getURL() -> URL? {
        return URL(string: self.url)
    }
}
