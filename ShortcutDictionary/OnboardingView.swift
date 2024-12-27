import SwiftUI

#Preview {
    OnboardingView()
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false

    @State private var currentPage = 0
    @State private var currentHeight: CGFloat = 120

    let pageHeights: [CGFloat] = [
        100,
        220,
        190
    ]

    var body: some View {
        VStack {
            // 상단 버튼
            HStack {
                if currentPage > 0 {
                    ToolbarButton(action: { currentPage -= 1 }, systemName: "chevron.backward")
                }
                Spacer()
                ToolbarButton(action: { NSApplication.shared.terminate(self) }, systemName: "xmark.circle")
            }
            .padding(8)

            // 온보딩 페이지 탭 뷰
            TabView(selection: $currentPage) {
                // 첫 번째 페이지
                VStack {
                    Image(systemName: "character.book.closed.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Spacer().frame(height: 10)

                    Text("환영합니다!")
                        .font(.title)
                        .bold()

                    Spacer().frame(height: 10)

                    Text("단축키 사전을 사용해볼까요?")

                    Spacer()
                }
                .tag(0)
                .toolbar(.hidden, for: .automatic)
                .transition(.opacity)

                // 두 번째 페이지
                VStack {
                    Image(systemName: "keyboard")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Spacer().frame(height: 10)

                    Text("어디서든 단축키로 사전 열기")
                        .font(.title2)
                        .bold()

                    Spacer().frame(height: 10)

                    ShortcutSettingsView()
                        .padding(.bottom, -50)
                }
                .tag(1)
                .toolbar(.hidden, for: .automatic)
                .transition(.opacity)

                // 세 번째 페이지
                VStack {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Spacer().frame(height: 10)

                    Text("준비 완료!")
                        .font(.title)
                        .bold()

                    Spacer().frame(height: 10)

                    GeneralSettingsView()

                        .padding(.bottom, -50)
                }
                .tag(2)
                .toolbar(.hidden, for: .automatic)
                .transition(.opacity)
            }
            .onChange(of: currentPage) { newPage in
                withAnimation(.bouncy) {
                    currentHeight = pageHeights[newPage]
                }
//                currentHeight = pageHeights[newPage]
                WindowManager.shared.resizeOnboarding(width: 400, height: pageHeights[newPage] + 140)
            }
            .frame(width: 400)
            .frame(height: currentHeight)

            Spacer()
            // 하단 버튼
            if currentPage < 2 {
                Button("다음") {
                    currentPage += 1
                }.buttonStyle(NextButton())
                    .padding(.bottom, 20)
            }
            else {
                Button("시작하기") {
                    WindowManager.shared.closeOnboarding()
                    WindowManager.shared.show()
                    hasCompletedOnboarding = true
                }
                .buttonStyle(NextButton())
                .padding(.bottom, 20)
            }
        }
        .background(
            VisualEffectView(
                material: NSVisualEffectView.Material.hudWindow,
                blendingMode: NSVisualEffectView.BlendingMode.behindWindow
            )
            .ignoresSafeArea()
        )
        .ignoresSafeArea()
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
