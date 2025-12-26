import AppKit
import SwiftUI

extension View {
    func getTitleBarHeight(perform action: @escaping (CGFloat) -> Void) -> some View {
        self.background(WindowAccessor { window in
            if let window = window {
                // 전체 윈도우 프레임 높이 - 콘텐츠 영역 높이 = 타이틀 바 높이
                let frameHeight = window.frame.height
                let contentHeight = window.contentLayoutRect.height
                let titleBarHeight = frameHeight - contentHeight

                action(titleBarHeight)
            }
        })
    }
}

// NSWindow에 접근하기 위한 헬퍼 구조체
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            // 뷰가 윈도우에 부착된 후 윈도우 객체를 콜백으로 전달
            self.callback(nsView.window)
        }
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
