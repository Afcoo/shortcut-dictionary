import SwiftUI

#Preview {
    OnboardingView()
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemIcon: String
    let title: String
    let content: AnyView
}

struct OnboardingView: View {
    @AppStorage(SettingKeys.hasCompletedOnboarding.rawValue)
    private var hasCompletedOnboarding = SettingKeys.hasCompletedOnboarding.defaultValue as! Bool

    @AppStorage(SettingKeys.isLiquidGlassEnabled.rawValue)
    private var isLiquidGlassEnabled = SettingKeys.isLiquidGlassEnabled.defaultValue as! Bool

    @State private var currentPage = 0

    @State private var onboardingPages = [
        OnboardingPage(
            systemIcon: "character.book.closed.fill",
            title: "환영합니다!",
            content: AnyView(
                Text("단축키 사전을 사용해볼까요?")
                    .font(.headline)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
            )
        ),
        OnboardingPage(
            systemIcon: "keyboard",
            title: "어디서든 단축키로 사전 열기",
            content: AnyView(ShortcutSettingsView())
        ),
        OnboardingPage(
            systemIcon: "checkmark.seal",
            title: "준비 완료!",
            content: AnyView(GeneralSettingsView())
        ),
    ]

    var body: some View {
        VStack(spacing: 0.0) {
            // 상단 버튼
            HStack {
                let _action = currentPage > 0
                    ? prev
                    : { NSApplication.shared.terminate(self) }

                let _systemName = currentPage > 0
                    ? "chevron.backward"
                    : "xmark"

                if #available(macOS 26.0, *), isLiquidGlassEnabled {
                    ToolbarButtonV2(action: _action, systemName: _systemName)
                }
                else {
                    ToolbarButton(action: _action, systemName: _systemName)
                }

                Spacer()

                let nextButton =
                    Button(currentPage < onboardingPages.count - 1 ? "다음" : "시작하기", action: next)

                if #available(macOS 26.0, *), isLiquidGlassEnabled {
                    nextButton
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.extraLarge)
                }
                else {
                    nextButton
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
            }
            .padding(8)

            OnboardingViewDetails(page: onboardingPages[currentPage])
        }
        .frame(width: 400)
        .setViewColoredBackground()
        .clipShape(RoundedRectangle(cornerRadius: isLiquidGlassEnabled ? 26.0 : 15.0))
    }

    func prev() {
        changePage(-1)
    }

    func next() {
        if currentPage < onboardingPages.count - 1 {
            changePage(1)
        }
        else {
            end()
        }
    }

    func changePage(_ num: Int) {
        currentPage += num
    }

    func end() {
        hasCompletedOnboarding = true
        WindowManager.shared.closeOnboarding()
        WindowManager.shared.showDict()
    }
}

struct OnboardingViewDetails: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0.0) {
            Image(systemName: page.systemIcon)
                .font(.system(size: 70))
                .foregroundColor(.accentColor)

            Spacer().frame(height: 20)

            Text(page.title)
                .font(.largeTitle)
                .bold()

            page.content
                .frame(width: 400)
                .fixedSize()
        }
    }
}

struct NextButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(0)
            .frame(width: 70, height: 32)
            .background(.blue)
            .font(.callout)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

#Preview {
    OnboardingView()
}
