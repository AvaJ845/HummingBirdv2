import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var model = appModel

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SipTheme.Spacing.lg) {
                    header

                    Text("One easy button. No account. Wineries around you and wines worth drinking.")
                        .font(.subheadline)
                        .foregroundStyle(SipTheme.ColorToken.inkSecondary)

                    EasyButton(
                        title: model.wineries.isEmpty ? "Find Wineries Near Me" : "Refresh Nearby Wineries",
                        subtitle: easySubtitle,
                        isLoading: model.isBusy
                    ) {
                        Task { await model.findNearby() }
                    }

                    quickFilters
                    nearbySection
                    topWinesSection
                }
                .padding(SipTheme.Spacing.lg)
            }
            .sipCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var easySubtitle: String {
        guard appModel.coords != nil else {
            return "Pull your location · instant results"
        }
        if appModel.usingFallbackLocation {
            return "Using demo wine country · tap to try your location"
        }
        return appModel.locationLabel
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good sipping")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SipTheme.ColorToken.muted)
                Text("SipNear")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(SipTheme.ColorToken.ink)
            }
            Spacer()
            NavigationLink {
                SavedView()
            } label: {
                Label("Saved", systemImage: "heart.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(SipTheme.ColorToken.inkSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(SipTheme.ColorToken.surface, in: Capsule())
                    .overlay(Capsule().stroke(SipTheme.ColorToken.border, lineWidth: 1))
            }
            .accessibilityHint("Shows bottles saved on this iPhone")
        }
    }

    private var quickFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([WineType.red, .white, .sparkling, .rose]) { type in
                    Button {
                        Haptics.selection()
                        appModel.openDiscover(filter: type)
                    } label: {
                        Label(type.title, systemImage: type.symbolName)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(SipTheme.ColorToken.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(SipTheme.ColorToken.surface, in: Capsule())
                            .overlay(Capsule().stroke(SipTheme.ColorToken.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityLabel("Wine style shortcuts")
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: SipTheme.Spacing.sm) {
            SectionHeader(
                title: "Nearby wineries",
                subtitle: appModel.statusMessage
                    ?? (appModel.wineries.isEmpty
                        ? "Tap the easy button to pull locations"
                        : "\(appModel.wineries.count) places found"),
                actionTitle: "Map",
                action: { appModel.selectedTab = .nearby }
            )

            if appModel.isBusy && appModel.wineries.isEmpty {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Finding wineries around you…")
                        .foregroundStyle(SipTheme.ColorToken.muted)
                }
                .frame(maxWidth: .infinity)
                .padding(SipTheme.Spacing.lg)
                .sipCardStyle()
            } else if appModel.wineries.isEmpty {
                EmptyStateCard(
                    symbol: "map",
                    title: "Ready when you are",
                    message: "Hit the big button — SipNear uses your location to surface wineries, tasting rooms, and wine shops nearby."
                )
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
        VStack(alignment: .leading, spacing: SipTheme.Spacing.sm) {
            SectionHeader(
                title: "Top-rated bottles",
                subtitle: "Vivino-style ratings, zero friction",
                actionTitle: "See all",
                action: { appModel.openDiscover() }
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WineCatalog.topRated()) { wine in
                        NavigationLink {
                            WineDetailView(wine: wine)
                        } label: {
                            WineCard(wine: wine, isSaved: appModel.isSaved(wine.id))
                                .frame(width: 280)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    HomeView()
        .environment(AppModel())
}
