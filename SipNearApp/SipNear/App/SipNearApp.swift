import SwiftUI

@main
struct SipNearApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appModel)
                .tint(SipTheme.ColorToken.burgundy)
        }
    }
}
