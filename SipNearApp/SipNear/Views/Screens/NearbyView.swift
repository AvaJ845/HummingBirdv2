import SwiftUI
import MapKit

struct NearbyView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var showMap = true
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                if appModel.wineries.isEmpty {
                    emptyState
                } else {
                    if showMap {
                        mapSection
                            .frame(height: 240)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                    }

                    if let message = appModel.statusMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(SipColors.burgundySoft)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HStack {
                        Text("\(appModel.wineries.count) places")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(SipColors.inkSoft)
                        Spacer()
                        Button {
                            Task { await appModel.refreshWineries() }
                        } label: {
                            if appModel.isLoadingWineries {
                                ProgressView()
                            } else {
                                Text("Refresh")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(SipColors.burgundy)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                    List(appModel.wineries) { winery in
                        NavigationLink {
                            WineryDetailView(wineryID: winery.id)
                        } label: {
                            WineryCard(winery: winery)
                        }
                        .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(SipColors.cream.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear { updateCamera() }
            .onChange(of: appModel.coords?.latitude) { _, _ in updateCamera() }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Nearby")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(SipColors.ink)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SipColors.muted)
            }
            Spacer()
            Button {
                showMap.toggle()
            } label: {
                Label(showMap ? "List" : "Map", systemImage: showMap ? "list.bullet" : "map")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SipColors.burgundy)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(SipColors.parchment)
                    .overlay(Capsule().stroke(SipColors.border, lineWidth: 1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var subtitle: String {
        var text = appModel.coords == nil ? "Tap to pull your location" : appModel.locationLabel
        if appModel.fromFallbackWineries { text += " · curated backup" }
        return text
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            EasyButton(
                title: "Find Wineries Near Me",
                subtitle: "One tap · no account",
                loading: appModel.isBusy
            ) {
                Task { await appModel.findNearby() }
            }
            .padding(20)
            Spacer()
        }
    }

    private var mapSection: some View {
        Map(position: $position) {
            if let coords = appModel.coords {
                Annotation("You", coordinate: coords.locationCoordinate) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(SipColors.gold)
                        .padding(4)
                        .background(.white)
                        .clipShape(Circle())
                }
            }

            ForEach(appModel.wineries) { winery in
                Marker(winery.name, coordinate: winery.coordinate)
                    .tint(SipColors.burgundy)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(SipColors.border, lineWidth: 1)
        )
    }

    private func updateCamera() {
        let center = appModel.coords?.locationCoordinate
            ?? LocationService.defaultCoords.locationCoordinate
        position = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
            )
        )
    }
}
