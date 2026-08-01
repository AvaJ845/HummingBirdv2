import SwiftUI

struct WineryCard: View {
    let winery: Winery

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SipColors.creamDark)
                    .frame(width: 46, height: 46)
                Image(systemName: "wineglass.fill")
                    .foregroundStyle(SipColors.burgundy)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(winery.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SipColors.ink)
                        .lineLimit(1)
                    Spacer()
                    if let meters = winery.distanceMeters {
                        Text(Geo.formatDistance(meters))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SipColors.burgundy)
                    }
                }

                Text(metaLine)
                    .font(.subheadline)
                    .foregroundStyle(SipColors.muted)
                    .lineLimit(1)

                if let rating = winery.rating {
                    RatingBadge(rating: rating, count: winery.reviewCount)
                        .padding(.top, 2)
                } else {
                    Text(winery.source == .osm ? "OpenStreetMap" : "Curated pick")
                        .font(.caption)
                        .foregroundStyle(SipColors.muted)
                        .padding(.top, 2)
                }
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(SipColors.muted)
        }
        .padding(14)
        .background(SipColors.parchment)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(SipColors.border, lineWidth: 1)
        )
    }

    private var metaLine: String {
        if let address = winery.address, !address.isEmpty {
            return "\(winery.category.label) · \(address)"
        }
        return winery.category.label
    }
}
