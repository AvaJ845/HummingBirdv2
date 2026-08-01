import SwiftUI

struct WelcomeView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    SipTheme.ColorToken.burgundyDeep,
                    SipTheme.ColorToken.burgundy,
                    SipTheme.ColorToken.wine
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Label("No account · One tap", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SipTheme.ColorToken.goldSoft)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.12), in: Capsule())
                    .padding(.top, 8)

                Spacer(minLength: 20)

                Text("SIPNEAR")
                    .font(.caption.weight(.heavy))
                    .tracking(3)
                    .foregroundStyle(SipTheme.ColorToken.goldSoft)

                Text("Wine discovery,\nmade easy.")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.top, 10)
                    .minimumScaleFactor(0.85)

                Text("Find wineries around you, browse bottles worth drinking, and skip the signup wall.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.84))
                    .padding(.top, 12)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 12) {
                    featureRow("location.fill", "Pull nearby wineries from your location")
                    featureRow("wineglass.fill", "Browse ratings and tasting notes instantly")
                    featureRow("heart.fill", "Save favorites on this iPhone — no login")
                }
                .padding(.vertical, 28)

                Spacer()

                EasyButton(
                    title: "Find Wineries Near Me",
                    subtitle: "Uses your location · no account needed",
                    isLoading: appModel.isBusy
                ) {
                    Task {
                        await appModel.findNearby()
                        appModel.completeWelcome()
                    }
                }

                Button("Browse wines first") {
                    Haptics.selection()
                    appModel.completeWelcome()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 6)
            }
            .padding(.horizontal, SipTheme.Spacing.lg)
        }
        .preferredColorScheme(.dark)
    }

    private func featureRow(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(SipTheme.ColorToken.goldSoft)
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WelcomeView()
        .environment(AppModel())
}
