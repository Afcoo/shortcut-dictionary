import SwiftUI

struct DictActivationSettingSheet: View {
    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    @Binding var isPresented: Bool
    let mode: String

    @State private var showCustomDictSetting = false

    @ObservedObject var webDictManager = WebDictManager.shared

    init(isPresented: Binding<Bool>, mode: String = "dictionary") {
        _isPresented = isPresented
        self.mode = mode
    }

    var body: some View {
        VStack {
            HStack {
                if #available(macOS 26.0, *), isLiquidGlassEnabled {
                    ToolbarButtonV2(action: { isPresented = false }, systemName: "xmark")
                } else {
                    ToolbarButton(action: { isPresented = false }, systemName: "xmark.circle")
                }

                Spacer()
            }

            List(items, children: \.children) { dict in
                if dict.children == nil {
                    if mode == "dictionary" {
                        Toggle(dict.wrappedName, isOn: Binding(
                            get: { webDictManager.isActivated(id: dict.id) },
                            set: { value in webDictManager.setActivation(value, id: dict.id) }
                        ))
                        .disabled(webDictManager.isActivated(id: dict.id) && webDictManager.activatedDictIDs.count <= 1)
                    } else {
                        Toggle(dict.wrappedName, isOn: Binding(
                            get: { webDictManager.isActivatedChat(id: dict.id) },
                            set: { value in webDictManager.setChatActivation(value, id: dict.id) }
                        ))
                        .disabled(webDictManager.isActivatedChat(id: dict.id) && webDictManager.activatedChatIDs.count <= 1)
                    }
                } else {
                    Text(dict.wrappedName)
                }
            }

            if mode == "dictionary" {
                Button("커스텀 사전 설정") {
                    showCustomDictSetting = true
                }
                .sheet(isPresented: $showCustomDictSetting) {
                    CustomDictSettingSheet(isPresented: $showCustomDictSetting)
                }
            }
        }
        .padding(8)
        .frame(width: 250, height: 350)
        .setViewColoredBackground()
    }

    var items: [WebDict] {
        if mode == "dictionary" {
            return webDictManager.getAllDicts()
        }

        return webDictManager.getAllChats()
    }
}
