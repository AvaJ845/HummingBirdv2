import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var appModel: AppModel
    @Binding var initialFilter: WineType?
    @State private var filter: WineType? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(SipColors.ink)
                    Text("Browse like Vivino — tap any bottle for notes & ratings.")
                        .font(.subheadline)
                        .foregroundStyle(SipColors.muted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        filterChip(label: "All", selected: filter == nil) {
                            filter = nil
                        }
                        ForEach(WineType.allCases) { type in
                            filterChip(label: type.label, selected: filter == type) {
                                filter = type
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }

                List(WineData.filtered(type: filter)) { wine in
                    NavigationLink {
                        WineDetailView(wine: wine)
                    } label: {
                        WineCard(wine: wine, saved: appModel.isSaved(wine.id))
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(SipColors.cream.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                if let initialFilter {
                    filter = initialFilter
                }
            }
            .onChange(of: initialFilter) { _, newValue in
                filter = newValue
            }
        }
    }

    private func filterChip(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(selected ? .white : SipColors.inkSoft)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? SipColors.burgundy : SipColors.parchment)
                .overlay(
                    Capsule().stroke(selected ? SipColors.burgundy : SipColors.border, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
