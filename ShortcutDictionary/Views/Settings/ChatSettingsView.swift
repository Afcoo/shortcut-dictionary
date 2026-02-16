import SwiftUI

struct ChatSettingsView: View {
    @ObservedObject private var chatSettingKeysManager = ChatSettingKeysManager.shared
    @ObservedObject private var dictionarySettingKeysManager = DictionarySettingKeysManager.shared

    @State private var showChatActivationSetting = false
    @State private var showPromptManagementSetting = false

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
                Button("채팅 종류 관리") {
                    showChatActivationSetting = true
                }
                .sheet(isPresented: $showChatActivationSetting) {
                    DictActivationSettingSheet(isPresented: $showChatActivationSetting, mode: "chat")
                }
            }
            .disabled(!chatSettingKeysManager.isChatEnabled)

            Toggle(isOn: dictionarySettingKeysManager.binding(\.isMobileView)) {
                Text("모바일 뷰 사용")
                Text("설정을 적용하기 위해 재시작이 필요합니다")
            }
            .onChange(of: dictionarySettingKeysManager.isMobileView) { _, _ in
                NotificationCenter.default.post(name: .reloadDict, object: nil)
            }

            Section("자동 입력 프롬프트") {
                Picker("프롬프트", selection: chatSettingKeysManager.binding(\.selectedChatPromptID)) {
                    ForEach(webDictManager.getChatPrompts(), id: \.self) { prompt in
                        Text(prompt.name)
                            .tag(prompt.id)
                    }
                }
                .pickerStyle(.menu)
                .id(webDictManager.customChatPrompts)
                .disabled(!chatSettingKeysManager.isChatEnabled)

                LabeledContent("") {
                    Button("프롬프트 관리") {
                        showPromptManagementSetting = true
                    }
                    .sheet(isPresented: $showPromptManagementSetting) {
                        PromptActivationSettingSheet(isPresented: $showPromptManagementSetting)
                    }
                }
                .disabled(!chatSettingKeysManager.isChatEnabled)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
