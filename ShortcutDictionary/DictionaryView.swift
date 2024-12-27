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
//                    Spacer()
                    ToolbarButton(action: openSettingPage, systemName: "gear.circle")
                }
                Spacer()
                    .frame(height: _padding)
            }

            // 웹 뷰
            webDictView
                .id(selectedDict) // 값 변경시 리로드
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
    }

    private func openDict() {
        WindowManager.shared.show()
    }

    private func reloadDict() {
        NotificationCenter.default.post(name: .reloadDict, object: "")
    }

    private func closeDict() {
        WindowManager.shared.close()
    }

    private func openSettingPage() {
        WindowManager.shared.showSettings()
    }
}

#Preview {
    DictionaryView()
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

struct ToolbarButton: View {
    let action: () -> Void
    let systemName: String
    var useSystem = true

    var body: some View {
        Button(
            action: action,
            label: {
                if useSystem {
                    Image(systemName: systemName)
                        .imageScale(.large)
                        .foregroundColor(Color(.tertiaryLabelColor))
                }
                else {
                    Image(systemName)
                        .renderingMode(.template) // 색 변경 가능하게
                        .resizable()
                        .scaledToFit() // 비율 유지
                        .frame(height: 20)
                        .foregroundColor(Color(.tertiaryLabelColor))
                }
            }
        ).buttonStyle(.plain)
    }
}
