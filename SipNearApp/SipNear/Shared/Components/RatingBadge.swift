import SwiftUI

struct RatingBadge: View {
    let rating: Double
    var count: Int?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(SipTheme.ColorToken.gold)
            Text(rating, format: .number.precision(.fractionLength(1)))
                .font(.caption.weight(.bold))
                .foregroundStyle(SipTheme.ColorToken.ink)
                .monospacedDigit()
            if let count {
                Text("(\(count.formatted()))")
                    .font(.caption2)
                    .foregroundStyle(SipTheme.ColorToken.muted)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(SipTheme.ColorToken.surfaceSecondary)
        .clipShape(Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        if let count {
            return "Rated \(String(format: "%.1f", rating)) from \(count) ratings"
        }
        return "Rated \(String(format: "%.1f", rating))"
    }
}
