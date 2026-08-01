import SwiftUI

struct EasyButton: View {
    let title: String
    var subtitle: String? = nil
    var icon: String = "location.fill"
    var loading: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 52, height: 52)
                    if loading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.forward.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(SipColors.goldSoft)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(
                LinearGradient(
                    colors: [SipColors.burgundy, SipColors.wine],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: SipColors.burgundyDeep.opacity(0.28), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(loading)
    }
}
