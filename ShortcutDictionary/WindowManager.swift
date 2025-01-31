import KeyboardShortcuts
import SwiftUI

class WindowManager {
    @AppStorage(SettingKeys.isAlwaysOnTop.rawValue)
    private var isAlwaysOnTop = SettingKeys.isAlwaysOnTop.defaultValue as! Bool

    @AppStorage(SettingKeys.isShowOnMousePos.rawValue)
    private var isShowOnMousePos = SettingKeys.isShowOnMousePos.defaultValue as! Bool

    @AppStorage(SettingKeys.isOutClickToClose.rawValue)
    private var isOutClickToClose = SettingKeys.isOutClickToClose.defaultValue as! Bool

    static var shared = WindowManager()

    let dictWindow: NSWindow
    let dictWindowDelegate = DictWindowDelegate()

    var dummyWindow: NSWindow?
    var onboardingWindow: NSWindow?
    var aboutWindow: NSWindow?

    private var clickEventMonitor: Any?

    private init() {
        dictWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 550),
            styleMask: [.closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )
        setDictWindow()

        // NSWindow 및 Notification을 사용한 설정 열기
        // macOS 14.0 이상 NSApp.sendAction 사용 불가 대응
        if #available(macOS 14.0, *) {
            dummyWindow = NSWindow()
            dummyWindow!.isReleasedWhenClosed = false
            dummyWindow!.close()

            dummyWindow!.contentView = NSHostingView(rootView: DummyView())
        }
    }

    deinit {
        removeClickEventMonitor()
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

        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var isDictClosing = false
}

// 사전 창 관련
extension WindowManager {
    func setDictWindow() {
        dictWindow.isReleasedWhenClosed = false
        dictWindow.close()

        dictWindow.contentView = NSHostingView(
            rootView: DictionaryView()
                .frame(minWidth: 360, minHeight: 400)
                .ignoresSafeArea()
        )
        dictWindow.title = "단축키 사전"
        dictWindow.setFrameAutosaveName("DictionaryFrame")

        dictWindow.backgroundColor = .clear

        chromeless(dictWindow)
        moveToScreenCenter(dictWindow)

        setDictAlwaysOnTop(isAlwaysOnTop)

        dictWindow.delegate = dictWindowDelegate
    }

    func showDict() {
        guard !isDictClosing else { return }

        NSApplication.shared.setActivationPolicy(.regular)

        setShowOnMousePos()

        setOutClickToClose(isOutClickToClose)

        goFront(dictWindow)
    }

    func closeDict() {
        removeClickEventMonitor()
        dictWindow.close()
    }

    // 마우스 위치에 사전 창 표시 구현
    func setShowOnMousePos() {
        if isShowOnMousePos {
            // 마우스 위치가 창의 가운데로 오도록 설정
            let mouseLocation = NSEvent.mouseLocation
            let screens = NSScreen.screens
            if let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }) {
                let width = dictWindow.contentLayoutRect.width
                let height = dictWindow.contentLayoutRect.height

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
                dictWindow.setFrameOrigin(NSPoint(x: _x, y: _y))
            }
        }
    }

    // 사전 창 밖 클릭시 닫기 구현
    func setOutClickToClose(_ tf: Bool) {
        if tf, clickEventMonitor == nil {
            // 클릭 이벤트 모니터링
            clickEventMonitor = NSEvent.addGlobalMonitorForEvents(
                matching: [.leftMouseDown, .rightMouseDown]
            ) { [weak self] _ in
                guard let self = self else { return }

                let clickLocation = NSEvent.mouseLocation
                let windowFrame = dictWindow.frame

                // 클릭 위치가 창 밖인지 확인, 창 밖 클릭 시 닫기
                if !NSPointInRect(clickLocation, windowFrame) {
                    closeDict()
                }
            }
        }
        else {
            removeClickEventMonitor()
        }
    }

    private func removeClickEventMonitor() {
        if let monitor = clickEventMonitor {
            NSEvent.removeMonitor(monitor)
            clickEventMonitor = nil
        }
    }

    // 사전 창 항상 위에 표시 구현
    func setDictAlwaysOnTop(_ tf: Bool) {
        if tf {
            dictWindow.level = .floating
        }
        else {
            dictWindow.level = .normal
        }
    }
}

// 온보딩 윈도우 관리
extension WindowManager {
    func showOnboarding() {
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
        goFront(window)

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
}

// About 윈도우 관리
extension WindowManager {
    func showAbout() {
        if let window = aboutWindow {
            // 이미 있다면 앞으로 가져오기
            window.makeKeyAndOrderFront(nil)
        }
        else {
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 550, height: 300),
                styleMask: [.closable, .titled],
                backing: .buffered,
                defer: false
            )
            aboutWindow?.isReleasedWhenClosed = false
            aboutWindow?.contentView = NSHostingView(
                rootView: InfoView()
                    .frame(width: 300, height: 250)
            )
            aboutWindow?.title = "단축키 사전에 관하여"
            aboutWindow?.center()
            aboutWindow?.makeKeyAndOrderFront(nil)
        }
    }
}

private extension WindowManager {
    // 타이틀 바 완전 제거
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

    // 창을 가장 앞으로 가져오기
    func goFront(_ window: NSWindow) {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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

class DictWindowDelegate: NSObject, NSWindowDelegate {
    func windowDidBecomeKey(_ notification: Notification) {
        print("Dict Window become key")

        MenubarManager.shared.setupMenu()
    }

    func windowWillClose(_ notification: Notification) {
        print("Dict Window will close")
        WindowManager.shared.isDictClosing = true

        NSApp.setActivationPolicy(.prohibited)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WindowManager.shared.isDictClosing = false
        }
    }
}
