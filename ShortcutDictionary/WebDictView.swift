import SwiftUI
import WebKit

// #Preview {
//    WebDictView(.daum)
// }

struct WebDictView: NSViewRepresentable {
    private let selectedDict: Dicts

    init(_ dict: Dicts) {
        self.selectedDict = dict
    }

    func makeNSView(context: Context) -> WKWebView {
        makeView(context: context)
    }

    func updateNSView(_ view: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self, selectedDict)
    }

    // Coordinator 클래스: WKNavigationDelegate를 처리
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        @AppStorage("enable_close_with_esc") var isEscToClose: Bool = true

        private let parent: WebDictView
        private let selectedDict: Dicts

        private var webView: WKWebView?
        private var errorWebView: WKWebView?

        private var retryWorkItem: DispatchWorkItem?
        private var isRetrying = false
        private var retryCount = 0
        private let maxRetryCount = 5

        init(_ parent: WebDictView, _ selectedDict: Dicts) {
            self.selectedDict = selectedDict
            self.parent = parent
            super.init()

            // Notification 관리
            NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateText(_:)), name: .updateText, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleReload(_:)), name: .reloadDict, object: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // 웹 페이지 로드 완료 시 호출
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.webView = webView
            errorWebView = nil
        }

        // webView 초기 로드 실패시 호출
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            errorWebView = webView
            autoRetry(webView)
        }

        // webView 로드 실패시 호출
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            errorWebView = webView
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

            retryWorkItem = DispatchWorkItem {
                self.parent.tryLoad(Dicts.getURL(self.selectedDict), into: view)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: retryWorkItem!)
        }

        // Javascript 메시지 처리
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            // KeyDown 이벤트 처리
            if message.name == "KeyDownEvent" {
                let key = message.body as? String

                if let key {
                    switch key {
                    case "Escape":
                        if isEscToClose {
                            WindowManager.shared.close()
                        }
                    default:
                        return
                    }
                }
            }
        }

        // updateText Notification 수신 시 호출될 함수
        @objc func handleUpdateText(_ notification: Notification) {
            guard let text = notification.object as? String else { return }
            print(text)

            if let webView {
                let script = Dicts.getPasteScript(selectedDict, value: text)

                webView.evaluateJavaScript(script) { _, error in
                    if let error = error {
                        print("JavaScript execution error: \(error)")
                    } else {
                        print("JavaScript executed successfully")
                    }
                }
            }
        }

        // 초기 페이지로 이동
        @objc func handleReload(_ notification: Notification) {
            if let webView {
                webView.load(URLRequest(url: Dicts.getURL(selectedDict)))
            } else if isRetrying {
                retryWorkItem?.cancel()
                retryCount = 0
                isRetrying = false

                if let errorWebView {
                    parent.tryLoad(Dicts.getURL(selectedDict), into: errorWebView)
                }
            }
        }
    }
}

private extension WebDictView {
    func makeView(context: Context) -> WKWebView {
        // WKUserContentController 설정
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "KeyDownEvent") // Event Listener
        userContentController.addUserScript( // script injection
            WKUserScript(
                source: "document.onkeydown = (e) => window.webkit.messageHandlers.KeyDownEvent.postMessage(e.key);",
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
        )

        // WKWebViewConfiguration 설정
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator // WKNavigationDelegate 설정

        view.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"

        tryLoad(Dicts.getURL(selectedDict), into: view)
        return view
    }

    func tryLoad(_ url: URL?, into view: WKWebView) {
        guard let url = url else { return }
        view.load(URLRequest(url: url))
    }
}
