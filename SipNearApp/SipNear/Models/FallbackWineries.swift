import Foundation
import CoreLocation

enum Geo {
    static func haversineMeters(from a: Coordinates, to b: Coordinates) -> Double {
        let r = 6_371_000.0
        let dLat = (b.latitude - a.latitude) * .pi / 180
        let dLon = (b.longitude - a.longitude) * .pi / 180
        let lat1 = a.latitude * .pi / 180
        let lat2 = b.latitude * .pi / 180
        let h = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * r * asin(sqrt(h))
    }

    static func withDistances(_ wineries: [Winery], origin: Coordinates) -> [Winery] {
        wineries
            .map { winery in
                var copy = winery
                copy.distanceMeters = haversineMeters(
                    from: origin,
                    to: Coordinates(latitude: winery.latitude, longitude: winery.longitude)
                )
                return copy
            }
            .sorted { ($0.distanceMeters ?? .greatestFiniteMagnitude) < ($1.distanceMeters ?? .greatestFiniteMagnitude) }
    }

    static func formatDistance(_ meters: Double?) -> String {
        guard let meters else { return "" }
        if meters < 1000 { return "\(Int(meters.rounded())) m" }
        let miles = meters / 1609.344
        if miles < 10 { return String(format: "%.1f mi", miles) }
        return "\(Int(miles.rounded())) mi"
    }
}

enum FallbackWineries {
    static let curated: [Winery] = [
        Winery(id: "c1", name: "Castello di Amorosa", latitude: 38.5645, longitude: -122.5427, address: "4045 St Helena Hwy, Calistoga, CA", website: "https://castellodiamorosa.com", category: .winery, rating: 4.6, reviewCount: 8200, description: "A striking Tuscan castle winery with hillside tastings.", source: .curated),
        Winery(id: "c2", name: "Sterling Vineyards", latitude: 38.5821, longitude: -122.5663, address: "1111 Dunaweal Ln, Calistoga, CA", category: .winery, rating: 4.4, reviewCount: 5400, description: "Aerial tram views over Napa with classic estate wines.", source: .curated),
        Winery(id: "c3", name: "V. Sattui Winery", latitude: 38.5012, longitude: -122.4589, address: "1111 White Ln, St Helena, CA", category: .winery, rating: 4.5, reviewCount: 9100, description: "Picnic-perfect winery with a bustling tasting marketplace.", source: .curated),
        Winery(id: "c4", name: "Beringer Vineyards", latitude: 38.5104, longitude: -122.4805, address: "2000 Main St, St Helena, CA", category: .vineyard, rating: 4.3, reviewCount: 12000, description: "Historic Napa landmark with gardens and reserve tastings.", source: .curated),
        Winery(id: "c5", name: "Domaine Carneros", latitude: 38.2488, longitude: -122.3311, address: "1240 Duhig Rd, Napa, CA", category: .winery, rating: 4.6, reviewCount: 7800, description: "Elegant château known for sparkling wine and terrace views.", source: .curated),
        Winery(id: "c6", name: "Duckhorn Vineyards", latitude: 38.5248, longitude: -122.4792, address: "1000 Lodi Ln, St Helena, CA", category: .winery, rating: 4.5, reviewCount: 4300, description: "Merlot specialists with a polished tasting salon.", source: .curated),
        Winery(id: "c7", name: "Jordan Vineyard & Winery", latitude: 38.7172, longitude: -122.8874, address: "1474 Alexander Valley Rd, Healdsburg, CA", category: .winery, rating: 4.7, reviewCount: 3900, description: "Alexander Valley estate famous for Cabernet and hospitality.", source: .curated),
        Winery(id: "c8", name: "Francis Ford Coppola Winery", latitude: 38.6741, longitude: -122.8879, address: "300 Via Archimedes, Geyserville, CA", category: .winery, rating: 4.4, reviewCount: 10200, description: "Movie memorabilia, poolside lounging, and approachable wines.", source: .curated)
    ]

    static func nearby(origin: Coordinates, radiusMeters: Double = 120_000) -> [Winery] {
        let ranked = Geo.withDistances(curated, origin: origin)
        let filtered = ranked.filter { ($0.distanceMeters ?? .infinity) <= radiusMeters }
        return filtered.isEmpty ? ranked : filtered
    }
}
