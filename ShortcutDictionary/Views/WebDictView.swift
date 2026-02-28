import AppKit
import SwiftUI

struct WebDictView: View {
    @State private var pendingExternalURL: URL?

    let webDict: WebDict
    let mode: String

    var body: some View {
        WebDictContainerRepresentable(
            webDict: webDict,
            mode: mode,
            pendingExternalURL: $pendingExternalURL
        )
        .alert("외부 링크 열기", isPresented: isExternalLinkAlertPresented) {
            Button("브라우저에서 열기") {
                if let pendingExternalURL {
                    NSWorkspace.shared.open(pendingExternalURL)
                }
                pendingExternalURL = nil
            }
            .keyboardShortcut(.defaultAction)
            Button("이 창에서 열기") {
                openInCurrentWindow()
            }
            Button("취소", role: .cancel) {
                pendingExternalURL = nil
            }
        } message: {
            if let url = pendingExternalURL {
                Text("\(url)")
            }
        }
    }

    private var isExternalLinkAlertPresented: Binding<Bool> {
        Binding(
            get: { pendingExternalURL != nil },
            set: { isPresented in
                if !isPresented {
                    pendingExternalURL = nil
                }
            }
        )
    }

    private func openInCurrentWindow() {
        guard let pendingExternalURL else { return }

        if let controller = WebViewManager.shared.getController(mode: mode, id: webDict.id) {
            controller.openInCurrentWindow(url: pendingExternalURL)
        }
        self.pendingExternalURL = nil
    }
}

private struct WebDictContainerRepresentable: NSViewRepresentable {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject private var dictionarySettingKeysManager = DictionarySettingKeysManager.shared
    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared

    let webDict: WebDict
    let mode: String
    @Binding var pendingExternalURL: URL?

    func makeNSView(context _: Context) -> NSView {
        return NSView()
    }

    func updateNSView(_ container: NSView, context: Context) {
        context.coordinator.parent = self

        let controller = WebViewManager.shared.getOrCreateController(
            mode: mode,
            id: webDict.id,
            webDict: webDict,
            isMobileView: dictionarySettingKeysManager.isMobileView
        )

        controller.onExternalLinkRequested = { requestedURL in
            DispatchQueue.main.async {
                pendingExternalURL = requestedURL
            }
        }

        controller.applyAppearance(
            colorScheme: colorScheme,
            isToolbarEnabled: appearanceSettingKeysManager.isToolbarEnabled,
            isLiquidGlassEnabled: appearanceSettingKeysManager.isLiquidGlassEnabled,
            backgroundColor: appearanceSettingKeysManager.backgroundColor,
            backgroundDarkColor: appearanceSettingKeysManager.backgroundDarkColor
        )
        controller.syncReadyStateIfNeeded()

        context.coordinator.attach(controller.webView, to: container)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: WebDictContainerRepresentable

        init(_ parent: WebDictContainerRepresentable) {
            self.parent = parent
            super.init()
        }

        func attach(_ view: NSView, to container: NSView) {
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
    }
}
