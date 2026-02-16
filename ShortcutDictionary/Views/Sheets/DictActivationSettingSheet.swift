import SwiftUI

struct DictActivationSettingSheet: View {
    private enum GroupActivationState {
        case off
        case mixed
        case on
    }

    private struct TriStateCheckbox: NSViewRepresentable {
        private static let checkboxTag = 1024

        let state: GroupActivationState
        let isDisabled: Bool
        let onToggle: () -> Void

        func makeCoordinator() -> Coordinator {
            Coordinator(onToggle: onToggle)
        }

        func makeNSView(context: Context) -> NSView {
            let container = NSView()
            let button = NSButton(checkboxWithTitle: "", target: context.coordinator, action: #selector(Coordinator.handleToggle))
            button.setButtonType(.switch)
            button.allowsMixedState = true
            button.imagePosition = .imageOnly
            button.tag = Self.checkboxTag
            button.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(button)
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ])

            return container
        }

        func updateNSView(_ nsView: NSView, context: Context) {
            guard let button = nsView.viewWithTag(Self.checkboxTag) as? NSButton else { return }

            context.coordinator.onToggle = onToggle
            button.state = switch state {
            case .off: .off
            case .mixed: .mixed
            case .on: .on
            }
            button.isEnabled = !isDisabled
        }

        final class Coordinator: NSObject {
            var onToggle: () -> Void

            init(onToggle: @escaping () -> Void) {
                self.onToggle = onToggle
            }

            @objc func handleToggle() {
                onToggle()
            }
        }
    }

    private struct DictTableRow: Identifiable {
        let dict: WebDict
        let depth: Int
        let ancestorParentIDs: [String]

        var id: String {
            dict.id
        }

        var isParent: Bool {
            dict.children != nil
        }
    }

    @ObservedObject private var appearanceSettingKeysManager = AppearanceSettingKeysManager.shared
    @ObservedObject private var webDictManager = WebDictManager.shared

    @Binding var isPresented: Bool
    let mode: String

    @State private var selectedDictID: String?
    @State private var dictName = ""
    @State private var dictUrl = ""
    @State private var dictScript = ""
    @State private var dictPostScript = ""
    @State private var dictPrefix = ""
    @State private var dictPostfix = ""
    @State private var collapsedParentIDs: Set<String> = []
    @State private var showCustomEditorSheet = false
    @State private var isCustomEditorReadOnly = false

    init(isPresented: Binding<Bool>, mode: String = "dictionary") {
        _isPresented = isPresented
        self.mode = mode
    }

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

            activationTable

            HStack {
                Button("추가") {
                    let newDict = webDictManager.addCustomWebDict(mode: mode)
                    selectedDictID = newDict.id
                    loadEditor(dict: newDict)
                    isCustomEditorReadOnly = false
                }

                Button("삭제") {
                    guard let selectedDictID else { return }
                    webDictManager.deleteCustomWebDict(id: selectedDictID, mode: mode)
                    self.selectedDictID = nil
                    resetEditor()
                }
                .disabled(!isSelectedCustomItem)

                Button("편집") {
                    isCustomEditorReadOnly = false
                    showCustomEditorSheet = true
                }
                .disabled(!isSelectedCustomItem)

                Spacer()

                if mode == "dictionary" {
                    Button("이전 커스텀 사전 불러오기") {
                        _ = webDictManager.importLegacyCustomDictFromAppStorage()
                    }
                }
            }
        }
        .padding(8)
        .frame(width: 500)
        .setViewColoredBackground()
        .sheet(isPresented: $showCustomEditorSheet) {
            customEditorSheet
        }
        .onAppear {
            if mode == "dictionary" {
                collapsedParentIDs = Set(tableItems.filter(\.isParent).map(\.id))
            }

            if let first = customItems.first {
                selectedDictID = first.id
                loadEditor(dict: first)
            } else {
                selectedDictID = items.first?.id
            }
        }
        .onChange(of: selectedDictID) { newValue in
            guard let newValue,
                  let selectedRow = tableItems.first(where: { $0.id == newValue }),
                  !selectedRow.isParent
            else {
                resetEditor()
                return
            }

            loadEditor(dict: selectedRow.dict)
            isCustomEditorReadOnly = !isCustomItem(newValue)
        }
    }

    private var activationTable: some View {
        Table(visibleTableItems, selection: $selectedDictID) {
            TableColumn("활성") { (row: DictTableRow) in
                if row.isParent {
                    AnyView(TriStateCheckbox(
                        state: parentActivationState(for: row.dict),
                        isDisabled: isParentToggleDisabled(row.dict),
                        onToggle: { toggleParentActivation(row.dict) }
                    )
                    .frame(width: 22, height: 16))
                } else {
                    AnyView(Toggle("", isOn: Binding(
                        get: { isActivated(row.dict.id) },
                        set: { value in setActivation(value, row.dict.id) }
                    ))
                    .labelsHidden()
                    .toggleStyle(.checkbox)
                    .frame(width: 22)
                    .disabled(isActivated(row.dict.id) && activatedCount <= 1))
                }
            }
            .width(30)

            TableColumn("이름") { (row: DictTableRow) in
                HStack(spacing: 6) {
                    Color.clear
                        .frame(width: CGFloat(row.depth * 16))

                    if row.isParent {
                        Button(action: { toggleCollapse(parentID: row.id) }) {
                            Image(systemName: collapsedParentIDs.contains(row.id) ? "chevron.right" : "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(.secondaryLabelColor))
                                .frame(width: 14, height: 14)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 24, height: 16)
                        .contentShape(Rectangle())
                    } else {
                        Color.clear
                            .frame(width: 24)
                    }

                    Text(row.dict.wrappedName)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .width(150)

            TableColumn("URL") { (row: DictTableRow) in
                if row.isParent {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                } else {
                    Text(row.dict.url)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
            }
        }
        .contextMenu(forSelectionType: String.self, menu: { _ in
            EmptyView()
        }, primaryAction: { selectedIDs in
            handleTablePrimaryAction(selectedIDs)
        })
        .frame(height: 300)
    }

    var items: [WebDict] {
        if mode == "dictionary" {
            return webDictManager.getAllSelectableDicts()
        }

        return webDictManager.getAllSelectableChats()
    }

    private var tableItems: [DictTableRow] {
        if mode == "dictionary" {
            return flattenRows(webDictManager.getAllDicts())
        }

        return webDictManager.getAllChats().map { DictTableRow(dict: $0, depth: 0, ancestorParentIDs: []) }
    }

    private var visibleTableItems: [DictTableRow] {
        return tableItems.filter { row in
            row.ancestorParentIDs.allSatisfy { !collapsedParentIDs.contains($0) }
        }
    }

    private func flattenRows(_ dicts: [WebDict], depth: Int = 0, ancestorParentIDs: [String] = []) -> [DictTableRow] {
        var rows: [DictTableRow] = []

        for dict in dicts {
            rows.append(DictTableRow(dict: dict, depth: depth, ancestorParentIDs: ancestorParentIDs))

            if let children = dict.children {
                rows.append(contentsOf: flattenRows(children, depth: depth + 1, ancestorParentIDs: ancestorParentIDs + [dict.id]))
            }
        }

        return rows
    }

    private func toggleCollapse(parentID: String) {
        if collapsedParentIDs.contains(parentID) {
            collapsedParentIDs.remove(parentID)
        } else {
            collapsedParentIDs.insert(parentID)
        }
    }

    private func handleTablePrimaryAction(_ selectedIDs: Set<String>) {
        guard let selectedID = selectedIDs.first,
              let row = tableItems.first(where: { $0.id == selectedID })
        else {
            return
        }

        if row.isParent {
            toggleCollapse(parentID: selectedID)
            return
        }

        selectedDictID = selectedID
        loadEditor(dict: row.dict)
        isCustomEditorReadOnly = !isCustomItem(selectedID)
        showCustomEditorSheet = true
    }

    private func parentActivationState(for dict: WebDict) -> GroupActivationState {
        let leafIDs = collectLeafIDs(from: dict)

        if leafIDs.isEmpty {
            return .off
        }

        let activeCount = leafIDs.filter { isActivated($0) }.count

        if activeCount == 0 {
            return .off
        }

        if activeCount == leafIDs.count {
            return .on
        }

        return .mixed
    }

    private func toggleParentActivation(_ dict: WebDict) {
        let leafIDs = collectLeafIDs(from: dict)

        if leafIDs.isEmpty {
            return
        }

        let shouldActivateAll = parentActivationState(for: dict) != GroupActivationState.on

        for id in leafIDs {
            setActivation(shouldActivateAll, id)
        }
    }

    private func isParentToggleDisabled(_ dict: WebDict) -> Bool {
        let leafIDs = collectLeafIDs(from: dict)
        guard !leafIDs.isEmpty else { return true }

        let activeInParent = leafIDs.filter { isActivated($0) }.count
        let remainingActive = activatedCount - activeInParent
        let state = parentActivationState(for: dict)

        return remainingActive <= 0 && state == GroupActivationState.on
    }

    private func collectLeafIDs(from dict: WebDict) -> [String] {
        if let children = dict.children {
            return children.flatMap { collectLeafIDs(from: $0) }
        }

        return [dict.id]
    }

    private var customItems: [WebDict] {
        if mode == "chat" {
            return webDictManager.customChats
        }

        return webDictManager.customDicts
    }

    private var isSelectedCustomItem: Bool {
        guard let selectedDictID else { return false }
        return isCustomItem(selectedDictID)
    }

    private var activatedCount: Int {
        if mode == "chat" {
            return webDictManager.activatedChatIDs.count
        }

        return webDictManager.activatedDictIDs.count
    }

    private func isCustomItem(_ id: String) -> Bool {
        return customItems.contains { $0.id == id }
    }

    private func isActivated(_ id: String) -> Bool {
        if mode == "chat" {
            return webDictManager.isActivatedChat(id: id)
        }

        return webDictManager.isActivated(id: id)
    }

    private func setActivation(_ value: Bool, _ id: String) {
        if mode == "chat" {
            webDictManager.setChatActivation(value, id: id)
            return
        }

        webDictManager.setActivation(value, id: id)
    }

    private var customEditorSheet: some View {
        ZStack(alignment: .topLeading) {
            Form {
                TextField("이름", text: $dictName)
                    .autocorrectionDisabled()

                TextField("URL", text: $dictUrl)
                    .autocorrectionDisabled()

                LabeledContent("JavaScript") {
                    VStack(alignment: .leading, spacing: 6) {
                        TextEditor(text: $dictScript)
                            .multilineTextAlignment(.leading)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("사전이 표시될 때 실행되는 스크립트입니다")
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("즉시 실행 함수로 실행되며, 복사된 값은 SD_clipboard_value 변수에 저장됩니다")
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                LabeledContent("즉시 검색 Javascript") {
                    VStack(alignment: .leading, spacing: 6) {
                        TextEditor(text: $dictPostScript)
                            .multilineTextAlignment(.leading)
                            .frame(height: 70)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("즉시 검색이 활성화되었을 시, 텍스트 입력 후 실행되는 스크립트입니다")
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .formStyle(.grouped)
            .padding(.top, 32)
            .disabled(isCustomEditorReadOnly)

            Group {
                if #available(macOS 26.0, *), appearanceSettingKeysManager.isLiquidGlassEnabled {
                    ToolbarButtonV2(action: { showCustomEditorSheet = false }, systemName: "xmark")
                } else {
                    ToolbarButton(action: { showCustomEditorSheet = false }, systemName: "xmark.circle")
                }
            }
            .position(x: 26, y: 26)
        }
        .frame(width: 400)
        .background { Color(NSColor.windowBackgroundColor) }
        .onDisappear {
            if !isCustomEditorReadOnly {
                saveSelectedDict()
            }
        }
    }

    private func resetEditor() {
        dictName = ""
        dictUrl = ""
        dictScript = ""
        dictPostScript = ""
        dictPrefix = ""
        dictPostfix = ""
        isCustomEditorReadOnly = false
    }

    private func loadEditor(dict: WebDict) {
        dictName = dict.name ?? ""
        dictUrl = dict.url
        dictScript = dict.script
        dictPostScript = dict.postScript ?? ""
        dictPrefix = dict.prefix ?? ""
        dictPostfix = dict.postfix ?? ""
    }

    private func saveSelectedDict() {
        guard !isCustomEditorReadOnly,
              let selectedDictID,
              isCustomItem(selectedDictID)
        else {
            return
        }

        let trimmedName = dictName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = dictUrl.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURL.isEmpty else { return }

        let updated = WebDict(
            id: selectedDictID,
            name: trimmedName.isEmpty ? nil : trimmedName,
            url: trimmedURL,
            script: dictScript,
            postScript: dictPostScript.isEmpty ? nil : dictPostScript,
            prefix: dictPrefix.isEmpty ? nil : dictPrefix,
            postfix: dictPostfix.isEmpty ? nil : dictPostfix
        )

        webDictManager.updateCustomWebDict(updated, mode: mode)
    }
}
