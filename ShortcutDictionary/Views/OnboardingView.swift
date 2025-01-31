import SwiftUI

#Preview {
    OnboardingView()
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemIcon: String
    let title: String
    let content: AnyView
    let height: CGFloat
}

struct OnboardingView: View {
    @AppStorage(SettingKeys.hasCompletedOnboarding.rawValue)
    private var hasCompletedOnboarding = SettingKeys.hasCompletedOnboarding.defaultValue as! Bool

    let maxPage = 2
    @State private var currentPage = 0
    @State private var currentHeight: CGFloat = 120

    let onboardingPages = [
        OnboardingPage(
            systemIcon: "character.book.closed.fill",
            title: "환영합니다!",
            content: AnyView(
                Text("단축키 사전을 사용해볼까요?")
            ),
            height: 260
        ),
        OnboardingPage(
            systemIcon: "keyboard",
            title: "어디서든 단축키로 사전 열기",
            content: AnyView(
                ShortcutSettingsView()
                    .padding(.bottom, -50)
            ),
            height: 360
        ),
        OnboardingPage(
            systemIcon: "checkmark.seal",
            title: "준비 완료!",
            content: AnyView(
                GeneralSettingsView()
                    .padding(.bottom, -50)
            ),
            height: 330
        ),
    ]

    var body: some View {
        VStack {
            // 상단 버튼
            HStack {
                if currentPage > 0 {
                    ToolbarButton(action: prev, systemName: "chevron.backward")
                }
                Spacer()
                if currentPage != maxPage {
                    ToolbarButton(action: { NSApplication.shared.terminate(self) }, systemName: "xmark.circle")
                }
            }
            .padding(8)

            Image(systemName: onboardingPages[currentPage].systemIcon)
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Spacer().frame(height: 10)

            Text(onboardingPages[currentPage].title)
                .font(.title)
                .bold()

            Spacer().frame(height: 10)

            onboardingPages[currentPage].content

            Spacer()

            // 하단 버튼
            Button(currentPage < maxPage ? "다음" : "시작하기", action: next)
                .buttonStyle(NextButton())
                .padding(.bottom, 20)
        }
        .frame(width: 400)
        .background { ColoredBackground().ignoresSafeArea() }
    }

    func prev() {
        withAnimation(.spring) {
            currentPage -= 1
        }
        WindowManager.shared.resizeOnboarding(width: 400, height: onboardingPages[currentPage].height)
    }

    func next() {
        if currentPage < 2 {
            withAnimation(.spring) {
                currentPage += 1
                WindowManager.shared.resizeOnboarding(width: 400, height: onboardingPages[currentPage].height)
            }
        }
        else {
            hasCompletedOnboarding = true
            WindowManager.shared.closeOnboarding()
            WindowManager.shared.showDict()
        }
    }
}

struct NextButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(0)
            .frame(width: 60, height: 25)
            .background(.blue)
            .font(.caption2)
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}
