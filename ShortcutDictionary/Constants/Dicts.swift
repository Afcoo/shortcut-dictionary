import SwiftUI

enum Dicts: String, CaseIterable {
    case daum = "https://small.dic.daum.net/top/search.do?dic=eng"
    case naver = "https://en.dict.naver.com"

    static func getURL(_ dict: Self) -> URL {
        return URL(string: dict.rawValue)!
    }

    static func getName(_ dict: Self) -> String {
        switch dict {
        case .daum:
            return "다음 사전"
        case .naver:
            return "네이버 사전"
        }
    }

    static func getPasteScript(_ dict: Self, value: String) -> String {
        switch dict {
        case .daum:
            return """
            q.value = "\(value)";
            q.select()
            if(document.getElementById("searchBar") !== null) {
                searchBar.click();
            }
            """
        case .naver:
            return """
            var input = jQuery('#ac_input');
            input[0].value = '\(value)';
            input.focus();
            """
        }
    }
}
