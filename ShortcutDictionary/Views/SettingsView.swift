import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI
import WebKit

#Preview {
    SettingsView()
        .frame(height: 230)
}

struct SettingViews: Identifiable {
    let id = UUID()
    let height: Int
    let label: String
    let image: String
    let view: any View
}

struct SettingsView: View {
    @State private var currentView = 0

    let viewHeights: [CGFloat] = [
        115,
        170,
        265,
        260
    ]

    var body: some View {
        TabView(selection: $currentView) {
            GeneralSettingsView()
                .tabItem {
                    Label("일반", systemImage: "switch.2")
                }
                .tag(0)
            ShortcutSettingsView()
                .tabItem {
                    Label("단축키", systemImage: "keyboard")
                }
                .tag(1)
            DictionarySettingsView()
                .tabItem {
                    Label("사전", systemImage: "character.book.closed.fill")
                }
                .tag(2)
            InfoSettingsView()
                .tabItem {
                    Label("정보", systemImage: "info.circle")
                }
                .tag(3)
        }
        .frame(width: 350)
        .frame(height: viewHeights[currentView])
        .onDisappear {
            if !WindowManager.shared.dictWindow.isVisible {
                NSApplication.shared.setActivationPolicy(.prohibited)
            }
        }
    }
}

struct GeneralSettingsView: View {
    @AppStorage("enable_menu_item") var isMenuItemEnabled: Bool = true

    var body: some View {
        Form {
            // 시작 시 실행
            LaunchAtLogin.Toggle("시작 시 실행")

            // 메뉴 아이템 표시
            Toggle(isOn: $isMenuItemEnabled) {
                Text("메뉴 바 아이템 표시")
            }
            .onChange(of: isMenuItemEnabled) { _ in
                setMenuItemEnabled()
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
    }

    func setMenuItemEnabled() {
        if isMenuItemEnabled {
            MenubarManager.shared.setupMenuBarItem()
        }
        else {
            MenubarManager.shared.removeMenuBarItem()
        }
    }
}

struct ShortcutSettingsView: View {
    @AppStorage("enable_global_shortcut") var isGlobalShortcutEnabled: Bool = false
    @AppStorage("enable_copy_paste") var isCopyPasteEnabled: Bool = true

    var body: some View {
        Form {
            // 전역 단축키
            Toggle(isOn: $isGlobalShortcutEnabled) {
                Text("단축키 사용")
            }
            .onChange(of: isGlobalShortcutEnabled) { _ in
                setGlobalShortcutEnabled()
            }

            // 단축키 설정
            KeyboardShortcuts.Recorder("단축키", name: .dictShortcut)
                //                .padding(.leading, 20)
                .disabled(!isGlobalShortcutEnabled)

            // 단축키 입력시 복사 유무 결정
            Toggle(isOn: $isCopyPasteEnabled) {
                Text("선택된 단어 바로 검색")
                Text("단축키 입력시 자동으로 복사&붙여넣기를 합니다")
            }
            //                .padding(.leading, 20)
            .disabled(!isGlobalShortcutEnabled)
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
    }

    func setGlobalShortcutEnabled() {
        if isGlobalShortcutEnabled {
            KeyboardShortcuts.enable(.dictShortcut)
        }
        else {
            KeyboardShortcuts.disable(.dictShortcut)
        }
    }
}

struct DictionarySettingsView: View {
    @AppStorage("selected_dictonary") var selectedDict: Dicts = .daum
    @AppStorage("enable_always_on_top") var isAlwaysOnTop: Bool = false
    @AppStorage("enable_toolbar") var isToolbarEnabled: Bool = true
    @AppStorage("enable_show_on_mouse_position") var isShowOnMousePos: Bool = true
    @AppStorage("enable_close_with_esc") var isEscToClose: Bool = true
    @AppStorage("enable_close_with_out_click") var isOutClickToClose: Bool = true

    var body: some View {
        Form {
            // 사전 선택
            Picker("사전 종류", selection: $selectedDict) {
                ForEach(Dicts.allCases, id: \.self) { dict in
                    Text(Dicts.getName(dict)).tag(dict)
                }
            }.pickerStyle(.radioGroup)

            // 항상 위에 표시
            Toggle(isOn: $isAlwaysOnTop) {
                Text("항상 위에 표시")
            }

            // 툴바 표시
            Toggle(isOn: $isToolbarEnabled) {
                Text("툴바 표시")
            }
            .onChange(of: isAlwaysOnTop) { _ in
                WindowManager.shared.setDictAlwaysOnTop()
            }

            // 마우스 위치에 사전 표시
            Toggle(isOn: $isShowOnMousePos) {
                Text("마우스 위치에 사전 표시")
            }

            // ESC로 사전 닫기
            Toggle(isOn: $isEscToClose) {
                Text("ESC키로 사전 닫기")
            }

            // 사전 바깥 클릭 시 닫기
            Toggle(isOn: $isOutClickToClose) {
                Text("사전 밖 클릭 시 닫기")
            }
            .onChange(of: isOutClickToClose) { _ in
                WindowManager.shared.setOutClickToClose()
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .scrollDisabled(true)
    }
}

struct InfoSettingsView: View {
    @Environment(\.openURL) var openURL

    struct ThirdPartyLicense: Identifiable {
        let id = UUID()
        let name: String
        let licenseType: String
        let url: String
        let licenseUrl: String
    }

    let licenses = [
        ThirdPartyLicense(
            name: "KeyboardShortcuts",
            licenseType: "MIT",
            url: "https://github.com/sindresorhus/KeyboardShortcuts",
            licenseUrl: "https://github.com/sindresorhus/KeyboardShortcuts/blob/main/license"
        ),

        ThirdPartyLicense(
            name: "LaunchAtLogin",
            licenseType: "MIT",
            url: "https://github.com/sindresorhus/LaunchAtLogin-Modern",
            licenseUrl: "https://github.com/sindresorhus/LaunchAtLogin-Modern/blob/main/license"
        )
    ]

    @State private var showingLicenses = false

    var body: some View {
        VStack {
            Spacer()

            InfoView()

            Button("오픈소스 라이센스") {
                showingLicenses = true
            }
            .sheet(isPresented: $showingLicenses) {
                VStack {
                    HStack {
                        Text("3rd Party Licenses")
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabelColor))
                        Spacer()
                        ToolbarButton(action: { showingLicenses = false }, systemName: "xmark.circle")
                    }
                    .padding(8)

                    ForEach(licenses) { license in
                        VStack {
                            Text(license.name).bold()
                            HStack {
                                Link("Website", destination: URL(string: license.url)!)
                                Text("-")
                                Link(license.licenseType, destination: URL(string: license.licenseUrl)!)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    Spacer().frame(height: 20)
                }
                .frame(width: 200)
            }

            HStack {
                Menu {
                    Button("온보딩 (재시작 필요)") {
                        restartOnboarding()
//                        Alert 구현?
                    }
                    Button("설정 초기화") {
                        resetDefaults()
                    }

                    Button("WebView 초기화") {
                        resetWebView()
                    }
                } label: {
                    Text("초기화")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 80)

                Spacer()

                ToolbarButton(
                    action: { openURL(URL(string: "mailto:afcoo0215@gmail.com")!) },
                    systemName: "envelope"
                )
                ToolbarButton(
                    action: { openURL(URL(string: "https://github.com/Afcoo/shortcut-dictionary")!) },
                    systemName: "icon_github",
                    useSystem: false
                )
//                ToolbarButton(action: showInfo, systemName: "info.circle")
            }
            .padding(.all, 20)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
        }
    }

    // 온보딩 초기화
    func restartOnboarding() {
        UserDefaults.standard.resetKey("hasCompletedOnboarding")
    }

    // 설정 초기화
    func resetDefaults() {
        UserDefaults.standard.resetKeys()

        KeyboardShortcuts.disable(.dictShortcut)
        KeyboardShortcuts.reset(.dictShortcut)

        LaunchAtLogin.isEnabled = false
    }

    // WebView 초기화
    func resetWebView() {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: {
            records in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                // remove callback
            }
        })

        NotificationCenter.default.post(name: .reloadDict, object: "") // 사전 창 새로고침
    }
}

struct InfoView: View {
    let appIcon: NSImage = NSApplication.shared.applicationIconImage

    var body: some View {
        VStack {
            Image(nsImage: appIcon)
                .resizable()
                .frame(width: 100, height: 100)

            Text("단축키 사전").bold()
            Text("버전: \(getAppVersion()) (\(getBuildNumber()))")

            Spacer().frame(height: 10)

            Text("ⓒ 2024. Afcoo. All rights reserved.")
        }
    }

    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }

    func getBuildNumber() -> String {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return buildNumber
        }
        return "Unknown"
    }
}

extension UserDefaults {
    func resetKeys() {
        for item in UserKeys.allCases {
            removeObject(forKey: item.rawValue)
        }
    }

    func resetKey(_ key: String) {
        removeObject(forKey: key)
    }
}
