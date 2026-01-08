import SwiftUI

struct DictActivationSettingSheet: View {
    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    @Binding var isPresented: Bool

    @State private var showCustomDictSetting = false

    @ObservedObject var webDictManager = WebDictManager.shared

    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }

    var body: some View {
        VStack {
            HStack {
                if #available(macOS 26.0, *), isLiquidGlassEnabled {
                    ToolbarButtonV2(action: { isPresented = false }, systemName: "xmark")
                }
                else {
                    ToolbarButton(action: { isPresented = false }, systemName: "xmark.circle")
                }

                Spacer()
            }

            List(webDictManager.getAllDicts(), children: \.children) { dict in
                if dict.children == nil {
                    Toggle(dict.wrappedName, isOn: Binding(
                        get: { webDictManager.isActivated(id: dict.id) },
                        set: { value in webDictManager.setActivation(value, id: dict.id) }
                    ))
                    .disabled(webDictManager.isActivated(id: dict.id) && webDictManager.activatedDictIDs.count <= 1)
                }
                else {
                    Text(dict.wrappedName)
                }
            }

            Button("커스텀 사전 설정") {
                showCustomDictSetting = true
            }
            .sheet(isPresented: $showCustomDictSetting) {
                CustomDictSettingSheet(isPresented: $showCustomDictSetting)
            }
        }
        .padding(8)
        .frame(width: 250, height: 350)
        .setViewColoredBackground()
    }
}
