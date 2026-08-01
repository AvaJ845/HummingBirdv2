import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var wineries: [Winery] = []
    @Published var locationLabel: String = "Location not set"
    @Published var coords: Coordinates?
    @Published var usingFallbackLocation = false
    @Published var fromFallbackWineries = false
    @Published var statusMessage: String?
    @Published var isLoadingLocation = false
    @Published var isLoadingWineries = false
    @Published var hasCompletedWelcome = false
    @Published var savedWineIds: Set<String> = []

    private let locationService = LocationService()
    private let savedKey = "sipnear.savedWineIds"

    init() {
        if let data = UserDefaults.standard.array(forKey: savedKey) as? [String] {
            savedWineIds = Set(data)
        }
    }

    var isBusy: Bool { isLoadingLocation || isLoadingWineries }

    func findNearby() async {
        isLoadingLocation = true
        defer { isLoadingLocation = false }

        let result = await locationService.requestNearbyLocation()
        coords = result.coords
        usingFallbackLocation = result.usingFallback
        locationLabel = result.label
        await refreshWineries()
    }

    func refreshWineries() async {
        guard let coords else {
            await findNearby()
            return
        }

        isLoadingWineries = true
        defer { isLoadingWineries = false }

        let result = await WineryService.fetchNearby(coords: coords)
        wineries = result.wineries
        fromFallbackWineries = result.fromFallback
        statusMessage = result.message
    }

    func toggleSaved(wine: Wine) {
        if savedWineIds.contains(wine.id) {
            savedWineIds.remove(wine.id)
        } else {
            savedWineIds.insert(wine.id)
        }
        UserDefaults.standard.set(Array(savedWineIds), forKey: savedKey)
    }

    func isSaved(_ id: String) -> Bool {
        savedWineIds.contains(id)
    }

    func winery(id: String) -> Winery? {
        wineries.first { $0.id == id } ?? FallbackWineries.curated.first { $0.id == id }
    }
}
