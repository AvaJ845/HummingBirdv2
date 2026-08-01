import SwiftUI

struct SavedView: View {
    @EnvironmentObject private var appModel: AppModel

    private var wines: [Wine] {
        WineData.wines.filter { appModel.savedWineIds.contains($0.id) }
    }

    var body: some View {
        Group {
            if wines.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart")
                        .font(.system(size: 36))
                        .foregroundStyle(SipColors.burgundySoft)
                    Text("Nothing saved yet")
                        .font(.headline.weight(.bold))
                    Text("Tap the heart on any bottle — it stays on your phone, no signup.")
                        .font(.subheadline)
                        .foregroundStyle(SipColors.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(wines) { wine in
                    NavigationLink {
                        WineDetailView(wine: wine)
                    } label: {
                        WineCard(wine: wine, saved: true)
                    }
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(SipColors.cream.ignoresSafeArea())
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.large)
    }
}
