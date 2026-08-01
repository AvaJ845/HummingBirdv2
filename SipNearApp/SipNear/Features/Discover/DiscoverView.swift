import SwiftUI

struct DiscoverView: View {
    @Environment(AppModel.self) private var appModel
    @State private var filter: WineType?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(.largeTitle.weight(.heavy))
                        .foregroundStyle(SipTheme.ColorToken.ink)
                    Text("Browse like Vivino — tap any bottle for notes and ratings.")
                        .font(.subheadline)
                        .foregroundStyle(SipTheme.ColorToken.muted)
                }
                .padding(.horizontal, SipTheme.Spacing.lg)
                .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: filter == nil) {
                            filter = nil
                        }
                        ForEach(WineType.allCases) { type in
                            FilterChip(title: type.title, isSelected: filter == type) {
                                filter = type
                            }
                        }
                    }
                    .padding(.horizontal, SipTheme.Spacing.lg)
                    .padding(.vertical, 12)
                }

                List(WineCatalog.filtered(filter)) { wine in
                    NavigationLink {
                        WineDetailView(wine: wine)
                    } label: {
                        WineCard(wine: wine, isSaved: appModel.isSaved(wine.id))
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .sipCanvas()
            .toolbar(.hidden, for: .navigationBar)
            .onAppear { filter = appModel.discoverFilter }
            .onChange(of: appModel.discoverFilter) { _, newValue in
                filter = newValue
            }
        }
    }
}

#Preview {
    DiscoverView()
        .environment(AppModel())
}
