import SwiftUI

/// macOS Tahoe 부터 사용 가능한 Liquid Glass 툴바
@available(macOS 26.0, *)
struct DictToolbarV2: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @State private var showChevron = false
    @State private var showMenu = false

    @Namespace private var namespace

    var body: some View {
        HStack {
            // 닫기 버튼
            ToolbarButtonV2(
                action: { WindowManager.shared.closeDict() },
                systemName: "xmark"
            )

            Spacer()

            // 사전 전환 메뉴
            Button(action: { showMenu.toggle() }) {
                ZStack(alignment: .trailing) {
                    Text(WebDictManager.shared.getDict(selectedDict)?.getName() ?? "error")
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .offset(x: showChevron || showMenu ? -6 : 0)

                    if showChevron || showMenu {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .offset(x: 6)
                    }
                }
            }
            .popover(
                isPresented: $showMenu,
                arrowEdge: .bottom
            ) {
                VStack {
                    ForEach(WebDictManager.shared.getActivatedDicts(), id: \.self) { dict in
                        Button(
                            dict.getName(),
                            action: {
                                selectedDict = dict.id
                                showMenu.toggle()
                            }
                        )
                        .buttonStyle(.borderless)
                    }

                    Button("사전 종류 관리") {}
                }
                .padding(.all, 8)
                .frame(maxWidth: 180)
            }
            .buttonStyle(.borderless)
            .buttonBorderShape(.capsule)
            .onHover { isHover in
                withAnimation {
                    showChevron = isHover
                }
            }

            Spacer()

            // 뒤로/앞으로 버튼
            GlassEffectContainer {
                HStack {
                    ToolbarButtonV2(
                        action: {},
                        systemName: "chevron.left"
                    )
                    .glassEffectUnion(id: "bnf", namespace: namespace)

//                    TODO: seperator 추가

                    ToolbarButtonV2(
                        action: {},
                        systemName: "chevron.right"
                    )
                    .glassEffectUnion(id: "bnf", namespace: namespace)
                }
            }

            // 새로고침 버튼
            ToolbarButtonV2(
                action: { NotificationCenter.default.post(name: .reloadDict, object: "") },
                systemName: "arrow.trianglehead.clockwise"
            )

            // 설정 버튼
            ToolbarButtonV2(
                action: { WindowManager.shared.showSettings() },
                systemName: "gear"
            )
        }
        .padding(8)
        .contentShape(.rect) // 툴바 공간을 클릭 가능하게
        .contextMenu {
            Button(action: {})
                {}
        }
        // TODO: 웹 페이지 맞춰서 색상 설정하기
        .background {}
    }
}

@available(macOS 26.0, *)
struct ToolbarButtonV2: View {
    let action: () -> Void
    let systemName: String

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(Color(.tertiaryLabelColor))
                .font(.system(size: 18))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.accessoryBar)
        .buttonBorderShape(.circle)
        .glassEffect()
    }
}
