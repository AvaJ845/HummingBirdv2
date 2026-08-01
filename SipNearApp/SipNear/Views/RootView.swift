import SwiftUI

enum MainTab: Hashable {
    case home
    case nearby
    case discover
}

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selectedTab: MainTab = .home
    @State private var discoverFilter: WineType? = nil

    var body: some View {
        Group {
            if !appModel.hasCompletedWelcome {
                WelcomeView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        appModel.hasCompletedWelcome = true
                    }
                }
            } else {
                TabView(selection: $selectedTab) {
                    HomeView(
                        selectedTab: $selectedTab,
                        discoverFilter: $discoverFilter
                    )
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(MainTab.home)

                    NearbyView()
                        .tabItem { Label("Nearby", systemImage: "map.fill") }
                        .tag(MainTab.nearby)

                    DiscoverView(initialFilter: $discoverFilter)
                        .tabItem { Label("Discover", systemImage: "wineglass.fill") }
                        .tag(MainTab.discover)
                }
                .tint(SipColors.burgundy)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appModel.hasCompletedWelcome)
    }
}
