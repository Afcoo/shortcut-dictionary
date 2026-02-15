import KeyboardShortcuts
import SwiftUI

class WindowManager {
    private let windowSettingKeysManager = WindowSettingKeysManager.shared
    private let appearanceSettingKeysManager = AppearanceSettingKeysManager.shared

    static var shared = WindowManager()

    let dictWindow: NSWindow
    let dictWindowDelegate = DictWindowDelegate()
    let settingsToolbarObserver = SettingsToolbarObserver()

    var onboardingWindow: NSWindow?
    var aboutWindow: NSWindow?
    var settingsWindow: NSWindow?

    private var clickEventMonitor: Any?
    var isDictClosing = false

    private init() {
        dictWindow = DictWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 550),
            styleMask: [.closable, .titled, .resizable],
            backing: .buffered,
            defer: false
        )
        setDictWindow()
    }

    deinit {
        removeClickEventMonitor()
    }
}

// MARK: - 사전 윈도우 관리

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
        dictWindow.isOpaque = false

        dictWindow.isMovableByWindowBackground = true

        if appearanceSettingKeysManager.isLiquidGlassEnabled {
            dictWindow.toolbarStyle = .unified
            dictWindow.toolbar = NSToolbar()
        }

        chromeless(dictWindow)
        moveToScreenCenter(dictWindow)

        setDictAlwaysOnTop(windowSettingKeysManager.isAlwaysOnTop)

        dictWindow.delegate = dictWindowDelegate
    }

    func showDict() {
        guard !isDictClosing else { return }

        NSApplication.shared.setActivationPolicy(.regular)

        if windowSettingKeysManager.isShowOnScreenCenter {
            moveToScreenCenter(dictWindow)
        }

        setShowOnMousePos()

        setOutClickToClose(windowSettingKeysManager.isOutClickToClose)

        goFront(dictWindow)
    }

    func closeDict() {
        removeClickEventMonitor()
        dictWindow.close()
    }

    /// 마우스 위치에 사전 창 표시 구현
    func setShowOnMousePos() {
        if windowSettingKeysManager.isShowOnMousePos {
            let mouseLocation = NSEvent.mouseLocation
            let screens = NSScreen.screens
            if let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }) {
                // 설정에 맞는 사전 창 위치 계산
                let origin = Self.getDictWindowOrigin(
                    mouseLocation: mouseLocation,
                    dictFrame: dictWindow.frame,
                    screenFrame: screenWithMouse.frame,
                    visibleFrame: screenWithMouse.visibleFrame,
                    placement: DictWindowCursorPlacement(rawValue: windowSettingKeysManager.dictWindowCursorPlacement) ?? .center,
                    gap: CGFloat(windowSettingKeysManager.dictWindowCursorGap),
                    keepInScreen: windowSettingKeysManager.isDictWindowKeepInScreen
                )

                // 사전 창 위치 설정
                dictWindow.setFrameOrigin(origin)
            }
        }
    }

    static func getDictWindowOrigin(
        mouseLocation: NSPoint,
        dictFrame: CGRect,
        screenFrame _: CGRect,
        visibleFrame: CGRect,
        placement: DictWindowCursorPlacement,
        gap: CGFloat,
        keepInScreen: Bool
    ) -> NSPoint {
        let width = dictFrame.width
        let height = dictFrame.height

        var x: CGFloat
        var y: CGFloat

        let mlx = mouseLocation.x
        let mly = mouseLocation.y

        switch placement {
        case .topLeading:
            x = mlx + gap
            y = mly - gap - height
        case .top:
            x = mlx - width / 2
            y = mly - gap - height
        case .topTrailing:
            x = mlx - gap - width
            y = mly - gap - height
        case .leading:
            x = mlx + gap
            y = mly - height / 2
        case .center:
            x = mlx - width / 2
            y = mly - height / 2
        case .trailing:
            x = mlx - gap - width
            y = mly - height / 2
        case .bottomLeading:
            x = mlx + gap
            y = mly + gap
        case .bottom:
            x = mlx - width / 2
            y = mly + gap
        case .bottomTrailing:
            x = mlx - gap - width
            y = mly + gap
        }

        // 창이 화면 넘어가지 않게 보정
        if keepInScreen {
            let minX = visibleFrame.minX
            let maxX = max(minX, visibleFrame.maxX - width)
            x = max(minX, min(x, maxX))

            let minY = visibleFrame.minY
            let maxY = max(minY, visibleFrame.maxY - height)
            y = max(minY, min(y, maxY))
        }

        return NSPoint(x: x, y: y)
    }

    /// 사전 창 밖 클릭시 닫기 구현
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
        } else {
            removeClickEventMonitor()
        }
    }

    private func removeClickEventMonitor() {
        if let monitor = clickEventMonitor {
            NSEvent.removeMonitor(monitor)
            clickEventMonitor = nil
        }
    }

    /// 사전 창 항상 위에 표시 구현
    func setDictAlwaysOnTop(_ tf: Bool) {
        if tf {
            dictWindow.level = .floating
        } else {
            dictWindow.level = .normal
        }
    }

    /// 사전 창의 Liquid Glass 스타일 변경
    func setDictWindowLiquidGlass(_ tf: Bool) {
        if tf {
            dictWindow.toolbar = NSToolbar()
        } else {
            dictWindow.toolbar = nil
        }
    }
}

// MARK: - 설정 윈도우 관리

extension WindowManager {
    func showSettings() {
        if let window = settingsWindow {
            moveToScreenCenter(window)
            window.makeKeyAndOrderFront(nil)
        } else {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 480),
                styleMask: [.closable, .titled, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.contentView = NSHostingView(rootView: SettingsView())
            window.isReleasedWhenClosed = false

            window.title = "설정"
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden

            window.toolbar = NSToolbar()
            window.toolbarStyle = .unified

            moveToScreenCenter(window)
            window.makeKeyAndOrderFront(nil)

            settingsWindow = window
        }

        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

// MARK: - 온보딩 윈도우 관리

extension WindowManager {
    func showOnboarding() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 248),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = true

        window.contentView = NSHostingView(
            rootView: OnboardingView()
        )
        window.title = "환영합니다!"

        if appearanceSettingKeysManager.isLiquidGlassEnabled {
            window.toolbar = NSToolbar()
            window.toolbarStyle = .unified
        }

        window.backgroundColor = .clear
        window.isOpaque = false

        window.animationBehavior = .alertPanel

        window.isMovableByWindowBackground = true

        chromeless(window)
        moveToScreenCenter(window)
        goFront(window)

        onboardingWindow = window
    }

    func closeOnboarding() {
        guard let onboardingWindow else { return }
        onboardingWindow.close()
    }
}

// MARK: - About 윈도우 관리

extension WindowManager {
    func showAbout() {
        if let window = aboutWindow {
            // 이미 있다면 앞으로 가져오기
            window.makeKeyAndOrderFront(nil)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 300),
            styleMask: [.closable, .titled],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(
            rootView: InfoView()
                .frame(width: 300, height: 250)
        )
        window.title = "단축키 사전에 관하여"
        window.center()
        window.makeKeyAndOrderFront(nil)

        aboutWindow = window
    }
}

// MARK: - 윈도우 유틸리티

private extension WindowManager {
    /// 타이틀 바 완전 제거
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

    /// 창을 가장 앞으로 가져오기
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

            let screenFrame = screenWithMouse.frame

            let x = screenFrame.minX + screenFrame.width / 2 - width / 2
            let y = screenFrame.minY + screenFrame.height / 2 - height / 2

            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
}

// MARK: - DictWindowDelegate

class DictWindowDelegate: NSObject, NSWindowDelegate {
    func windowDidBecomeKey(_: Notification) {
        print("Dict Window become key")

        MenubarManager.shared.setupMenu()
    }

    func windowWillClose(_: Notification) {
        print("Dict Window will close")
        WindowManager.shared.isDictClosing = true

        NSApp.setActivationPolicy(.prohibited)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            WindowManager.shared.isDictClosing = false
        }
    }
}

// MARK: - SettingsToolbarObserver

/// 설정 창 NavigationSplitView의 사이드바 토글 버튼 숨김 처리
class SettingsToolbarObserver: NSObject {
    private let sidebarToggleId = NSToolbarItem.Identifier("com.apple.SwiftUI.navigationSplitView.toggleSidebar")

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(toolbarWillAddItem(_:)),
            name: NSToolbar.willAddItemNotification,
            object: nil
        )
    }

    @objc func toolbarWillAddItem(_ notification: Notification) {
        guard let item = notification.userInfo?["item"] as? NSToolbarItem,
              item.itemIdentifier == sidebarToggleId
        else { return }

        item.view?.isHidden = true
        item.menuFormRepresentation = nil
    }
}

// MARK: - DictWindow

/// 메뉴바 위로도 이동 가능한 사전 창
class DictWindow: NSWindow {
    override func constrainFrameRect(_ frameRect: NSRect, to _: NSScreen?) -> NSRect {
        return frameRect
    }
}
