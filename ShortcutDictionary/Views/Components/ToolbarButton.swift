import SwiftUI

struct ToolbarButton: View {
    let action: () -> Void
    let systemName: String
    var useSystem = true
    var scale: Image.Scale = .large

    var body: some View {
        Button(
            action: action,
            label: {
                if useSystem {
                    Image(systemName: systemName)
                        .imageScale(scale)
                        .foregroundColor(Color(.tertiaryLabelColor))
                }
                else {
                    Image(systemName)
                        .renderingMode(.template) // 색 변경 가능하게
                        .resizable()
                        .scaledToFit() // 비율 유지
                        .frame(height: 20)
                        .foregroundColor(Color(.tertiaryLabelColor))
                }
            }
        ).buttonStyle(.plain)
    }
}
