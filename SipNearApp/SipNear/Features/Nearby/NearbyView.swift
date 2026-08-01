import SwiftUI
import MapKit

struct NearbyView: View {
    @Environment(AppModel.self) private var appModel
    @State private var showMap = true
    @State private var position: MapCameraPosition = .automatic
    @Namespace private var mapScope

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header

                if appModel.wineries.isEmpty {
                    emptyState
                } else {
                    if showMap {
                        map
                            .frame(height: 250)
                            .padding(.horizontal, SipTheme.Spacing.lg)
                            .padding(.bottom, SipTheme.Spacing.sm)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if let message = appModel.statusMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(SipTheme.ColorToken.burgundy)
                            .padding(.horizontal, SipTheme.Spacing.lg)
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    listToolbar

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
            .sipCanvas()
            .toolbar(.hidden, for: .navigationBar)
            .onAppear(perform: updateCamera)
            .onChange(of: appModel.coords?.latitude) { _, _ in updateCamera() }
            .animation(SipTheme.Motion.gentle, value: showMap)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Nearby")
                    .font(.largeTitle.weight(.heavy))
                    .foregroundStyle(SipTheme.ColorToken.ink)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SipTheme.ColorToken.muted)
            }
            Spacer()
            Button {
                Haptics.selection()
                showMap.toggle()
            } label: {
                Label(showMap ? "List" : "Map", systemImage: showMap ? "list.bullet" : "map")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SipTheme.ColorToken.burgundy)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(SipTheme.ColorToken.surface, in: Capsule())
                    .overlay(Capsule().stroke(SipTheme.ColorToken.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showMap ? "Show list only" : "Show map")
        }
        .padding(.horizontal, SipTheme.Spacing.lg)
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
                isLoading: appModel.isBusy
            ) {
                Task { await appModel.findNearby() }
            }
            .padding(SipTheme.Spacing.lg)
            Spacer()
        }
    }

    private var listToolbar: some View {
        HStack {
            Text("\(appModel.wineries.count) places")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(SipTheme.ColorToken.inkSecondary)
            Spacer()
            Button {
                Task { await appModel.refreshWineries() }
            } label: {
                if appModel.isLoadingWineries {
                    ProgressView()
                } else {
                    Text("Refresh")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(SipTheme.ColorToken.burgundy)
                }
            }
            .accessibilityLabel("Refresh nearby wineries")
        }
        .padding(.horizontal, SipTheme.Spacing.lg)
        .padding(.bottom, 8)
    }

    private var map: some View {
        Map(position: $position, scope: mapScope) {
            if let coords = appModel.coords {
                Annotation("You", coordinate: coords.coordinate) {
                    Image(systemName: "person.crop.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(SipTheme.ColorToken.gold, .white)
                        .font(.title2)
                        .shadow(radius: 2, y: 1)
                }
            }

            ForEach(appModel.wineries) { winery in
                Marker(winery.name, systemImage: "wineglass.fill", coordinate: winery.coordinate)
                    .tint(SipTheme.ColorToken.burgundy)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass(scope: mapScope)
            MapPitchToggle(scope: mapScope)
            MapUserLocationButton(scope: mapScope)
        }
        .clipShape(RoundedRectangle(cornerRadius: SipTheme.Radius.panel, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SipTheme.Radius.panel, style: .continuous)
                .stroke(SipTheme.ColorToken.border, lineWidth: 1)
        )
        .accessibilityLabel("Map of nearby wineries")
    }

    private func updateCamera() {
        let center = appModel.coords?.coordinate ?? Coordinates.napaValley.coordinate
        position = .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
            )
        )
    }
}
