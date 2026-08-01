import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<Coordinates, Error>?
    private var authContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    func requestNearbyLocation() async -> LocationSnapshot {
        var status = manager.authorizationStatus
        if status == .notDetermined {
            status = await requestAuthorization()
        }

        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return LocationSnapshot(
                coords: .napaValley,
                granted: false,
                usingFallback: true,
                label: "Napa Valley · demo area"
            )
        }

        do {
            let coords = try await currentCoordinates()
            return LocationSnapshot(
                coords: coords,
                granted: true,
                usingFallback: false,
                label: "Near you"
            )
        } catch {
            return LocationSnapshot(
                coords: .napaValley,
                granted: true,
                usingFallback: true,
                label: "Napa Valley · demo area"
            )
        }
    }

    private func requestAuthorization() async -> CLAuthorizationStatus {
        await withCheckedContinuation { continuation in
            authContinuation = continuation
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

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
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
