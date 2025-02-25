import SwiftUI

struct Toolbar: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @State private var showMenu = false

    var body: some View {
        HStack {
            // 닫기 버튼
            ToolbarButton(
                action: { WindowManager.shared.closeDict() },
                systemName: "xmark.circle"
            )

            // 좌우 간격 맞추기용
            Image(systemName: "space")
                .foregroundStyle(.clear)
                .imageScale(.large)

            Spacer()

            // 사전 전환 메뉴
            Button(action: { showMenu.toggle() }) {
                HStack {
                    Text(WebDicts.shared.getDict(selectedDict)?.getName() ?? "error")

                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundColor(Color(.tertiaryLabelColor))
                }
            }
            .popover(
                isPresented: $showMenu,
                arrowEdge: .bottom
            ) {
                VStack {
                    ForEach(WebDicts.shared.getAllDicts(), id: \.self) { dict in
                        Button(
                            dict.getName(),
                            action: {
                                selectedDict = dict.id
                                print(selectedDict)
                                showMenu.toggle()
                            }
                        )
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.all, 8)
            }

            .buttonStyle(.borderless)
            .foregroundStyle(.tertiary)
            .frame(width: 80)

            Spacer()

            // 새로고침 버튼
            ToolbarButton(
                action: {
                    NotificationCenter.default.post(name: .reloadDict, object: "")
                },
                systemName: "arrow.clockwise.circle"
            )

            // 설정 버튼
            ToolbarButton(
                action: { WindowManager.shared.showSettings() },
                systemName: "gear.circle"
            )
        }
    }
//
//    private func openDict() {
//        WindowManager.shared.showDict()
//    }
//
//    private func reloadDict() {
//        NotificationCenter.default.post(name: .reloadDict, object: "")
//    }
//
//    private func closeDict() {
//        WindowManager.shared.closeDict()
//    }
//
//    private func openSettingPage() {
//        WindowManager.shared.showSettings()
//    }
}

#Preview {
    Toolbar()
}
