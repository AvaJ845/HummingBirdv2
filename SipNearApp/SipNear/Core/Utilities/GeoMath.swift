import Foundation
import CoreLocation

enum GeoMath {
    static func distanceMeters(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
        let left = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let right = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return left.distance(from: right)
    }

    static func formatDistance(_ meters: Double?) -> String {
        guard let meters else { return "" }
        let measurement = Measurement(value: meters, unit: UnitLength.meters)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = meters < 1609 ? 0 : 1
        return formatter.string(from: measurement)
    }
}
