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
        prefix: "다음을 한국어로 번역해줘:\n\n",
        postfix: "",
        isPreset: true
    )

    static let relatedWords = ChatPrompt(
        id: "preset_related_words",
        name: "모든 단어 검색",
        prefix: "아래 단어를 포함한 핵심 표현을 최대한 많이 찾아줘:\n\n",
        postfix: "",
        isPreset: true
    )

    static let meaningAndExamples = ChatPrompt(
        id: "preset_meaning_examples",
        name: "단어 및 예문",
        prefix: "아래 단어의 뜻을 품사별로 정리하고, 자연스러운 예문 5개를 작성해줘:\n\n",
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
