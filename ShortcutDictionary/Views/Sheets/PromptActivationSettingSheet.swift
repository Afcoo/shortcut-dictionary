import SwiftUI

struct PromptActivationSettingSheet: View {
    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared
    @ObservedObject private var chatSettingKeysManager = ChatSettingKeysManager.shared
    @ObservedObject private var webDictManager = WebDictManager.shared

    @Binding var isPresented: Bool

    @State private var selectedPromptID: String?
    @State private var promptName = ""
    @State private var promptPrefix = ""
    @State private var promptPostfix = ""
    @State private var showPromptEditorSheet = false
    @State private var isPromptEditorReadOnly = false

    var body: some View {
        VStack {
            HStack {
                if #available(macOS 26.0, *), appearanceSettingKeysManager.isLiquidGlassEnabled {
                    ToolbarButtonV2(action: { isPresented = false }, systemName: "xmark")
                } else {
                    ToolbarButton(action: { isPresented = false }, systemName: "xmark.circle")
                }

                Spacer()
            }

            promptTable

            HStack {
                Button("추가") {
                    let newPrompt = webDictManager.addCustomChatPrompt(name: "새 커스텀 프롬프트", prefix: "", postfix: "")
                    selectedPromptID = newPrompt.id
                    loadEditor(prompt: newPrompt)
                    isPromptEditorReadOnly = false
                    showPromptEditorSheet = true
                }

                Button("삭제") {
                    guard let selectedPromptID else { return }
                    webDictManager.deleteCustomChatPrompt(id: selectedPromptID)

                    if chatSettingKeysManager.selectedChatPromptID == selectedPromptID {
                        chatSettingKeysManager.selectedChatPromptID = ChatPromptPresets.none.id
                    }

                    self.selectedPromptID = webDictManager.getChatPrompts().first?.id
                    resetEditor()
                }
                .disabled(!isSelectedCustomPrompt)

                Button("편집") {
                    isPromptEditorReadOnly = false
                    showPromptEditorSheet = true
                }
                .disabled(!isSelectedCustomPrompt)

                Spacer()
            }
        }
        .padding(8)
        .frame(width: 500)
        .setViewColoredBackground()
        .sheet(isPresented: $showPromptEditorSheet) {
            promptEditorSheet
        }
        .onAppear {
            selectedPromptID = webDictManager.getChatPrompts().first?.id

            if let firstCustomPrompt = webDictManager.customChatPrompts.first {
                selectedPromptID = firstCustomPrompt.id
                loadEditor(prompt: firstCustomPrompt)
            }
        }
        .onChange(of: selectedPromptID) { newValue in
            guard let newValue,
                  let selectedPrompt = webDictManager.getChatPrompts().first(where: { $0.id == newValue })
            else {
                resetEditor()
                return
            }

            loadEditor(prompt: selectedPrompt)
            isPromptEditorReadOnly = selectedPrompt.isPreset
        }
    }

    private var promptTable: some View {
        Table(webDictManager.getChatPrompts(), selection: $selectedPromptID) {
            TableColumn("이름") { (prompt: ChatPrompt) in
                Text(prompt.name)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .width(120)

            TableColumn("앞 프롬프트") { (prompt: ChatPrompt) in
                Text(prompt.prefix)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }

            TableColumn("뒷 프롬프트") { (prompt: ChatPrompt) in
                Text(prompt.postfix)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
            }
        }
        .contextMenu(forSelectionType: String.self, menu: { _ in
            EmptyView()
        }, primaryAction: { selectedIDs in
            handleTablePrimaryAction(selectedIDs)
        })
        .frame(height: 320)
    }

    private var isSelectedCustomPrompt: Bool {
        guard let selectedPromptID else { return false }
        return webDictManager.customChatPrompts.contains(where: { $0.id == selectedPromptID })
    }

    private func handleTablePrimaryAction(_ selectedIDs: Set<String>) {
        guard let selectedID = selectedIDs.first else { return }

        selectedPromptID = selectedID

        if let selectedPrompt = webDictManager.getChatPrompts().first(where: { $0.id == selectedID }) {
            loadEditor(prompt: selectedPrompt)
            isPromptEditorReadOnly = selectedPrompt.isPreset
            showPromptEditorSheet = true
        }
    }

    private var promptEditorSheet: some View {
        ZStack(alignment: .topLeading) {
            Form {
                TextField("이름", text: $promptName)
                    .autocorrectionDisabled()

                TextField("앞에 붙일 프롬프트", text: $promptPrefix, axis: .vertical)
                    .lineLimit(2 ... 6)

                TextField("뒤에 붙일 프롬프트", text: $promptPostfix, axis: .vertical)
                    .lineLimit(2 ... 6)
            }
            .formStyle(.grouped)
            .padding(.top, 32)
            .padding(.bottom, 32)
            .disabled(isPromptEditorReadOnly)

            Group {
                if #available(macOS 26.0, *), appearanceSettingKeysManager.isLiquidGlassEnabled {
                    ToolbarButtonV2(action: { showPromptEditorSheet = false }, systemName: "xmark")
                } else {
                    ToolbarButton(action: { showPromptEditorSheet = false }, systemName: "xmark.circle")
                }
            }
            .position(x: 26, y: 26)
        }
        .frame(width: 420)
        .background { Color(NSColor.windowBackgroundColor) }
        .onDisappear {
            if !isPromptEditorReadOnly {
                saveSelectedPrompt()
            }
        }
    }

    private func resetEditor() {
        promptName = ""
        promptPrefix = ""
        promptPostfix = ""
        isPromptEditorReadOnly = false
    }

    private func loadEditor(prompt: ChatPrompt) {
        promptName = prompt.name
        promptPrefix = prompt.prefix
        promptPostfix = prompt.postfix
    }

    private func saveSelectedPrompt() {
        guard !isPromptEditorReadOnly,
              let selectedPromptID,
              let selectedPrompt = webDictManager.customChatPrompts.first(where: { $0.id == selectedPromptID })
        else {
            return
        }

        let trimmedName = promptName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let updatedPrompt = ChatPrompt(
            id: selectedPrompt.id,
            name: trimmedName,
            prefix: promptPrefix,
            postfix: promptPostfix,
            isPreset: false
        )

        webDictManager.updateCustomChatPrompt(updatedPrompt)
    }
}
