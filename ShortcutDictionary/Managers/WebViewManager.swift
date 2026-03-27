import WebKit

class WebViewManager {
    private let chatSettingKeysManager = ChatSettingKeysManager.shared
    private let dictionarySettingKeysManager = DictionarySettingKeysManager.shared

    static var shared = WebViewManager()

    private var controllers: [String: WebViewController] = [:]
    private var lastExternalOpen: (key: String, date: Date)?

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateText(_:)), name: .updateText, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload(_:)), name: .reloadDict, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGoBack(_:)), name: .goBackDict, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGoForward(_:)), name: .goForwardDict, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func getOrCreateController(mode: String, id: String, webDict: WebDict, isMobileView: Bool) -> WebViewController {
        let key = cacheKey(mode: mode, id: id)

        if let controller = controllers[key] {
            controller.update(webDict: webDict, isMobileView: isMobileView)
            return controller
        }

        let controller = WebViewController(mode: mode, id: id, webDict: webDict, isMobileView: isMobileView)
        controllers[key] = controller
        return controller
    }

    func getController(mode: String, id: String) -> WebViewController? {
        let key = cacheKey(mode: mode, id: id)
        return controllers[key]
    }

    func preloadSelectedWebDictView() {
        guard let selectedDict = WebDictManager.shared.getDict(dictionarySettingKeysManager.selectedDict) else {
            return
        }

        _ = getOrCreateController(
            mode: "dictionary",
            id: selectedDict.id,
            webDict: selectedDict,
            isMobileView: dictionarySettingKeysManager.isMobileView
        )
    }

    func preloadSelectedChatWebDictView() {
        guard chatSettingKeysManager.isChatEnabled,
              let selectedChat = WebDictManager.shared.getChat(chatSettingKeysManager.selectedChat)
        else {
            return
        }

        _ = getOrCreateController(
            mode: "chat",
            id: selectedChat.id,
            webDict: selectedChat,
            isMobileView: dictionarySettingKeysManager.isMobileView
        )
    }

    func openInExternalBrowser(webDict: WebDict, mode: String) {
        guard let url = URL(string: webDict.url) else { return }

        let key = "\(mode)::\(webDict.id)::\(url.absoluteString)"
        if let lastExternalOpen,
           lastExternalOpen.key == key,
           Date().timeIntervalSince(lastExternalOpen.date) < 0.7
        {
            return
        }

        lastExternalOpen = (key: key, date: Date())
        NSWorkspace.shared.open(url)
    }

    private func cacheKey(mode: String, id: String) -> String {
        return "\(mode)::\(id)"
    }

    private func selectedWebDict(for mode: String) -> WebDict? {
        return WebDictManager.shared.getSelectedWebDict(
            mode: mode,
            selectedDictID: dictionarySettingKeysManager.selectedDict,
            selectedChatID: chatSettingKeysManager.selectedChat
        )
    }

    private func resolvedMode(from notification: Notification) -> String {
        if let mode = notification.userInfo?[NotificationUserInfoKey.mode] as? String {
            return mode
        }

        return dictionarySettingKeysManager.selectedPageMode == "chat" && chatSettingKeysManager.isChatEnabled
            ? "chat"
            : "dictionary"
    }

    private func textFrom(_ notification: Notification) -> String? {
        if let text = notification.userInfo?[NotificationUserInfoKey.text] as? String {
            return text
        }

        return notification.object as? String
    }
}

private extension WebViewManager {
    @objc func handleUpdateText(_ notification: Notification) {
        guard let text = textFrom(notification) else { return }

        WebDictManager.shared.normalizeState()
        let mode = resolvedMode(from: notification)
        guard let webDict = selectedWebDict(for: mode) else { return }

        let controller = getOrCreateController(
            mode: mode,
            id: webDict.id,
            webDict: webDict,
            isMobileView: dictionarySettingKeysManager.isMobileView
        )

        controller.handleIncomingText(text)
    }

    @objc func handleReload(_ notification: Notification) {
        WebDictManager.shared.normalizeState()
        let mode = resolvedMode(from: notification)
        guard let webDict = selectedWebDict(for: mode) else { return }

        let controller = getOrCreateController(
            mode: mode,
            id: webDict.id,
            webDict: webDict,
            isMobileView: dictionarySettingKeysManager.isMobileView
        )
        controller.reload()
    }

    @objc func handleGoBack(_ notification: Notification) {
        let mode = resolvedMode(from: notification)
        guard let webDict = selectedWebDict(for: mode),
              let controller = getController(mode: mode, id: webDict.id)
        else { return }

        controller.goBack()
    }

    @objc func handleGoForward(_ notification: Notification) {
        let mode = resolvedMode(from: notification)
        guard let webDict = selectedWebDict(for: mode),
              let controller = getController(mode: mode, id: webDict.id)
        else { return }

        controller.goForward()
    }
}
