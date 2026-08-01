import Foundation

enum WineryService {
    private static let endpoints = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter"
    ]

    static func fetchNearby(coords: Coordinates, radiusMeters: Int = 25_000) async -> NearbyWineriesResult {
        do {
            let primary = try await queryOverpass(coords: coords, radiusMeters: radiusMeters)
            if !primary.isEmpty {
                return NearbyWineriesResult(wineries: Array(primary.prefix(60)), fromFallback: false, message: nil)
            }

            let wider = try await queryOverpass(coords: coords, radiusMeters: radiusMeters * 2)
            if !wider.isEmpty {
                return NearbyWineriesResult(
                    wineries: Array(wider.prefix(60)),
                    fromFallback: false,
                    message: "Expanded your search radius to find more places."
                )
            }

            return NearbyWineriesResult(
                wineries: CuratedWineries.ranked(near: coords),
                fromFallback: true,
                message: "No live map matches nearby — showing curated wine-country picks."
            )
        } catch {
            return NearbyWineriesResult(
                wineries: CuratedWineries.ranked(near: coords),
                fromFallback: true,
                message: "Live map data unavailable — showing curated wine-country picks."
            )
        }
    }

    private static func queryOverpass(coords: Coordinates, radiusMeters: Int) async throws -> [Winery] {
        let query = """
        [out:json][timeout:25];
        (
          nwr["craft"="winery"](around:\(radiusMeters),\(coords.latitude),\(coords.longitude));
          nwr["amenity"="winery"](around:\(radiusMeters),\(coords.latitude),\(coords.longitude));
          nwr["tourism"="wine_cellar"](around:\(radiusMeters),\(coords.latitude),\(coords.longitude));
          nwr["shop"="wine"](around:\(radiusMeters),\(coords.latitude),\(coords.longitude));
          nwr["landuse"="vineyard"]["name"](around:\(radiusMeters),\(coords.latitude),\(coords.longitude));
        );
        out center tags;
        """

        var lastError: Error?
        for endpoint in endpoints {
            guard let url = URL(string: endpoint) else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 18
            request.setValue(
                "application/x-www-form-urlencoded; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
            let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            request.httpBody = "data=\(encoded)".data(using: .utf8)

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                let decoded = try JSONDecoder().decode(OverpassResponse.self, from: data)
                let mapped = decoded.elements.compactMap(Self.mapElement)
                return CuratedWineries.withDistances(dedupe(mapped), origin: coords)
            } catch {
                lastError = error
            }
        }
        throw lastError ?? URLError(.cannotConnectToHost)
    }

    static func mapElement(_ element: OverpassElement) -> Winery? {
        guard let tags = element.tags,
              let name = tags["name"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty
        else { return nil }

        let latitude = element.lat ?? element.center?.lat
        let longitude = element.lon ?? element.center?.lon
        guard let latitude, let longitude else { return nil }

        let addressParts = [
            tags["addr:housenumber"],
            tags["addr:street"],
            tags["addr:city"],
            tags["addr:state"]
        ].compactMap { $0 }

        return Winery(
            id: "osm-\(element.type)-\(element.id)",
            name: name,
            latitude: latitude,
            longitude: longitude,
            address: addressParts.isEmpty ? tags["addr:full"] : addressParts.joined(separator: " "),
            phone: tags["phone"] ?? tags["contact:phone"],
            website: tags["website"] ?? tags["contact:website"],
            hours: tags["opening_hours"],
            category: category(from: tags),
            summary: tags["description"],
            source: .openStreetMap
        )
    }

    private static func category(from tags: [String: String]) -> WineryCategory {
        if tags["craft"] == "winery" || tags["amenity"] == "winery" { return .winery }
        if tags["landuse"] == "vineyard" { return .vineyard }
        if tags["tourism"] == "wine_cellar" { return .wineCellar }
        if tags["shop"] == "wine" || tags["shop"] == "alcohol" { return .wineShop }
        return .winery
    }

    private static func dedupe(_ wineries: [Winery]) -> [Winery] {
        var seen = Set<String>()
        var result: [Winery] = []
        for winery in wineries {
            let key = "\(winery.name.lowercased())|\(String(format: "%.3f", winery.latitude))|\(String(format: "%.3f", winery.longitude))"
            if seen.insert(key).inserted {
                result.append(winery)
            }
        }
        return result
    }
}

struct OverpassResponse: Decodable, Sendable {
    let elements: [OverpassElement]
}

struct OverpassElement: Decodable, Sendable {
    let id: Int
    let type: String
    let lat: Double?
    let lon: Double?
    let center: Center?
    let tags: [String: String]?

    struct Center: Decodable, Sendable {
        let lat: Double
        let lon: Double
    }
}
