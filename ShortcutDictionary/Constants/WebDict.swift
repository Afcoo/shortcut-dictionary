import SwiftUI

struct WebDict: Hashable, Codable, Identifiable {
    var id: String // 고유 id
    var name: String? // 표시 이름

    var wrappedName: String {
        self.name ?? self.id
    }

    var url: String

    var script: String
    var postScript: String? // 즉시 검색 스크립트

    // 검색 단어 전/후 추가 문자열
    var prefix: String?
    var postfix: String?

    // 하위 사전
    var isEmptyParent: Bool = false
    var children: [WebDict]?
}

extension WebDict {
    func getPasteScript(value: String, fastSearch: Bool = false) -> String? {
        return """
        (() => {
            let SD_clipboard_value = `\(value)`;
            \((self.prefix ?? "") + self.script + (self.postfix ?? ""))
        })();
        """ + (fastSearch ? (self.postScript ?? "") : "")
    }

    // 하위 항목들을 순회하며 조건에 맞는 항목을 배열로 반환
    func filterRecursively(isIncluded: (WebDict) -> Bool) -> [WebDict] {
        var results: [WebDict] = []

        if isIncluded(self) {
            results.append(self)
        }

        // 하위 항목이 있다면 재귀적으로 탐색해 결과에 추가
        if let children = self.children {
            for child in children {
                results.append(contentsOf: child.filterRecursively(isIncluded: isIncluded))
            }
        }

        return results
    }
}
