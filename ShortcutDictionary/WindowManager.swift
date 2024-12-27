import KeyboardShortcuts
import SwiftUI

class WindowManager {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("enable_always_on_top") var isAlwaysOnTop: Bool = false
    @AppStorage("enable_show_on_mouse_position") var isShowOnMousePos: Bool = true

    static var shared = WindowManager()

    let window: NSWindow
    var dummyWindow: NSWindow?
    var onboardingWindow: NSWindow?

    private init() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 550),
            styleMask: [.closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )

        window.isReleasedWhenClosed = false
        window.close()

        window.contentView = NSHostingView(
            rootView: DictionaryView()
                .frame(minWidth: 360, minHeight: 400)
                .ignoresSafeArea()
        )
        window.title = "단축키 사전"
        window.setFrameAutosaveName("DictionaryFrame")

        chromeless(window)
        setAlwaysOnTop(isAlwaysOnTop)
        moveToScreenCenter(window)

        if #available(macOS 14.0, *) {
            dummyWindow = NSWindow()
            dummyWindow!.isReleasedWhenClosed = false
            dummyWindow!.close()

            dummyWindow!.contentView = NSHostingView(rootView: DummyView())
        }
    }

    func show() {
        if isShowOnMousePos {
            // 마우스 위치가 창의 가운데로 오도록 설정
            let mouseLocation = NSEvent.mouseLocation
            let screens = NSScreen.screens
            if let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }) {
                let width = window.contentLayoutRect.width
                let height = window.contentLayoutRect.height

                var _x = mouseLocation.x - width / 2
                var _y = mouseLocation.y - height / 2

                // 창이 화면 넘어가지 않게 보정
                if _x < screenWithMouse.frame.minX { // 좌측
                    _x = screenWithMouse.frame.minX
                }
                if _x > screenWithMouse.frame.maxX - width { // 우측
                    _x = screenWithMouse.frame.maxX - width
                }
                if _y < screenWithMouse.frame.minY { // 하단
                    _y = screenWithMouse.frame.minY
                }

                // set window position
                window.setFrameOrigin(NSPoint(x: _x, y: _y))
            }
        }

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func close() {
        window.close()
    }

    func setAlwaysOnTop(_ tf: Bool) {
        if tf {
            window.level = .floating
        }
        else {
            window.level = .normal
        }
    }

    func showSettings() {
        if #available(macOS 14.0, *) {
            NotificationCenter.default.post(name: .showSettings, object: nil)
        }
        else {
            if #available(macOS 13.0, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
        }
    }

    func chromeless(_ window: NSWindow) {
        // hide buttons
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // hide title and bar
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
    }

    func showOnboarding() {
        if hasCompletedOnboarding {
            return
        }

        let window = NSWindow()
        window.styleMask = [.titled]
        window.isReleasedWhenClosed = true

        let hostingView = NSHostingView(
            rootView: OnboardingView()
                .ignoresSafeArea()
        )
        window.contentView = hostingView
        window.setContentSize(hostingView.intrinsicContentSize)

        window.title = "환영합니다!"
        chromeless(window)
        window.backgroundColor = .clear

        moveToScreenCenter(window)
        window.makeKeyAndOrderFront(nil)

        onboardingWindow = window
    }

    func resizeOnboarding(width: CGFloat, height: CGFloat) {
        guard let onboardingWindow else {
            return
        }
        let prevWidth = onboardingWindow.frame.width
        let prevHeight = onboardingWindow.frame.height

        let _x = onboardingWindow.frame.origin.x + (prevWidth - width) / 2 // 가운데 유지
        let _y = onboardingWindow.frame.origin.y + prevHeight - height // 아래로 높이 변화가 일어나게 수정

        onboardingWindow.setFrame(NSRect(x: _x, y: _y, width: width, height: height), display: true, animate: true)
    }

    func closeOnboarding() {
        guard let onboardingWindow else {
            return
        }

        onboardingWindow.close()
    }

    func moveToScreenCenter(_ window: NSWindow) {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens

        if let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }) {
            let width = window.contentLayoutRect.width
            let height = window.contentLayoutRect.height

            let screenWidth = screenWithMouse.frame.maxX - screenWithMouse.frame.minX
            let screenHeight = screenWithMouse.frame.maxY - screenWithMouse.frame.minY

            let _x = screenWidth / 2 - width / 2
            let _y = screenHeight / 2 - height / 2

            window.setFrameOrigin(NSPoint(x: _x, y: _y))
        }
    }
}

// dummy view for opening settings
@available(macOS 14.0, *)
struct DummyView: View {
    @Environment(\.openSettings) private var openSettings
    var body: some View {
        EmptyView()
            .onReceive(
                NotificationCenter.default.publisher(for: .showSettings),
                perform: { _ in
                    openSettings()
                }
            )
    }
}
