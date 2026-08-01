import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appModel: AppModel
    var onContinue: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SipColors.burgundyDeep, SipColors.burgundy, SipColors.wine],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Label("No account · One tap", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SipColors.goldSoft)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.12))
                    .clipShape(Capsule())
                    .padding(.top, 12)

                Spacer(minLength: 24)

                Text("SIPNEAR")
                    .font(.caption.weight(.heavy))
                    .tracking(3)
                    .foregroundStyle(SipColors.goldSoft)

                Text("Wine discovery,\nmade easy.")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.top, 10)

                Text("Find wineries around you, browse top-rated bottles, and skip the signup wall. Vivino vibes — easier buttons.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.top, 12)

                VStack(alignment: .leading, spacing: 12) {
                    feature("location.fill", "Pull nearby wineries from your location")
                    feature("wineglass.fill", "Browse ratings & tasting notes instantly")
                    feature("heart.fill", "Save favorites on-device — no login")
                }
                .padding(.vertical, 28)

                Spacer()

                EasyButton(
                    title: "Find Wineries Near Me",
                    subtitle: "Uses your location · no account needed",
                    icon: "location.north.line.fill",
                    loading: appModel.isBusy
                ) {
                    Task {
                        await appModel.findNearby()
                        onContinue()
                    }
                }

                Button("Browse wines first") {
                    onContinue()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.78))
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
        }
    }

    private func feature(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(SipColors.goldSoft)
                .frame(width: 34, height: 34)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(text)
                .foregroundStyle(.white.opacity(0.9))
                .font(.subheadline)
        }
    }
}
