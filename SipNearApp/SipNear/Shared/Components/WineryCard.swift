import SwiftUI

struct WineryCard: View {
    let winery: Winery

    var body: some View {
        HStack(spacing: SipTheme.Spacing.sm) {
            Image(systemName: "wineglass.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(SipTheme.ColorToken.burgundy)
                .frame(width: 46, height: 46)
                .background(SipTheme.ColorToken.surfaceSecondary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(winery.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SipTheme.ColorToken.ink)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    if let meters = winery.distanceMeters {
                        Text(GeoMath.formatDistance(meters))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SipTheme.ColorToken.burgundy)
                            .monospacedDigit()
                    }
                }

                Text(metaLine)
                    .font(.subheadline)
                    .foregroundStyle(SipTheme.ColorToken.muted)
                    .lineLimit(1)

                if let rating = winery.rating {
                    RatingBadge(rating: rating, count: winery.reviewCount)
                        .padding(.top, 2)
                } else {
                    Text(winery.source == .openStreetMap ? "OpenStreetMap" : "Curated pick")
                        .font(.caption)
                        .foregroundStyle(SipTheme.ColorToken.muted)
                        .padding(.top, 2)
                }
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SipTheme.ColorToken.muted)
                .accessibilityHidden(true)
        }
        .padding(SipTheme.Spacing.sm)
        .sipCardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens winery details")
    }

    private var metaLine: String {
        if let address = winery.address, !address.isEmpty {
            return "\(winery.category.title) · \(address)"
        }
        return winery.category.title
    }
}
