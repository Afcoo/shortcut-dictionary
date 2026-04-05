import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI
import WebKit

struct InfoSettingsView: View {
    @Environment(\.openURL) var openURL

    @State private var showingLicenses = false

    var body: some View {
        VStack {
            Spacer()

            InfoView()

            Button("오픈소스 라이센스") {
                showingLicenses = true
            }
            .sheet(isPresented: $showingLicenses) {
                LicenseSheet(isPresented: $showingLicenses)
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
        }
    }

    /// 온보딩 초기화
    func restartOnboarding() {
        UserDefaults.standard.resetKey(.hasCompletedOnboarding)
    }

    /// 설정 초기화
    func resetDefaults() {
        UserDefaults.standard.resetKeys()

        KeyboardShortcuts.disable(.dictShortcut)
        KeyboardShortcuts.reset(.dictShortcut)
        KeyboardShortcuts.disable(.chatShortcut)
        KeyboardShortcuts.reset(.chatShortcut)

        LaunchAtLogin.isEnabled = false
    }

    /// WebView 초기화
    func resetWebView() {
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()

        dataStore.removeData(ofTypes: dataTypes, modifiedSince: .distantPast) {
            DispatchQueue.main.async {
                WebViewManager.shared.reloadAllControllers()
            }
        }
    }
}

struct InfoView: View {
    let appIcon: NSImage = NSApplication.shared.applicationIconImage

    var body: some View {
        VStack {
            Spacer()

            Image(nsImage: appIcon)
                .resizable()
                .frame(width: 100, height: 100)

            Text("단축키 사전").bold()
            Text("버전: \(getAppVersion()) (\(getBuildNumber()))")

            Spacer().frame(height: 10)

            Text("ⓒ 2024-2026. Afcoo. All rights reserved.")

            Spacer()
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
