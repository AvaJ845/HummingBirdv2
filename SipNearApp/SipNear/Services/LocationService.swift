import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let defaultCoords = Coordinates(latitude: 38.5025, longitude: -122.2654)

    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<Coordinates, Error>?
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    struct LocationResult {
        let coords: Coordinates
        let granted: Bool
        let usingFallback: Bool
        let label: String
    }

    func requestNearbyLocation() async -> LocationResult {
        var status = manager.authorizationStatus

        if status == .notDetermined {
            status = await requestAuthorization()
        }

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return LocationResult(
                coords: Self.defaultCoords,
                granted: false,
                usingFallback: true,
                label: "Napa Valley (demo area)"
            )
        }

        do {
            let coords = try await currentCoordinates()
            return LocationResult(
                coords: coords,
                granted: true,
                usingFallback: false,
                label: "Near you"
            )
        } catch {
            return LocationResult(
                coords: Self.defaultCoords,
                granted: true,
                usingFallback: true,
                label: "Napa Valley (demo area)"
            )
        }
    }

    private func requestAuthorization() async -> CLAuthorizationStatus {
        await withCheckedContinuation { cont in
            self.authContinuation = cont
            manager.requestWhenInUseAuthorization()
        }
    }

    private func currentCoordinates() async throws -> Coordinates {
        if let location = manager.location {
            return Coordinates(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        }

        return try await withCheckedThrowingContinuation { cont in
            self.locationContinuation = cont
            manager.requestLocation()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            self.authorizationStatus = status
            if status != .notDetermined, let authContinuation {
                authContinuation.resume(returning: status)
                self.authContinuation = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        Task { @MainActor in
            locationContinuation?.resume(
                returning: Coordinates(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            )
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: error)
            locationContinuation = nil
        }
    }
}
