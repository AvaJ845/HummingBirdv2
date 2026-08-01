import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel
    @Binding var selectedTab: MainTab
    @Binding var discoverFilter: WineType?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    Text("One easy button. No account. Wineries around you + wines worth drinking.")
                        .font(.subheadline)
                        .foregroundStyle(SipColors.inkSoft)

                    EasyButton(
                        title: appModel.wineries.isEmpty ? "Find Wineries Near Me" : "Refresh Nearby Wineries",
                        subtitle: easySubtitle,
                        icon: "location.north.line.fill",
                        loading: appModel.isBusy
                    ) {
                        Task { await appModel.findNearby() }
                    }

                    quickFilters

                    nearbySection
                    topWinesSection
                }
                .padding(20)
            }
            .background(SipColors.cream.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var easySubtitle: String {
        if appModel.coords == nil {
            return "Pull your location · instant results"
        }
        if appModel.usingFallbackLocation {
            return "Using demo wine country · tap to try your location"
        }
        return appModel.locationLabel
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good sipping")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SipColors.muted)
                Text("SipNear")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundStyle(SipColors.ink)
            }
            Spacer()
            NavigationLink {
                SavedView()
            } label: {
                Label("Saved", systemImage: "heart.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(SipColors.inkSoft)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(SipColors.parchment)
                    .overlay(
                        Capsule().stroke(SipColors.border, lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }
        }
    }

    private var quickFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([
                    (WineType.red, "wineglass.fill", "Reds"),
                    (.white, "drop.fill", "Whites"),
                    (.sparkling, "sparkles", "Bubbles"),
                    (.rose, "leaf.fill", "Rosé")
                ], id: \.2) { type, icon, label in
                    Button {
                        discoverFilter = type
                        selectedTab = .discover
                    } label: {
                        Label(label, systemImage: icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SipColors.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(SipColors.parchment)
                            .overlay(Capsule().stroke(SipColors.border, lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Nearby wineries",
                subtitle: appModel.statusMessage
                    ?? (appModel.wineries.isEmpty
                        ? "Tap the easy button to pull locations"
                        : "\(appModel.wineries.count) spots found"),
                action: "Map"
            ) {
                selectedTab = .nearby
            }

            if appModel.isBusy && appModel.wineries.isEmpty {
                VStack(spacing: 10) {
                    ProgressView()
                    Text("Finding wineries around you…")
                        .foregroundStyle(SipColors.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(cardBackground)
            } else if appModel.wineries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "map")
                        .foregroundStyle(SipColors.burgundySoft)
                    Text("Ready when you are")
                        .font(.headline.weight(.bold))
                    Text("Hit the big button — we’ll use your location to surface wineries, tasting rooms, and wine shops nearby.")
                        .font(.subheadline)
                        .foregroundStyle(SipColors.muted)
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(cardBackground)
            } else {
                ForEach(Array(appModel.wineries.prefix(4))) { winery in
                    NavigationLink {
                        WineryDetailView(wineryID: winery.id)
                    } label: {
                        WineryCard(winery: winery)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var topWinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Top-rated bottles",
                subtitle: "Vivino-style ratings, zero friction",
                action: "See all"
            ) {
                discoverFilter = nil
                selectedTab = .discover
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WineData.topRated()) { wine in
                        NavigationLink {
                            WineDetailView(wine: wine)
                        } label: {
                            WineCard(wine: wine, saved: appModel.isSaved(wine.id))
                                .frame(width: 280)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func sectionHeader(
        title: String,
        subtitle: String,
        action: String,
        onAction: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(SipColors.ink)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(SipColors.muted)
            }
            Spacer()
            Button(action, action: onAction)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(SipColors.burgundy)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(SipColors.parchment)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(SipColors.border, lineWidth: 1)
            )
    }
}
