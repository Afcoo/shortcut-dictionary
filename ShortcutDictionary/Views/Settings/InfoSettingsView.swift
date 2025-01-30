import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI
import WebKit

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
            .fixedSize(horizontal: false, vertical: true)
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
        for item in SettingKeys.allCases {
            removeObject(forKey: item.rawValue)
        }
    }

    func resetKey(_ key: String) {
        removeObject(forKey: key)
    }
}
