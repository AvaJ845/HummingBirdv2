import SwiftUI

struct WineCard: View {
    let wine: Wine
    var saved: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: wine.colorHex))
                    .frame(width: 54, height: 96)
                Text(String(wine.type.rawValue.prefix(1)).uppercased())
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.bottom, 10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(wine.winery.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(SipColors.burgundySoft)
                    .tracking(0.6)
                Text(titleText)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(SipColors.ink)
                    .lineLimit(2)
                Text("\(wine.region) · \(wine.country)")
                    .font(.subheadline)
                    .foregroundStyle(SipColors.muted)
                    .lineLimit(1)

                HStack {
                    RatingBadge(rating: wine.rating, count: wine.ratingsCount)
                    Spacer()
                    Text("~$\(wine.priceEstimate)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(SipColors.inkSoft)
                }
                .padding(.top, 6)
            }

            if saved {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(SipColors.wine)
            }
        }
        .padding(14)
        .background(SipColors.parchment)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(SipColors.border, lineWidth: 1)
        )
    }

    private var titleText: String {
        if let vintage = wine.vintage {
            return "\(wine.name) \(vintage)"
        }
        return wine.name
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
