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

    @State private var isReady = false

    @State private var titleBarHeight: CGFloat = 0.0

    @State private var currentPage = 0

    @State private var onboardingPages = [
        OnboardingPage(
            systemIcon: "character.book.closed.fill",
            title: "환영합니다!",
            content: AnyView(
                VStack {
                    Text("단축키 사전을 사용해볼까요?")
                        .font(.headline)
                    Spacer().frame(height: 28)
                }
                .fixedSize()
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
        VStack {
            // 상단 버튼
            HStack {
                if currentPage > 0 {
                    ToolbarButton(action: prev, systemName: "chevron.backward")
                }
                Spacer()
                if currentPage != onboardingPages.endIndex {
                    ToolbarButton(action: { NSApplication.shared.terminate(self) }, systemName: "xmark.circle")
                }
            }
            .padding(8)

            OnboardingViewDetails(page: onboardingPages[currentPage])

            // 하단 버튼
            Button(currentPage < onboardingPages.endIndex ? "다음" : "시작하기", action: next)
                .buttonStyle(NextButton())
                .padding(.bottom, -titleBarHeight + 22)
        }
        .ignoresSafeArea()
        .frame(width: 400)
        .background { ColoredBackground().ignoresSafeArea() }
        .opacity(isReady ? 1 : 0)
        .getTitleBarHeight { height in
            self.titleBarHeight = height

            withAnimation {
                self.isReady = true
            }
        }
        .getViewSize { size in print(size.height) }
    }

    func prev() {
        changePage(-1)
    }

    func next() {
        if currentPage < onboardingPages.endIndex {
            changePage(1)
        }
        else {
            end()
        }
    }

    func changePage(_ num: Int) {
        currentPage += num

        isReady = false
        withAnimation(.smooth(duration: 1.5)) {
            self.isReady = true
        }
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
        VStack {
            Image(systemName: page.systemIcon)
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Spacer().frame(height: 20)

            Text(page.title)
                .font(.largeTitle)
                .bold()

            Spacer().frame(height: 14)

            page.content
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
