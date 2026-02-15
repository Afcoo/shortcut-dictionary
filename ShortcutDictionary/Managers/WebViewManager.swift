import WebKit

class WebViewManager {
    static var shared = WebViewManager()

    private var views: [String: WKWebView] = [:]

    private init() {}

    func getOrCreate(mode: String, id: String, create: () -> WKWebView) -> WKWebView {
        let key = cacheKey(mode: mode, id: id)

        if let view = views[key] {
            return view
        }

        let view = create()
        views[key] = view

        return view
    }

    func get(mode: String, id: String) -> WKWebView? {
        let key = cacheKey(mode: mode, id: id)
        return views[key]
    }

    private func cacheKey(mode: String, id: String) -> String {
        return "\(mode)::\(id)"
    }
}
