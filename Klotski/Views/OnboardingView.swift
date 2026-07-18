import SwiftUI

/// Shown once, automatically, on first launch — introduces the puzzle before
/// dropping the player into the Home screen's puzzle list. Re-reachable anytime
/// afterward via the "Rules"/"How to Play" button on Home, which covers the same
/// ground for players who skip this or want a refresher.
struct OnboardingView: View {
    let onFinish: () -> Void
    @State private var page = 0

    private let pages: [(emoji: String, titleKey: String, bodyKey: String)] = [
        ("👋", "onboard.welcome.title", "onboard.welcome.body"),
        ("🎯", "onboard.goal.title", "onboard.goal.body"),
        ("👆", "onboard.moves.title", "onboard.moves.body"),
        ("💡", "onboard.hint.title", "onboard.hint.body"),
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.15, green: 0.05, blue: 0.05), .black],
                            startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(L("onboard.skip")) { onFinish() }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding()
                }

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { i in
                        VStack(spacing: 22) {
                            Spacer()
                            if i == 0 {
                                AppEmblem(size: 84)
                            } else {
                                Text(pages[i].emoji).font(.system(size: 72))
                            }
                            Text(L(pages[i].titleKey))
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            Text(L(pages[i].bodyKey))
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 36)
                            Spacer()
                            Spacer()
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                Button {
                    if page < pages.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        onFinish()
                    }
                } label: {
                    Text(page < pages.count - 1 ? L("onboard.next") : L("onboard.start"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.78, green: 0.12, blue: 0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview { OnboardingView(onFinish: {}) }
