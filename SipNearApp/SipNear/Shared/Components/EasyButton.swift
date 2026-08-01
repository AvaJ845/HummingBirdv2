import SwiftUI

struct EasyButton: View {
    let title: String
    var subtitle: String?
    var systemImage: String = "location.north.line.fill"
    var isLoading = false
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.impact(.medium)
            action()
        } label: {
            HStack(spacing: SipTheme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.14))
                        .frame(width: 52, height: 52)
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: systemImage)
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.84))
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.forward.circle.fill")
                    .font(.title2)
                    .foregroundStyle(SipTheme.ColorToken.goldSoft)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, SipTheme.Spacing.md)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [SipTheme.ColorToken.burgundy, SipTheme.ColorToken.wine],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: SipTheme.Radius.button, style: .continuous))
            .shadow(color: SipTheme.ColorToken.burgundyDeep.opacity(0.28), radius: 18, y: 10)
        }
        .buttonStyle(SipPressableButtonStyle())
        .disabled(isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle ?? "Finds wineries around your current location")
    }
}

struct SipPressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.96 : 1)
            .animation(SipTheme.Motion.snappy, value: configuration.isPressed)
    }
}

#Preview {
    EasyButton(title: "Find Wineries Near Me", subtitle: "No account needed") {}
        .padding()
        .sipCanvas()
}
