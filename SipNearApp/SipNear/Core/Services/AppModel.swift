import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class AppModel {
    var hasCompletedWelcome = false
    var selectedTab: AppTab = .home
    var discoverFilter: WineType?

    var wineries: [Winery] = []
    var coords: Coordinates?
    var locationLabel = "Location not set"
    var usingFallbackLocation = false
    var fromFallbackWineries = false
    var statusMessage: String?

    var isLoadingLocation = false
    var isLoadingWineries = false

    private(set) var savedWineIDs: Set<String> = []

    private let locationService = LocationService()
    private let savedKey = "sipnear.savedWineIds"

    var isBusy: Bool { isLoadingLocation || isLoadingWineries }

    var savedWines: [Wine] {
        WineCatalog.all.filter { savedWineIDs.contains($0.id) }
    }

    init() {
        if let stored = UserDefaults.standard.array(forKey: savedKey) as? [String] {
            savedWineIDs = Set(stored)
        }
    }

    func completeWelcome() {
        withAnimation(SipTheme.Motion.emphasized) {
            hasCompletedWelcome = true
        }
    }

    func findNearby() async {
        isLoadingLocation = true
        defer { isLoadingLocation = false }

        let snapshot = await locationService.requestNearbyLocation()
        coords = snapshot.coords
        usingFallbackLocation = snapshot.usingFallback
        locationLabel = snapshot.label
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
        withAnimation(SipTheme.Motion.gentle) {
            wineries = result.wineries
            fromFallbackWineries = result.fromFallback
            statusMessage = result.message
        }
    }

    func toggleSaved(_ wine: Wine) {
        if savedWineIDs.contains(wine.id) {
            savedWineIDs.remove(wine.id)
            Haptics.selection()
        } else {
            savedWineIDs.insert(wine.id)
            Haptics.success()
        }
        UserDefaults.standard.set(Array(savedWineIDs), forKey: savedKey)
    }

    func isSaved(_ id: String) -> Bool {
        savedWineIDs.contains(id)
    }

    func winery(id: String) -> Winery? {
        wineries.first { $0.id == id } ?? CuratedWineries.all.first { $0.id == id }
    }

    func openDiscover(filter: WineType? = nil) {
        discoverFilter = filter
        selectedTab = .discover
    }
}
