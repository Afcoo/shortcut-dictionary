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
            .padding(.all, 8)

            Form {
                TextField("URL", text: $dictUrl)
                    .autocorrectionDisabled()
                LabeledContent("JavaScript") {
                    VStack(alignment: .leading) {
                        Text("let SD_clipboard_value = [클립보드에서 복사된 값];")
                        TextEditor(text: $dictScript)
                            .multilineTextAlignment(.leading)
                            .frame(height: 150)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 500)
        .onAppear {
            if let dict = WebDicts.shared.getDict(.custom) {
                dictUrl = dict.url
                dictScript = dict.script
            }
        }
        .onDisappear {
            let webDict = WebDict(
                name: "커스텀",
                url: dictUrl,
                script: dictScript
            )

            WebDicts.shared.saveCustomDict(webDict)
        }
    }
}
