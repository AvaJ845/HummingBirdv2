import Foundation
import CoreLocation

enum WineType: String, CaseIterable, Identifiable, Codable {
    case red, white, rose, sparkling, dessert

    var id: String { rawValue }

    var label: String {
        switch self {
        case .red: return "Red"
        case .white: return "White"
        case .rose: return "Rosé"
        case .sparkling: return "Sparkling"
        case .dessert: return "Dessert"
        }
    }
}

enum WineryCategory: String, Codable {
    case winery, vineyard, wineShop, wineCellar, tastingRoom

    var label: String {
        switch self {
        case .winery: return "Winery"
        case .vineyard: return "Vineyard"
        case .wineShop: return "Wine shop"
        case .wineCellar: return "Wine cellar"
        case .tastingRoom: return "Tasting room"
        }
    }
}

struct Coordinates: Hashable, Codable {
    var latitude: Double
    var longitude: Double

    var locationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Winery: Identifiable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    var distanceMeters: Double? = nil
    var address: String? = nil
    var phone: String? = nil
    var website: String? = nil
    var hours: String? = nil
    var category: WineryCategory
    var rating: Double? = nil
    var reviewCount: Int? = nil
    var description: String? = nil
    var source: Source

    enum Source: String {
        case osm
        case curated
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Wine: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let winery: String
    let region: String
    let country: String
    let type: WineType
    var vintage: Int?
    let rating: Double
    let ratingsCount: Int
    let priceEstimate: Int
    let grapes: [String]
    let tastingNotes: [String]
    let description: String
    let colorHex: String
    var alcohol: Double?
}
