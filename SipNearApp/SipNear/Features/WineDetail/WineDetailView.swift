import SwiftUI

struct WineDetailView: View {
    @Environment(AppModel.self) private var appModel
    let wine: Wine

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero

                VStack(alignment: .leading, spacing: 12) {
                    Text(wine.winery.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(SipTheme.ColorToken.burgundy)

                    Text(wine.displayName)
                        .font(.title.weight(.heavy))
                        .foregroundStyle(SipTheme.ColorToken.ink)

                    Text("\(wine.region), \(wine.country)")
                        .foregroundStyle(SipTheme.ColorToken.muted)

                    statsRow

                    group("Why you’ll like it") {
                        Text(wine.blurb)
                            .foregroundStyle(SipTheme.ColorToken.inkSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    group("Tasting notes") {
                        FlowLayout(spacing: 8) {
                            ForEach(wine.tastingNotes, id: \.self) { note in
                                Text(note)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SipTheme.ColorToken.ink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(SipTheme.ColorToken.surfaceSecondary, in: Capsule())
                            }
                        }
                    }

                    group("Grapes") {
                        Text(wine.grapes.joined(separator: " · "))
                            .foregroundStyle(SipTheme.ColorToken.inkSecondary)
                    }

                    Button {
                        appModel.toggleSaved(wine)
                    } label: {
                        Label(
                            appModel.isSaved(wine.id) ? "Saved on this iPhone" : "Save with one tap",
                            systemImage: appModel.isSaved(wine.id) ? "heart.fill" : "heart"
                        )
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(SipTheme.ColorToken.burgundy, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                    .accessibilityHint("Saves locally. No account required.")
                }
                .padding(SipTheme.Spacing.lg)
                .background(SipTheme.ColorToken.canvas)
                .clipShape(RoundedRectangle(cornerRadius: SipTheme.Radius.panel, style: .continuous))
                .offset(y: -18)
            }
        }
        .sipCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appModel.toggleSaved(wine)
                } label: {
                    Image(systemName: appModel.isSaved(wine.id) ? "heart.fill" : "heart")
                        .symbolEffect(.bounce, value: appModel.isSaved(wine.id))
                        .foregroundStyle(appModel.isSaved(wine.id) ? SipTheme.ColorToken.gold : SipTheme.ColorToken.ink)
                }
                .accessibilityLabel(appModel.isSaved(wine.id) ? "Remove from saved" : "Save wine")
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [wine.swatch, SipTheme.ColorToken.burgundyDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 260)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(wine.swatch.gradient)
                .frame(width: 90, height: 150)
                .overlay {
                    Text(wine.type.title.uppercased())
                        .font(.caption.weight(.heavy))
                        .tracking(1)
                        .foregroundStyle(.white)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 16)
                }
                .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
                .padding(.bottom, 28)
                .accessibilityHidden(true)
        }
    }

    private var statsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                RatingBadge(rating: wine.rating, count: wine.ratingsCount)
                pill("Est. price", wine.priceEstimate.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                if let alcohol = wine.alcohol {
                    pill("ABV", String(format: "%.1f%%", alcohol))
                }
            }
        }
    }

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.heavy))
                .foregroundStyle(SipTheme.ColorToken.ink)
            content()
        }
        .padding(.top, 8)
    }

    private func pill(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(SipTheme.ColorToken.muted)
            Text(value)
                .font(.caption.weight(.heavy))
                .foregroundStyle(SipTheme.ColorToken.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(SipTheme.ColorToken.surface, in: Capsule())
        .overlay(Capsule().stroke(SipTheme.ColorToken.border, lineWidth: 1))
    }
}

/// Lightweight wrapping layout for tasting-note chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var height: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            height = y + rowHeight
        }
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
