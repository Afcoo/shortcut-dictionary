import Foundation

struct ChatPrompt: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var prefix: String
    var postfix: String
    var isPreset: Bool

    func wrap(_ text: String) -> String {
        return prefix + text + postfix
    }
}

enum ChatPromptPresets {
    static let none = ChatPrompt(
        id: "none",
        name: "원본 입력",
        prefix: "",
        postfix: "",
        isPreset: true
    )

    static let translate = ChatPrompt(
        id: "preset_translate",
        name: "번역",
        prefix: "다음을 한국어로 번역:\n",
        postfix: "",
        isPreset: true
    )

    static let relatedWords = ChatPrompt(
        id: "preset_all_words",
        name: "모든 단어 검색",
        prefix: "문장 속 고유 단어들만 뜻 검색:\n",
        postfix: "",
        isPreset: true
    )

    static let meaningAndExamples = ChatPrompt(
        id: "preset_meaning_examples",
        name: "단어 및 예문",
        prefix: "단어의 뜻을 품사별로 정리 후, 각각의 뜻에 예문 하나씩:\n",
        postfix: "",
        isPreset: true
    )

    static let all: [ChatPrompt] = [
        none,
        translate,
        relatedWords,
        meaningAndExamples,
    ]
}
