import SwiftUI
import WebKit

struct WebDictView: NSViewRepresentable {
    @Environment(\.colorScheme) var colorScheme // 다크모드 변경 감지용

    @ObservedObject private var dictionarySettingKeysManager = DictionarySettingKeysManager.shared
    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared

    let webDict: WebDict
    let mode: String

    func makeNSView(context _: Context) -> NSView {
        return NSView()
    }

    func updateNSView(_ container: NSView, context: Context) {
        context.coordinator.parent = self // Coordinator의 parent 참조 업데이트

        let view = context.coordinator.getOrCreateView(
            webDict: webDict,
            mode: mode,
            isMobileView: dictionarySettingKeysManager.isMobileView
        )

        applyAppearance(to: view)
        context.coordinator.attach(view, to: container)

        if let reqUrl = URL(string: webDict.url),
           context.coordinator.shouldLoadRequestedURL(reqUrl, mode: mode, id: webDict.id, currentURL: view.url)
        {
            view.stopLoading()
            view.load(URLRequest(url: reqUrl))
            context.coordinator.setReady(false, for: mode, id: webDict.id)
        }

        context.coordinator.flushPendingTextIfNeeded(mode: mode, id: webDict.id)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func applyAppearance(to view: WKWebView) {
        if dictionarySettingKeysManager.isMobileView {
            view.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
        } else {
            view.customUserAgent = nil
        }

        if #available(macOS 26.0, *) {
            view.obscuredContentInsets = appearanceSettingKeysManager.isToolbarEnabled && appearanceSettingKeysManager.isLiquidGlassEnabled
                ? .init(top: 52, left: 0, bottom: 0, right: 0)
                : .init(top: 0, left: 0, bottom: 0, right: 0)
        }

        view.underPageBackgroundColor =
            colorScheme == .light
                ? NSColor(Color(hexString: appearanceSettingKeysManager.backgroundColor))
                : NSColor(Color(hexString: appearanceSettingKeysManager.backgroundDarkColor))
    }

    func tryLoad(_ url: URL, into view: WKWebView) {
        view.load(URLRequest(url: url))
    }

    /// Coordinator 클래스: WKNavigationDelegate를 처리
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private let windowSettingKeysManager = WindowSettingKeysManager.shared
        private let shortcutSettingKeysManager = ShortcutSettingKeysManager.shared

        var parent: WebDictView

        private var viewModeAndID: [ObjectIdentifier: (mode: String, id: String)] = [:]
        private var requestedURLs: [String: String] = [:]
        private var readyKeys: Set<String> = []
        private var pendingTexts: [String: String] = [:]

        private var retryWorkItem: DispatchWorkItem?
        private var isRetrying = false
        private var retryCount = 0
        private let maxRetryCount = 5
        private let pasteRetryInterval: TimeInterval = 0.25
        private let maxPasteRetryDuration: TimeInterval = 5.0

        init(_ parent: WebDictView) {
            self.parent = parent
            super.init()

            // Notification 관리
            NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateText(_:)), name: .updateText, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleReload(_:)), name: .reloadDict, object: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        /// 웹 페이지 로드 완료 시 호출
        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            guard let modeAndID = viewModeAndID[ObjectIdentifier(webView)] else {
                return
            }

            let key = cacheKey(mode: modeAndID.mode, id: modeAndID.id)
            readyKeys.insert(key)

            flushPendingTextIfNeeded(mode: modeAndID.mode, id: modeAndID.id)
        }

        /// webView 초기 로드 실패시 호출
        func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
            autoRetry(webView)
        }

        /// webView 로드 실패시 호출
        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            autoRetry(webView)
        }

        func autoRetry(_ view: WKWebView) {
            guard retryCount < maxRetryCount else {
                retryWorkItem = nil
                isRetrying = false
                retryCount = 0
                return
            }
            isRetrying = true
            retryCount += 1

            // 지수 백오프를 사용한 재시도 간격
            let delay = Double(pow(2.0, Double(retryCount - 1)))
            if let modeAndID = viewModeAndID[ObjectIdentifier(view)],
               let currentWebDict = resolveWebDict(mode: modeAndID.mode, id: modeAndID.id),
               let url = URL(string: currentWebDict.url)
            {
                retryWorkItem = DispatchWorkItem {
                    self.parent.tryLoad(url, into: view)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: retryWorkItem!)
            }
        }

        /// Javascript 메시지 처리
        func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
            // KeyDown 이벤트 처리
            if message.name == "KeyDownEvent" {
                let key = message.body as? String

                if let key {
                    switch key {
                    case "Escape":
                        if windowSettingKeysManager.isEscToClose {
                            WindowManager.shared.closeDict()
                        }
                    default:
                        return
                    }
                }
            }
        }

        /// updateText Notification 수신 시 호출될 함수
        @objc func handleUpdateText(_ notification: Notification) {
            guard let text = textFrom(notification) else { return }

            let mode = parent.mode
            let id = parent.webDict.id

            guard let webView = WebViewManager.shared.get(mode: mode, id: id) else {
                pendingTexts[cacheKey(mode: mode, id: id)] = text
                return
            }

            let key = cacheKey(mode: mode, id: id)

            if readyKeys.contains(key) {
                runPasteScript(text: text, in: webView)
            } else {
                pendingTexts[key] = text
            }
        }

        /// 초기 페이지로 이동
        @objc func handleReload(_ notification: Notification) {
            if let mode = notification.userInfo?[NotificationUserInfoKey.mode] as? String,
               mode != parent.mode
            {
                return
            }

            guard let url = URL(string: parent.webDict.url) else {
                return
            }

            if let webView = WebViewManager.shared.get(mode: parent.mode, id: parent.webDict.id) {
                webView.load(URLRequest(url: url))
                setReady(false, for: parent.mode, id: parent.webDict.id)
            } else if isRetrying {
                retryWorkItem?.cancel()
                retryCount = 0
                isRetrying = false
            }
        }

        func getOrCreateView(webDict: WebDict, mode: String, isMobileView: Bool) -> WKWebView {
            let view = WebViewManager.shared.getOrCreate(mode: mode, id: webDict.id) {
                self.createView(webDict: webDict, isMobileView: isMobileView)
            }

            viewModeAndID[ObjectIdentifier(view)] = (mode: mode, id: webDict.id)

            return view
        }

        func attach(_ view: WKWebView, to container: NSView) {
            guard view.superview !== container else {
                return
            }

            view.removeFromSuperview()

            for existing in container.subviews {
                existing.removeFromSuperview()
            }

            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)

            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                view.topAnchor.constraint(equalTo: container.topAnchor),
                view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
        }

        func setReady(_ ready: Bool, for mode: String, id: String) {
            let key = cacheKey(mode: mode, id: id)

            if ready {
                readyKeys.insert(key)
            } else {
                readyKeys.remove(key)
            }
        }

        func flushPendingTextIfNeeded(mode: String, id: String) {
            let key = cacheKey(mode: mode, id: id)

            guard let text = pendingTexts[key],
                  let webView = WebViewManager.shared.get(mode: mode, id: id),
                  readyKeys.contains(key)
            else {
                return
            }

            runPasteScript(text: text, in: webView)
            pendingTexts[key] = nil
        }

        func shouldLoadRequestedURL(_ requestedURL: URL, mode: String, id: String, currentURL: URL?) -> Bool {
            let key = cacheKey(mode: mode, id: id)
            let requested = requestedURL.absoluteString

            if let lastRequested = requestedURLs[key] {
                if lastRequested == requested {
                    return false
                }

                requestedURLs[key] = requested
                return true
            }

            requestedURLs[key] = requested
            return currentURL == nil
        }

        private func textFrom(_ notification: Notification) -> String? {
            if let mode = notification.userInfo?[NotificationUserInfoKey.mode] as? String,
               mode != parent.mode
            {
                return nil
            }

            if let text = notification.userInfo?[NotificationUserInfoKey.text] as? String {
                return text
            }

            return notification.object as? String
        }

        private func runPasteScript(text: String, in webView: WKWebView) {
            let processedText: String

            if parent.mode == "chat" {
                processedText = WebDictManager.shared.getSelectedChatPrompt().wrap(text)
            } else {
                processedText = text
            }

            let script = parent.webDict.getPasteScript(value: processedText, fastSearch: shortcutSettingKeysManager.isFastSearchEnabled) ?? ""

            runPasteScriptWhenDOMReady(script: script, in: webView)
        }

        private func runPasteScriptWhenDOMReady(
            script: String,
            in webView: WKWebView,
            attempt: Int = 0,
            startedAt: Date = Date()
        ) {
            let domReadyScript = "document.readyState"

            webView.evaluateJavaScript(domReadyScript) { result, error in
                guard error == nil else {
                    self.retryPasteScript(script: script, in: webView, attempt: attempt, startedAt: startedAt)
                    return
                }

                let readyState = result as? String ?? "loading"
                guard readyState != "loading" else {
                    self.retryPasteScript(script: script, in: webView, attempt: attempt, startedAt: startedAt)
                    return
                }

                webView.evaluateJavaScript(script) { _, pasteError in
                    if let pasteError {
                        if Date().timeIntervalSince(startedAt) >= self.maxPasteRetryDuration {
                            print("JavaScript execution error: \(pasteError)")
                        } else {
                            self.retryPasteScript(script: script, in: webView, attempt: attempt, startedAt: startedAt)
                        }
                    } else {
                        print("JavaScript executed successfully")
                    }
                }
            }
        }

        private func retryPasteScript(script: String, in webView: WKWebView, attempt: Int, startedAt: Date) {
            if Date().timeIntervalSince(startedAt) >= maxPasteRetryDuration {
                return
            }

            let nextAttempt = attempt + 1

            DispatchQueue.main.asyncAfter(deadline: .now() + pasteRetryInterval) {
                self.runPasteScriptWhenDOMReady(
                    script: script,
                    in: webView,
                    attempt: nextAttempt,
                    startedAt: startedAt
                )
            }
        }

        private func cacheKey(mode: String, id: String) -> String {
            return "\(mode)::\(id)"
        }

        private func resolveWebDict(mode: String, id: String) -> WebDict? {
            if mode == "chat" {
                return WebDictManager.shared.getChat(id)
            }

            return WebDictManager.shared.getDict(id)
        }

        private func createView(webDict: WebDict, isMobileView: Bool) -> WKWebView {
            let userContentController = WKUserContentController()
            userContentController.add(self, name: "KeyDownEvent")
            userContentController.addUserScript(
                WKUserScript(
                    source: "document.onkeydown = (e) => window.webkit.messageHandlers.KeyDownEvent.postMessage(e.key);",
                    injectionTime: .atDocumentEnd,
                    forMainFrameOnly: true
                )
            )

            let config = WKWebViewConfiguration()
            config.userContentController = userContentController

            let view = WKWebView(frame: .zero, configuration: config)
            view.navigationDelegate = self

            if isMobileView {
                view.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
            }

            if let url = URL(string: webDict.url) {
                view.load(URLRequest(url: url))
            }

            return view
        }
    }
}
