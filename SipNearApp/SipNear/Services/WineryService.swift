import Foundation

struct NearbyResult {
    let wineries: [Winery]
    let fromFallback: Bool
    let message: String?
}

enum WineryService {
    private static let endpoints = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter"
    ]

    static func fetchNearby(coords: Coordinates, radiusMeters: Int = 25_000) async -> NearbyResult {
        do {
            let osm = try await queryOverpass(coords: coords, radiusMeters: radiusMeters)
            if !osm.isEmpty {
                return NearbyResult(wineries: Array(osm.prefix(60)), fromFallback: false, message: nil)
            }

            let wider = try await queryOverpass(coords: coords, radiusMeters: radiusMeters * 2)
            if !wider.isEmpty {
                return NearbyResult(
                    wineries: Array(wider.prefix(60)),
                    fromFallback: false,
                    message: "Expanded search radius to find more wineries."
                )
            }

            return NearbyResult(
                wineries: FallbackWineries.nearby(origin: coords),
                fromFallback: true,
                message: "No OpenStreetMap wineries nearby — showing curated wine country picks."
            )
        } catch {
            return NearbyResult(
                wineries: FallbackWineries.nearby(origin: coords),
                fromFallback: true,
                message: "Live map data unavailable — showing curated wine country picks."
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
            request.setValue(
                "application/x-www-form-urlencoded; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
            let body = "data=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
            request.httpBody = body.data(using: .utf8)
            request.timeoutInterval = 18

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                let decoded = try JSONDecoder().decode(OverpassResponse.self, from: data)
                let mapped = decoded.elements.compactMap { $0.asWinery() }
                let unique = dedupe(mapped)
                return Geo.withDistances(unique, origin: coords)
            } catch {
                lastError = error
            }
        }

        throw lastError ?? URLError(.cannotConnectToHost)
    }

    private static func dedupe(_ wineries: [Winery]) -> [Winery] {
        var seen = Set<String>()
        var result: [Winery] = []
        for winery in wineries {
            let key = "\(winery.name.lowercased())|\(String(format: "%.3f", winery.latitude))|\(String(format: "%.3f", winery.longitude))"
            if seen.contains(key) { continue }
            seen.insert(key)
            result.append(winery)
        }
        return result
    }
}

private struct OverpassResponse: Decodable {
    let elements: [OsmElement]
}

private struct OsmElement: Decodable {
    let id: Int
    let type: String
    let lat: Double?
    let lon: Double?
    let center: Center?
    let tags: [String: String]?

    struct Center: Decodable {
        let lat: Double
        let lon: Double
    }

    func asWinery() -> Winery? {
        guard let tags, let name = tags["name"]?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return nil
        }
        let latitude = lat ?? center?.lat
        let longitude = lon ?? center?.lon
        guard let latitude, let longitude else { return nil }

        let addressParts = [
            tags["addr:housenumber"],
            tags["addr:street"],
            tags["addr:city"],
            tags["addr:state"]
        ].compactMap { $0 }
        let address = addressParts.isEmpty ? tags["addr:full"] : addressParts.joined(separator: " ")

        return Winery(
            id: "osm-\(type)-\(id)",
            name: name,
            latitude: latitude,
            longitude: longitude,
            address: address,
            phone: tags["phone"] ?? tags["contact:phone"],
            website: tags["website"] ?? tags["contact:website"],
            hours: tags["opening_hours"],
            category: category(from: tags),
            description: tags["description"],
            source: .osm
        )
    }

    private func category(from tags: [String: String]) -> WineryCategory {
        if tags["craft"] == "winery" || tags["amenity"] == "winery" { return .winery }
        if tags["landuse"] == "vineyard" { return .vineyard }
        if tags["tourism"] == "wine_cellar" { return .wineCellar }
        if tags["shop"] == "wine" || tags["shop"] == "alcohol" { return .wineShop }
        return .winery
    }
}
