import SwiftUI

struct ChatSettingsView: View {
    @ObservedObject private var chatSettingKeysManager = ChatSettingKeysManager.shared

    @State private var showChatActivationSetting = false
    @State private var customPromptName = ""
    @State private var customPromptPrefix = ""
    @State private var customPromptPostfix = ""

    @ObservedObject private var webDictManager = WebDictManager.shared

    var body: some View {
        Form {
            Toggle(isOn: chatSettingKeysManager.binding(\.isChatEnabled)) {
                Text("채팅 기능 사용")
            }

            Picker("채팅 서비스", selection: chatSettingKeysManager.binding(\.selectedChat)) {
                ForEach(webDictManager.getActivatedChats(), id: \.self) { chat in
                    Text(chat.wrappedName)
                        .tag(chat.id)
                }
            }
            .pickerStyle(.menu)
            .id(webDictManager.activatedChatIDs)
            .disabled(!chatSettingKeysManager.isChatEnabled)

            LabeledContent("") {
                Button("채팅 서비스 관리") {
                    showChatActivationSetting = true
                }
                .sheet(isPresented: $showChatActivationSetting) {
                    DictActivationSettingSheet(isPresented: $showChatActivationSetting, mode: "chat")
                }
            }
            .disabled(!chatSettingKeysManager.isChatEnabled)

            Section("자동 입력 프롬프트") {
                Picker("프롬프트", selection: chatSettingKeysManager.binding(\.selectedChatPromptID)) {
                    ForEach(webDictManager.getChatPrompts(), id: \.self) { prompt in
                        Text(prompt.name)
                            .tag(prompt.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!chatSettingKeysManager.isChatEnabled)

                TextField("커스텀 프롬프트 이름", text: $customPromptName)
                    .disabled(!chatSettingKeysManager.isChatEnabled)

                TextField("앞에 붙일 프롬프트", text: $customPromptPrefix, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .disabled(!chatSettingKeysManager.isChatEnabled)

                TextField("뒤에 붙일 프롬프트", text: $customPromptPostfix, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .disabled(!chatSettingKeysManager.isChatEnabled)

                HStack {
                    Button("커스텀 프롬프트 추가") {
                        addPrompt()
                    }
                    .disabled(!canAddPrompt)

                    Spacer()
                }

                if !webDictManager.customChatPrompts.isEmpty {
                    ForEach(webDictManager.customChatPrompts, id: \.self) { prompt in
                        HStack {
                            Text(prompt.name)

                            Spacer()

                            Button("삭제") {
                                webDictManager.deleteCustomChatPrompt(id: prompt.id)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    var canAddPrompt: Bool {
        return chatSettingKeysManager.isChatEnabled && !customPromptName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addPrompt() {
        let trimmedName = customPromptName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        webDictManager.addCustomChatPrompt(
            name: trimmedName,
            prefix: customPromptPrefix,
            postfix: customPromptPostfix
        )

        customPromptName = ""
        customPromptPrefix = ""
        customPromptPostfix = ""
    }
}
