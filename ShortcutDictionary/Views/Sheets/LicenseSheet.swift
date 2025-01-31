import SwiftUI

struct LicenseSheet: View {
    @Binding var isPresented: Bool

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

    var body: some View {
        VStack {
            HStack {
                Text("3rd Party Licenses")
                    .font(.caption)
                    .foregroundColor(Color(.tertiaryLabelColor))
                Spacer()
                ToolbarButton(action: { isPresented = false }, systemName: "xmark.circle")
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
}
