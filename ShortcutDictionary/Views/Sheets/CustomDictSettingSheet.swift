import SwiftUI

struct CustomDictSettingSheet: View {
    @Binding var isPresented: Bool

    @State private var dictUrl = ""
    @State private var dictScript = ""

    var body: some View {
        VStack {
            HStack {
                Text("커스텀 사전 설정")
                    .font(.headline)
                    .foregroundColor(Color(.tertiaryLabelColor))
                Spacer()
                ToolbarButton(action: { isPresented = false }, systemName: "xmark.circle")
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)

            Form {
                TextField("URL", text: $dictUrl)
                    .autocorrectionDisabled()
                LabeledContent("JavaScript") {
                    VStack(alignment: .leading) {
                        Text("let SD_clipboard_value = [클립보드에서 복사된 값];")
                        TextEditor(text: $dictScript)
                            .multilineTextAlignment(.leading)
                            .frame(height: 150)

                        Text("스크립트는 즉시 실행 함수로 실행됩니다")
                    }
                }
            }
            .formStyle(.grouped)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 500)
        .onAppear {
            if let dict = WebDicts.shared.getDict("custom") {
                dictUrl = dict.url
                dictScript = dict.script
            }
        }
        .onDisappear {
            let webDict = WebDict(
                id: "custom",
                name: "커스텀",
                url: dictUrl,
                script: dictScript
            )

            WebDicts.shared.saveCustomDict(webDict)
        }
    }
}
