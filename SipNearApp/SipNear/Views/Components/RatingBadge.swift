import SwiftUI

struct RatingBadge: View {
    let rating: Double
    var count: Int? = nil

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundStyle(SipColors.gold)
            Text(String(format: "%.1f", rating))
                .font(.caption.weight(.bold))
                .foregroundStyle(SipColors.ink)
            if let count {
                Text("(\(count.formatted()))")
                    .font(.caption2)
                    .foregroundStyle(SipColors.muted)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(SipColors.creamDark)
        .clipShape(Capsule())
    }
}
