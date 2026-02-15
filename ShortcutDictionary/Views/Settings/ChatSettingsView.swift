import SwiftUI

struct ChatSettingsView: View {
    @AppStorage(SettingKeys.isChatEnabled.rawValue)
    private var isChatEnabled = SettingKeys.isChatEnabled.defaultValue as! Bool

    @AppStorage(SettingKeys.selectedChat.rawValue)
    private var selectedChat = SettingKeys.selectedChat.defaultValue as! String

    @AppStorage(SettingKeys.activatedChats.rawValue)
    private var activatedChats = SettingKeys.activatedChats.defaultValue as! String

    @AppStorage(SettingKeys.selectedChatPromptID.rawValue)
    private var selectedChatPromptID = SettingKeys.selectedChatPromptID.defaultValue as! String

    @State private var showChatActivationSetting = false
    @State private var customPromptName = ""
    @State private var customPromptPrefix = ""
    @State private var customPromptPostfix = ""

    @ObservedObject private var webDictManager = WebDictManager.shared

    var body: some View {
        Form {
            Toggle(isOn: $isChatEnabled) {
                Text("채팅 기능 사용")
            }

            Picker("채팅 서비스", selection: $selectedChat) {
                ForEach(webDictManager.getActivatedChats(), id: \.self) { chat in
                    Text(chat.wrappedName)
                        .tag(chat.id)
                }
            }
            .pickerStyle(.menu)
            .id(activatedChats)
            .disabled(!isChatEnabled)

            LabeledContent("") {
                Button("채팅 서비스 관리") {
                    showChatActivationSetting = true
                }
                .sheet(isPresented: $showChatActivationSetting) {
                    DictActivationSettingSheet(isPresented: $showChatActivationSetting, mode: "chat")
                }
            }
            .disabled(!isChatEnabled)

            Section("자동 입력 프롬프트") {
                Picker("프롬프트", selection: $selectedChatPromptID) {
                    ForEach(webDictManager.getChatPrompts(), id: \.self) { prompt in
                        Text(prompt.name)
                            .tag(prompt.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!isChatEnabled)

                TextField("커스텀 프롬프트 이름", text: $customPromptName)
                    .disabled(!isChatEnabled)

                TextField("앞에 붙일 프롬프트", text: $customPromptPrefix, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .disabled(!isChatEnabled)

                TextField("뒤에 붙일 프롬프트", text: $customPromptPostfix, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .disabled(!isChatEnabled)

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
        return isChatEnabled && !customPromptName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
