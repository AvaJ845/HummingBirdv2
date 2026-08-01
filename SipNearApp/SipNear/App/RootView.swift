import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var model = appModel

        Group {
            if model.hasCompletedWelcome {
                TabView(selection: $model.selectedTab) {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(AppTab.home)

                    NearbyView()
                        .tabItem { Label("Nearby", systemImage: "map.fill") }
                        .tag(AppTab.nearby)

                    DiscoverView()
                        .tabItem { Label("Discover", systemImage: "wineglass.fill") }
                        .tag(AppTab.discover)
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                WelcomeView()
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .animation(SipTheme.Motion.emphasized, value: model.hasCompletedWelcome)
    }
}

#Preview("Welcome") {
    RootView()
        .environment(AppModel())
}

#Preview("Home") {
    RootView()
        .environment({
            let model = AppModel()
            model.hasCompletedWelcome = true
            return model
        }())
}
