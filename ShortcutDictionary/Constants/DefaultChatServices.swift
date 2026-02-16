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

    static let grok = WebDict(
        id: "grok",
        name: "Grok",
        url: "https://grok.com/",
        script: """
        let q =
            document.querySelector("textarea[aria-label*='grok' i]") ??
            document.querySelector("textarea[placeholder*='grok' i]") ??
            document.querySelector("textarea");

        if (q) {
            const setter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, "value")?.set;
            if (setter) {
                setter.call(q, SD_clipboard_value);
            } else {
                q.value = SD_clipboard_value;
            }

            q.dispatchEvent(new InputEvent("input", {
                bubbles: true,
                cancelable: true,
                data: SD_clipboard_value,
                inputType: "insertText"
            }));
            q.dispatchEvent(new Event("change", {
                bubbles: true,
                cancelable: true
            }));
        }
        """,
        postScript: """
        setTimeout(() => {
            const sendButton =
                document.querySelector("button[type='submit']") ??
                document.querySelector("button[aria-label*='submit' i]") ??
                document.querySelector("button[aria-label*='제출' i]");

            if (sendButton && !sendButton.disabled && sendButton.getAttribute("aria-disabled") != "true") {
                sendButton.click();
            }
        }, 120);
        """
    )

    static let z_ai = WebDict(
        id: "z_ai",
        name: "Z.ai",
        url: "https://chat.z.ai/",
        script: """
        let q =
            document.querySelector("#chat-input") ??
            document.querySelector("textarea[placeholder*='help' i]") ??
            document.querySelector("textarea");

        if (q) {
            const setter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, "value")?.set;
            if (setter) {
                setter.call(q, SD_clipboard_value);
            } else {
                q.value = SD_clipboard_value;
            }

            q.dispatchEvent(new InputEvent("input", {
                bubbles: true,
                cancelable: true,
                data: SD_clipboard_value,
                inputType: "insertText"
            }));
            q.dispatchEvent(new Event("change", {
                bubbles: true,
                cancelable: true
            }));
        }
        """,
        postScript: """
        setTimeout(() => {
            const sendButton =
                document.querySelector("#send-message-button") ??
                document.querySelector("button[type='submit']") ??
                document.querySelector("button[aria-label*='send' i]");

            if (sendButton && !sendButton.disabled && sendButton.getAttribute("aria-disabled") != "true") {
                sendButton.click();
            }
        }, 120);
        """
    )

    static let perplexity = WebDict(
        id: "perplexity",
        name: "Perplexity",
        url: "https://www.perplexity.ai/",
        script: """
        const closeButton =
            document.querySelector("button[aria-label*='close' i]") ??
            document.querySelector("button[aria-label*='닫기' i]");
        if (closeButton) {
            closeButton.click();
        }

        let q =
            document.querySelector("#ask-input") ??
            document.querySelector("[contenteditable='true']") ??
            document.querySelector("[role='textbox']");

        if (q) {
            q.focus();
            q.textContent = SD_clipboard_value;
            q.dispatchEvent(new InputEvent("beforeinput", {
                bubbles: true,
                cancelable: true,
                data: SD_clipboard_value,
                inputType: "insertText"
            }));
            q.dispatchEvent(new InputEvent("input", {
                bubbles: true,
                cancelable: true,
                data: SD_clipboard_value,
                inputType: "insertText"
            }));
            q.dispatchEvent(new Event("change", {
                bubbles: true,
                cancelable: true
            }));
        }

        window.__SD_perplexity_query = SD_clipboard_value;
        """,
        postScript: """
        setTimeout(() => {
            const sendButton =
                document.querySelector("button[aria-label='Submit']") ??
                document.querySelector("button[aria-label*='submit' i]") ??
                document.querySelector("button[aria-label*='제출' i]") ??
                document.querySelector("button[type='submit']");

            if (sendButton && !sendButton.disabled && sendButton.getAttribute("aria-disabled") != "true") {
                sendButton.click();
                return;
            }

            const query = window.__SD_perplexity_query;
            if (typeof query === "string" && query.length > 0) {
                location.href = `https://www.perplexity.ai/search?q=${encodeURIComponent(query)}`;
            }
        }, 120);
        """
    )

    static let all = [chatgpt, claude, gemini, grok, z_ai, perplexity]
}
