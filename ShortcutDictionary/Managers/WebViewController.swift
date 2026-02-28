import AppKit
import SwiftUI
import WebKit

final class WebViewController: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    private let windowSettingKeysManager = WindowSettingKeysManager.shared
    private let shortcutSettingKeysManager = ShortcutSettingKeysManager.shared

    let mode: String
    let id: String
    let webView: WKWebView
    var onExternalLinkRequested: ((URL) -> Void)?

    private var webDict: WebDict
    private var requestedURL: String?
    private var isReady = false
    private var pendingText: String?

    private var retryWorkItem: DispatchWorkItem?
    private var isRetrying = false
    private var retryCount = 0
    private let maxRetryCount = 5
    private let pasteRetryInterval: TimeInterval = 0.25
    private let maxPasteRetryDuration: TimeInterval = 5.0

    init(mode: String, id: String, webDict: WebDict, isMobileView: Bool) {
        self.mode = mode
        self.id = id
        self.webDict = webDict

        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        webView = WKWebView(frame: .zero, configuration: config)

        super.init()

        bindWebViewHandlers()
        configure(isMobileView: isMobileView)
        ensureRequestedURLLoaded(force: true)
    }

    deinit {
        retryWorkItem?.cancel()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "KeyDownEvent")
    }

    func update(webDict: WebDict, isMobileView: Bool) {
        self.webDict = webDict
        configure(isMobileView: isMobileView)
        ensureRequestedURLLoaded(force: false)
    }

    func configure(isMobileView: Bool) {
        if isMobileView {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
        } else {
            webView.customUserAgent = nil
        }
    }

    func applyAppearance(
        colorScheme: ColorScheme,
        isToolbarEnabled: Bool,
        isLiquidGlassEnabled: Bool,
        backgroundColor: String,
        backgroundDarkColor: String
    ) {
        if #available(macOS 26.0, *) {
            webView.obscuredContentInsets = isToolbarEnabled && isLiquidGlassEnabled
                ? .init(top: 52, left: 0, bottom: 0, right: 0)
                : .init(top: 0, left: 0, bottom: 0, right: 0)
        }

        webView.underPageBackgroundColor =
            colorScheme == .light
                ? NSColor(Color(hexString: backgroundColor))
                : NSColor(Color(hexString: backgroundDarkColor))
    }

    func reload() {
        ensureRequestedURLLoaded(force: true)
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func openInCurrentWindow(url: URL) {
        webView.load(URLRequest(url: url))
        setReady(false)
    }

    func handleIncomingText(_ text: String) {
        if isReady {
            runPasteScript(text: text)
        } else {
            pendingText = text
            syncReadyStateIfNeeded()
        }
    }

    func syncReadyStateIfNeeded() {
        guard !isReady else { return }

        webView.evaluateJavaScript("document.readyState") { [weak self] result, _ in
            guard let self = self else { return }

            let readyState = result as? String ?? "loading"
            guard readyState != "loading" else { return }

            self.setReady(true)
            self.flushPendingTextIfNeeded()
        }
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        guard webView === self.webView else { return }

        setReady(true)
        flushPendingTextIfNeeded()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError _: Error) {
        guard webView === self.webView else { return }
        autoRetry()
    }

    func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        guard webView === self.webView else { return }
        autoRetry()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard webView === self.webView else {
            decisionHandler(.allow)
            return
        }

        guard navigationAction.navigationType == .linkActivated,
              let url = navigationAction.request.url
        else {
            decisionHandler(.allow)
            return
        }

        if shouldPromptExternalOpen(for: url) {
            onExternalLinkRequested?(url)
            decisionHandler(.cancel)
            return
        }

        if navigationAction.targetFrame == nil {
            webView.load(URLRequest(url: url))
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith _: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures _: WKWindowFeatures
    ) -> WKWebView? {
        guard webView === self.webView,
              let url = navigationAction.request.url
        else {
            return nil
        }

        if shouldPromptExternalOpen(for: url) {
            onExternalLinkRequested?(url)
            return nil
        }

        webView.load(URLRequest(url: url))
        return nil
    }

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "KeyDownEvent" else { return }

        let key = message.body as? String
        if key == "Escape", windowSettingKeysManager.isEscToClose {
            WindowManager.shared.closeDict()
        }
    }

    private func bindWebViewHandlers() {
        let userContentController = webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: "KeyDownEvent")
        userContentController.add(self, name: "KeyDownEvent")
        userContentController.addUserScript(
            WKUserScript(
                source: "document.onkeydown = (e) => window.webkit.messageHandlers.KeyDownEvent.postMessage(e.key);",
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )

        webView.navigationDelegate = self
        webView.uiDelegate = self
    }

    private func setReady(_ ready: Bool) {
        isReady = ready
    }

    private func ensureRequestedURLLoaded(force: Bool) {
        guard let reqURL = URL(string: webDict.url) else {
            return
        }

        let requested = reqURL.absoluteString
        let shouldLoad: Bool

        if force {
            shouldLoad = true
        } else if requestedURL != requested {
            shouldLoad = true
        } else {
            shouldLoad = (webView.url == nil)
        }

        guard shouldLoad else {
            syncReadyStateIfNeeded()
            return
        }

        requestedURL = requested
        webView.stopLoading()
        webView.load(URLRequest(url: reqURL))
        setReady(false)
    }

    private func shouldPromptExternalOpen(for destinationURL: URL) -> Bool {
        guard let scheme = destinationURL.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let destinationHost = destinationURL.host?.lowercased(),
              let baseHost = webDict.host
        else {
            return false
        }

        return destinationHost != baseHost
    }

    private func flushPendingTextIfNeeded() {
        guard let text = pendingText, isReady else {
            return
        }

        runPasteScript(text: text)
        pendingText = nil
    }

    private func runPasteScript(text: String) {
        let processedText: String

        if mode == "chat" {
            processedText = WebDictManager.shared.getSelectedChatPrompt().wrap(text)
        } else {
            processedText = text
        }

        let script = webDict.getPasteScript(value: processedText, fastSearch: shortcutSettingKeysManager.isFastSearchEnabled) ?? ""

        runPasteScriptWhenDOMReady(script: script)
    }

    private func runPasteScriptWhenDOMReady(
        script: String,
        attempt: Int = 0,
        startedAt: Date = Date()
    ) {
        webView.evaluateJavaScript("document.readyState") { [weak self] result, error in
            guard let self = self else { return }

            guard error == nil else {
                self.retryPasteScript(script: script, attempt: attempt, startedAt: startedAt)
                return
            }

            let readyState = result as? String ?? "loading"
            guard readyState != "loading" else {
                self.retryPasteScript(script: script, attempt: attempt, startedAt: startedAt)
                return
            }

            self.webView.evaluateJavaScript(script) { _, pasteError in
                if let pasteError {
                    if Date().timeIntervalSince(startedAt) >= self.maxPasteRetryDuration {
                        print("JavaScript execution error: \(pasteError)")
                    } else {
                        self.retryPasteScript(script: script, attempt: attempt, startedAt: startedAt)
                    }
                } else {
                    print("JavaScript executed successfully")
                }
            }
        }
    }

    private func retryPasteScript(script: String, attempt: Int, startedAt: Date) {
        if Date().timeIntervalSince(startedAt) >= maxPasteRetryDuration {
            return
        }

        let nextAttempt = attempt + 1

        DispatchQueue.main.asyncAfter(deadline: .now() + pasteRetryInterval) {
            self.runPasteScriptWhenDOMReady(
                script: script,
                attempt: nextAttempt,
                startedAt: startedAt
            )
        }
    }

    private func autoRetry() {
        guard retryCount < maxRetryCount else {
            retryWorkItem = nil
            isRetrying = false
            retryCount = 0
            return
        }

        isRetrying = true
        retryCount += 1

        let delay = Double(pow(2.0, Double(retryCount - 1)))

        guard let url = URL(string: webDict.url) else {
            return
        }

        retryWorkItem = DispatchWorkItem {
            self.webView.load(URLRequest(url: url))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: retryWorkItem!)
    }
}
