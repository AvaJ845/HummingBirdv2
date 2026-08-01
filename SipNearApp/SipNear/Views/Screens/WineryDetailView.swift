import SwiftUI

struct WineryDetailView: View {
    @EnvironmentObject private var appModel: AppModel
    let wineryID: String

    private var winery: Winery? {
        appModel.winery(id: wineryID)
    }

    var body: some View {
        Group {
            if let winery {
                content(winery)
            } else {
                Text("Winery not found.")
                    .foregroundStyle(SipColors.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(SipColors.cream)
            }
        }
        .navigationTitle("Winery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ winery: Winery) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 10) {
                    Image(systemName: "wineglass.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(SipColors.burgundy)
                        .frame(width: 64, height: 64)
                        .background(SipColors.creamDark)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                    Text(winery.name)
                        .font(.system(size: 26, weight: .heavy))
                        .multilineTextAlignment(.center)

                    Text(meta(winery))
                        .font(.subheadline)
                        .foregroundStyle(SipColors.muted)
                        .multilineTextAlignment(.center)

                    if let rating = winery.rating {
                        RatingBadge(rating: rating, count: winery.reviewCount)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(22)
                .background(SipColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(SipColors.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                section("About", text: aboutText(winery))

                if let address = winery.address {
                    section("Address", text: address)
                }
                if let hours = winery.hours {
                    section("Hours", text: hours)
                }

                VStack(spacing: 10) {
                    Link(destination: directionsURL(winery)) {
                        Label("Directions", systemImage: "location.north.line.fill")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(SipColors.burgundy)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    if let website = winery.website, let url = URL(string: website) {
                        Link(destination: url) {
                            secondaryButton(title: "Website", icon: "globe")
                        }
                    }

                    if let phone = winery.phone,
                       let url = URL(string: "tel:\(phone.filter { $0.isNumber || $0 == "+" })") {
                        Link(destination: url) {
                            secondaryButton(title: "Call", icon: "phone")
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
        .background(SipColors.cream.ignoresSafeArea())
    }

    private func meta(_ winery: Winery) -> String {
        if let meters = winery.distanceMeters {
            return "\(winery.category.label) · \(Geo.formatDistance(meters)) away"
        }
        return winery.category.label
    }

    private func aboutText(_ winery: Winery) -> String {
        if let description = winery.description, !description.isEmpty {
            return description
        }
        if winery.source == .osm {
            return "Pulled live from OpenStreetMap near your location. Tap directions for an easy route."
        }
        return "A curated wine-country highlight shown when live map data is sparse nearby."
    }

    private func section(_ title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.heavy))
            Text(text)
                .foregroundStyle(SipColors.inkSoft)
        }
    }

    private func directionsURL(_ winery: Winery) -> URL {
        URL(string: "https://maps.apple.com/?daddr=\(winery.latitude),\(winery.longitude)")!
    }

    private func secondaryButton(title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.headline.weight(.bold))
            .foregroundStyle(SipColors.burgundy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(SipColors.parchment)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(SipColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
