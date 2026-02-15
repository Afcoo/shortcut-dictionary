enum DefaultChatServices {
    static let chatgpt = WebDict(
        id: "chatgpt",
        name: "ChatGPT",
        url: "https://chatgpt.com",
        script: """
        document.querySelector(".ProseMirror").innerText = SD_clipboard_value;
        """,
        postScript: """
        setTimeout(() => {
            document.querySelector('[data-testid="send-button"]').click();
        }, 100);
        """
    )

    static let claude = WebDict(
        id: "claude",
        name: "Claude",
        url: "https://claude.ai/",
        script: """
        document.querySelector(".ProseMirror").innerText = SD_clipboard_value;
        """,
        postScript: """
        setTimeout(() => {
            const q = document.querySelector(".ProseMirror")
            const enterEvent = new KeyboardEvent('keydown', {
                key: 'Enter',
                code: 'Enter',
                keyCode: 13,
                which: 13,
                bubbles: true,
                cancelable: true,
                metaKey: true
            }); // cmd + enter 단축키 전송

            q.dispatchEvent(enterEvent);
        }, 100);
        """
    )

    static let gemini = WebDict(
        id: "gemini",
        name: "Gemini",
        url: "https://gemini.google.com/",
        script: """
        document.querySelector(".ql-editor").innerText = SD_clipboard_value;
        """,
        postScript: """
        setTimeout(() => {
            document.querySelector(".send-button").click();
        }, 100);
        """
    )

    static let all = [chatgpt, claude, gemini]
}
