import SwiftUI

struct DictActivationSettingSheet: View {
    @AppStorage(SettingKeys.selectedDict.rawValue)
    private var selectedDict = SettingKeys.selectedDict.defaultValue as! String

    @Binding var isPresented: Bool

    @State private var showCustomDictSetting = false

    @State private var isOns: [Bool] = []

    let dictManager = WebDictManager.shared
    let allDicts = WebDictManager.shared.getAllDicts()

    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
        _isOns = State(initialValue: allDicts.map { dict in
            dictManager.getActivation(dict: dict)
        })
    }

    var body: some View {
        VStack {
            HStack {
                Text("사전 종류 관리")
                    .font(.headline)
                    .foregroundColor(Color(.tertiaryLabelColor))
                Spacer()
                ToolbarButton(action: { isPresented = false }, systemName: "xmark.circle")
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            List {
                ForEach(allDicts.indices, id: \.self) { index in
                    let dict = allDicts[index]

                    Toggle(
                        dict.getName(),
                        isOn: $isOns[index]
                    )
                    .onChange(of: isOns[index]) { toValue in

                        if toValue {
                            dictManager.addActivation(dict: dict)
//                            selectedDict = allDicts[index].id
                        }
                        else {
                            dictManager.removeActivation(dict: dict)

                            selectedDict = allDicts[isOns.firstIndex(of: true) ?? 0].id
                        }

                        // 에러 처리?
                    }
                    // 활성화된 사전이 1개 뿐일 때 비활성화 하지 못하게 방지
                    .disabled(isOns[index] == true && dictManager.activatedDicts.count <= 1)
                }
            }
            .frame(height: 200)

            Button("커스텀 사전 설정") {
                showCustomDictSetting = true
            }
            .sheet(isPresented: $showCustomDictSetting) {
                CustomDictSettingSheet(isPresented: $showCustomDictSetting)
            }
        }
    }
}
