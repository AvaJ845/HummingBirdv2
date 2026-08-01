import SwiftUI

struct WineDetailView: View {
    @EnvironmentObject private var appModel: AppModel
    let wine: Wine

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [Color(hex: wine.colorHex), SipColors.burgundyDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 260)

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(hex: wine.colorHex))
                        .frame(width: 90, height: 150)
                        .overlay {
                            Text(wine.type.rawValue.uppercased())
                                .font(.caption.weight(.heavy))
                                .tracking(1)
                                .foregroundStyle(.white)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                                .padding(.bottom, 16)
                        }
                        .padding(.bottom, 28)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(wine.winery.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(SipColors.burgundySoft)

                    Text(titleText)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(SipColors.ink)

                    Text("\(wine.region), \(wine.country)")
                        .foregroundStyle(SipColors.muted)

                    HStack(spacing: 8) {
                        RatingBadge(rating: wine.rating, count: wine.ratingsCount)
                        pill(label: "Est. price", value: "$\(wine.priceEstimate)")
                        if let alcohol = wine.alcohol {
                            pill(label: "ABV", value: String(format: "%.1f%%", alcohol))
                        }
                    }
                    .padding(.top, 6)

                    Text("Why you’ll like it")
                        .font(.title3.weight(.heavy))
                        .padding(.top, 12)
                    Text(wine.description)
                        .foregroundStyle(SipColors.inkSoft)

                    Text("Tasting notes")
                        .font(.title3.weight(.heavy))
                        .padding(.top, 8)
                    FlowNotes(notes: wine.tastingNotes)

                    Text("Grapes")
                        .font(.title3.weight(.heavy))
                        .padding(.top, 8)
                    Text(wine.grapes.joined(separator: " · "))
                        .foregroundStyle(SipColors.inkSoft)

                    Button {
                        appModel.toggleSaved(wine: wine)
                    } label: {
                        Label(
                            appModel.isSaved(wine.id) ? "Saved on this device" : "Save with one tap",
                            systemImage: appModel.isSaved(wine.id) ? "heart.fill" : "heart"
                        )
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(SipColors.burgundy)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 20)
                }
                .padding(20)
                .background(SipColors.cream)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .offset(y: -16)
            }
        }
        .background(SipColors.cream.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.toggleSaved(wine: wine)
                } label: {
                    Image(systemName: appModel.isSaved(wine.id) ? "heart.fill" : "heart")
                        .foregroundStyle(appModel.isSaved(wine.id) ? SipColors.gold : SipColors.ink)
                }
            }
        }
    }

    private var titleText: String {
        if let vintage = wine.vintage {
            return "\(wine.name) \(vintage)"
        }
        return wine.name
    }

    private func pill(label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(SipColors.muted)
            Text(value)
                .font(.caption.weight(.heavy))
                .foregroundStyle(SipColors.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(SipColors.parchment)
        .overlay(Capsule().stroke(SipColors.border, lineWidth: 1))
        .clipShape(Capsule())
    }
}

private struct FlowNotes: View {
    let notes: [String]

    var body: some View {
        FlexibleTags(notes)
    }
}

/// Simple wrapping tag layout without third-party deps.
private struct FlexibleTags: View {
    let tags: [String]
    init(_ tags: [String]) { self.tags = tags }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { tag in
                        Text(tag)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SipColors.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(SipColors.creamDark)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        // Keep layout predictable: 3 tags per row
        stride(from: 0, to: tags.count, by: 3).map { start in
            Array(tags[start..<min(start + 3, tags.count)])
        }
    }
}
