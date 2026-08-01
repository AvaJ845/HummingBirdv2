import SwiftUI

struct SavedView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        Group {
            if appModel.savedWines.isEmpty {
                ContentUnavailableView {
                    Label("Nothing saved yet", systemImage: "heart")
                } description: {
                    Text("Tap the heart on any bottle. It stays on this iPhone — no account.")
                }
            } else {
                List(appModel.savedWines) { wine in
                    NavigationLink {
                        WineDetailView(wine: wine)
                    } label: {
                        WineCard(wine: wine, isSaved: true)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .sipCanvas()
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.large)
    }
}
