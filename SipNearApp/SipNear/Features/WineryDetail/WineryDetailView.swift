import SwiftUI

struct WineryDetailView: View {
    @Environment(AppModel.self) private var appModel
    let wineryID: String

    private var winery: Winery? { appModel.winery(id: wineryID) }

    var body: some View {
        Group {
            if let winery {
                content(winery)
            } else {
                ContentUnavailableView(
                    "Winery unavailable",
                    systemImage: "wineglass",
                    description: Text("This place is no longer in your nearby results.")
                )
            }
        }
        .navigationTitle("Winery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ winery: Winery) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SipTheme.Spacing.md) {
                VStack(spacing: 10) {
                    Image(systemName: "wineglass.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(SipTheme.ColorToken.burgundy)
                        .frame(width: 64, height: 64)
                        .background(SipTheme.ColorToken.surfaceSecondary, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                    Text(winery.name)
                        .font(.title.weight(.heavy))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(SipTheme.ColorToken.ink)

                    Text(meta(winery))
                        .font(.subheadline)
                        .foregroundStyle(SipTheme.ColorToken.muted)
                        .multilineTextAlignment(.center)

                    if let rating = winery.rating {
                        RatingBadge(rating: rating, count: winery.reviewCount)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(SipTheme.Spacing.lg)
                .sipCardStyle()

                detailGroup("About", text: about(winery))
                if let address = winery.address {
                    detailGroup("Address", text: address)
                }
                if let hours = winery.hours {
                    detailGroup("Hours", text: hours)
                }

                VStack(spacing: 10) {
                    Link(destination: directionsURL(winery)) {
                        Label("Directions", systemImage: "location.north.line.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(SipTheme.ColorToken.burgundy, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .simultaneousGesture(TapGesture().onEnded { Haptics.impact(.light) })

                    if let website = winery.website, let url = URL(string: website) {
                        Link(destination: url) {
                            secondaryLabel("Website", symbol: "globe")
                        }
                    }

                    if let phone = winery.phone {
                        let digits = phone.filter { $0.isNumber || $0 == "+" }
                        if let url = URL(string: "tel:\(digits)") {
                            Link(destination: url) {
                                secondaryLabel("Call", symbol: "phone")
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(SipTheme.Spacing.lg)
        }
        .sipCanvas()
    }

    private func meta(_ winery: Winery) -> String {
        if let meters = winery.distanceMeters {
            return "\(winery.category.title) · \(GeoMath.formatDistance(meters)) away"
        }
        return winery.category.title
    }

    private func about(_ winery: Winery) -> String {
        if let summary = winery.summary, !summary.isEmpty { return summary }
        if winery.source == .openStreetMap {
            return "Pulled live from OpenStreetMap near your location. Tap Directions for an Apple Maps route."
        }
        return "A curated wine-country highlight shown when live map data is sparse nearby."
    }

    private func detailGroup(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.heavy))
                .foregroundStyle(SipTheme.ColorToken.ink)
            Text(text)
                .foregroundStyle(SipTheme.ColorToken.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func directionsURL(_ winery: Winery) -> URL {
        URL(string: "https://maps.apple.com/?daddr=\(winery.latitude),\(winery.longitude)")!
    }

    private func secondaryLabel(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.headline.weight(.bold))
            .foregroundStyle(SipTheme.ColorToken.burgundy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(SipTheme.ColorToken.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(SipTheme.ColorToken.border, lineWidth: 1)
            )
    }
}
