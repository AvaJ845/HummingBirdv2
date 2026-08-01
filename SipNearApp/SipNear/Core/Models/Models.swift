import Foundation
import CoreLocation
import SwiftUI

struct Coordinates: Hashable, Codable, Sendable {
    var latitude: Double
    var longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static let napaValley = Coordinates(latitude: 38.5025, longitude: -122.2654)
}

enum WineType: String, CaseIterable, Identifiable, Codable, Sendable {
    case red, white, rose, sparkling, dessert

    var id: String { rawValue }

    var title: String {
        switch self {
        case .red: return "Red"
        case .white: return "White"
        case .rose: return "Rosé"
        case .sparkling: return "Sparkling"
        case .dessert: return "Dessert"
        }
    }

    var symbolName: String {
        switch self {
        case .red: return "wineglass.fill"
        case .white: return "drop.fill"
        case .rose: return "leaf.fill"
        case .sparkling: return "sparkles"
        case .dessert: return "birthday.cake.fill"
        }
    }
}

enum WineryCategory: String, Codable, Sendable {
    case winery, vineyard, wineShop, wineCellar, tastingRoom

    var title: String {
        switch self {
        case .winery: return "Winery"
        case .vineyard: return "Vineyard"
        case .wineShop: return "Wine shop"
        case .wineCellar: return "Wine cellar"
        case .tastingRoom: return "Tasting room"
        }
    }
}

struct Winery: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    var distanceMeters: Double?
    var address: String?
    var phone: String?
    var website: String?
    var hours: String?
    var category: WineryCategory
    var rating: Double?
    var reviewCount: Int?
    var summary: String?
    var source: Source

    enum Source: String, Sendable {
        case openStreetMap
        case curated
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Wine: Identifiable, Hashable, Codable, Sendable {
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
    let blurb: String
    let colorHex: String
    var alcohol: Double?

    var displayName: String {
        if let vintage { return "\(name) \(vintage)" }
        return name
    }

    var swatch: Color { Color(hex: colorHex) }
}

enum AppTab: Hashable {
    case home, nearby, discover
}

struct LocationSnapshot: Sendable {
    let coords: Coordinates
    let granted: Bool
    let usingFallback: Bool
    let label: String
}

struct NearbyWineriesResult: Sendable {
    let wineries: [Winery]
    let fromFallback: Bool
    let message: String?
}
