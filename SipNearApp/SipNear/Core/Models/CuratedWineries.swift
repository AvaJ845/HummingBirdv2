import Foundation

enum CuratedWineries {
    static let all: [Winery] = [
        Winery(id: "c1", name: "Castello di Amorosa", latitude: 38.5645, longitude: -122.5427, address: "4045 St Helena Hwy, Calistoga, CA", website: "https://castellodiamorosa.com", category: .winery, rating: 4.6, reviewCount: 8200, summary: "A striking Tuscan castle winery with hillside tastings.", source: .curated),
        Winery(id: "c2", name: "Sterling Vineyards", latitude: 38.5821, longitude: -122.5663, address: "1111 Dunaweal Ln, Calistoga, CA", category: .winery, rating: 4.4, reviewCount: 5400, summary: "Aerial tram views over Napa with classic estate wines.", source: .curated),
        Winery(id: "c3", name: "V. Sattui Winery", latitude: 38.5012, longitude: -122.4589, address: "1111 White Ln, St Helena, CA", category: .winery, rating: 4.5, reviewCount: 9100, summary: "Picnic-perfect winery with a bustling tasting marketplace.", source: .curated),
        Winery(id: "c4", name: "Beringer Vineyards", latitude: 38.5104, longitude: -122.4805, address: "2000 Main St, St Helena, CA", category: .vineyard, rating: 4.3, reviewCount: 12000, summary: "Historic Napa landmark with gardens and reserve tastings.", source: .curated),
        Winery(id: "c5", name: "Domaine Carneros", latitude: 38.2488, longitude: -122.3311, address: "1240 Duhig Rd, Napa, CA", category: .winery, rating: 4.6, reviewCount: 7800, summary: "Elegant château known for sparkling wine and terrace views.", source: .curated),
        Winery(id: "c6", name: "Duckhorn Vineyards", latitude: 38.5248, longitude: -122.4792, address: "1000 Lodi Ln, St Helena, CA", category: .winery, rating: 4.5, reviewCount: 4300, summary: "Merlot specialists with a polished tasting salon.", source: .curated),
        Winery(id: "c7", name: "Jordan Vineyard & Winery", latitude: 38.7172, longitude: -122.8874, address: "1474 Alexander Valley Rd, Healdsburg, CA", category: .winery, rating: 4.7, reviewCount: 3900, summary: "Alexander Valley estate famous for Cabernet and hospitality.", source: .curated),
        Winery(id: "c8", name: "Francis Ford Coppola Winery", latitude: 38.6741, longitude: -122.8879, address: "300 Via Archimedes, Geyserville, CA", category: .winery, rating: 4.4, reviewCount: 10200, summary: "Movie memorabilia, poolside lounging, and approachable wines.", source: .curated)
    ]

    static func ranked(near origin: Coordinates, radiusMeters: Double = 120_000) -> [Winery] {
        let ranked = withDistances(all, origin: origin)
        let nearby = ranked.filter { ($0.distanceMeters ?? .infinity) <= radiusMeters }
        return nearby.isEmpty ? ranked : nearby
    }

    static func withDistances(_ wineries: [Winery], origin: Coordinates) -> [Winery] {
        wineries
            .map { winery in
                var copy = winery
                copy.distanceMeters = GeoMath.distanceMeters(from: origin.coordinate, to: winery.coordinate)
                return copy
            }
            .sorted { ($0.distanceMeters ?? .greatestFiniteMagnitude) < ($1.distanceMeters ?? .greatestFiniteMagnitude) }
    }
}

extension Winery {
    init(
        id: String,
        name: String,
        latitude: Double,
        longitude: Double,
        address: String? = nil,
        phone: String? = nil,
        website: String? = nil,
        hours: String? = nil,
        category: WineryCategory,
        rating: Double? = nil,
        reviewCount: Int? = nil,
        summary: String? = nil,
        source: Source
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.distanceMeters = nil
        self.address = address
        self.phone = phone
        self.website = website
        self.hours = hours
        self.category = category
        self.rating = rating
        self.reviewCount = reviewCount
        self.summary = summary
        self.source = source
    }
}
