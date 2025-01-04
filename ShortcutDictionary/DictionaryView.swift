import SwiftUI

struct DictionaryView: View {
    @AppStorage("selected_dictonary") var selectedDict: Dicts = .daum
    @AppStorage("enable_toolbar") var isToolbarEnabled: Bool = true

    private var webDictView: WebDictView {
        WebDictView(selectedDict)
    }

    var _padding = 8.0

    var body: some View {
        VStack {
            // 툴바
            if isToolbarEnabled {
                HStack {
                    ToolbarButton(action: closeDict, systemName: "xmark.circle")
                    Spacer()
                    ToolbarButton(action: reloadDict, systemName: "arrow.clockwise.circle")
                    ToolbarButton(action: openSettingPage, systemName: "gear.circle")
                }
                Spacer()
                    .frame(height: _padding)
            }

            // 웹 뷰
            webDictView
                .id(selectedDict) // 선택된 사전 변경시 리로드
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(_padding)
        .background(
            VisualEffectView(
                material: NSVisualEffectView.Material.hudWindow,
                blendingMode: NSVisualEffectView.BlendingMode.behindWindow
            )
            .ignoresSafeArea()
        )
        .contextMenu { // Edge 우클릭시 표시
            Button((isToolbarEnabled ? "􀆅 " : "") + "툴바 표시") {
                isToolbarEnabled.toggle()
            }

            Button("새로 고침") {
                reloadDict()
            }

            Button("창 닫기") {
                closeDict()
            }

            Divider()

            Button("종료") {
                NSApplication.shared.terminate(self)
            }
        }
    }

    private func openDict() {
        WindowManager.shared.showDict()
    }

    private func reloadDict() {
        NotificationCenter.default.post(name: .reloadDict, object: "")
    }

    private func closeDict() {
        WindowManager.shared.closeDict()
    }

    private func openSettingPage() {
        WindowManager.shared.showSettings()
    }
}

#Preview {
    DictionaryView()
}
