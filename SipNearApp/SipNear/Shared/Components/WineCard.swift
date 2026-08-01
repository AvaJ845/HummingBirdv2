import SwiftUI

struct WineCard: View {
    let wine: Wine
    var isSaved = false

    var body: some View {
        HStack(alignment: .top, spacing: SipTheme.Spacing.sm) {
            bottleArt

            VStack(alignment: .leading, spacing: 4) {
                Text(wine.winery.uppercased())
                    .font(.caption2.weight(.semibold))
                    .tracking(0.7)
                    .foregroundStyle(SipTheme.ColorToken.burgundy)
                Text(wine.displayName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(SipTheme.ColorToken.ink)
                    .lineLimit(2)
                Text("\(wine.region) · \(wine.country)")
                    .font(.subheadline)
                    .foregroundStyle(SipTheme.ColorToken.muted)
                    .lineLimit(1)

                HStack {
                    RatingBadge(rating: wine.rating, count: wine.ratingsCount)
                    Spacer(minLength: 8)
                    Text(wine.priceEstimate, format: .currency(code: "USD").precision(.fractionLength(0)))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(SipTheme.ColorToken.inkSecondary)
                        .accessibilityLabel("About \(wine.priceEstimate) dollars")
                }
                .padding(.top, 6)
            }

            if isSaved {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(SipTheme.ColorToken.wine)
                    .accessibilityLabel("Saved")
            }
        }
        .padding(SipTheme.Spacing.sm)
        .sipCardStyle()
        .accessibilityElement(children: .combine)
    }

    private var bottleArt: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(wine.swatch.gradient)
                .frame(width: 54, height: 96)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.white.opacity(0.25))
                        .frame(width: 16, height: 12)
                        .offset(y: -5)
                }
            Text(String(wine.type.title.prefix(1)))
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
                .padding(8)
                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(.bottom, 10)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    WineCard(wine: WineCatalog.all[0], isSaved: true)
        .padding()
        .sipCanvas()
}
