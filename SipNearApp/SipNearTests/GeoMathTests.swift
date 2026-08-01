import XCTest
@testable import SipNear

final class GeoMathTests: XCTestCase {
    func testDistanceBetweenKnownPointsIsReasonable() {
        let napa = Coordinates.napaValley.coordinate
        let calistoga = Coordinates(latitude: 38.5788, longitude: -122.5797).coordinate
        let meters = GeoMath.distanceMeters(from: napa, to: calistoga)

        XCTAssertGreaterThan(meters, 20_000)
        XCTAssertLessThan(meters, 50_000)
    }

    func testFormatDistanceUsesNaturalScale() {
        let meters = GeoMath.formatDistance(250)
        XCTAssertFalse(meters.isEmpty)

        let miles = GeoMath.formatDistance(5_000)
        XCTAssertFalse(miles.isEmpty)
    }
}

final class WineryMappingTests: XCTestCase {
    func testMapsNamedOverpassNode() throws {
        let json = """
        {
          "id": 42,
          "type": "node",
          "lat": 38.5,
          "lon": -122.3,
          "tags": {
            "name": "Test Cellars",
            "craft": "winery",
            "addr:city": "Napa"
          }
        }
        """.data(using: .utf8)!

        let element = try JSONDecoder().decode(OverpassElement.self, from: json)
        let winery = try XCTUnwrap(WineryService.mapElement(element))

        XCTAssertEqual(winery.name, "Test Cellars")
        XCTAssertEqual(winery.category, .winery)
        XCTAssertEqual(winery.source, .openStreetMap)
        XCTAssertEqual(winery.address, "Napa")
    }

    func testIgnoresNamelessElements() throws {
        let json = """
        {
          "id": 7,
          "type": "node",
          "lat": 38.5,
          "lon": -122.3,
          "tags": { "craft": "winery" }
        }
        """.data(using: .utf8)!

        let element = try JSONDecoder().decode(OverpassElement.self, from: json)
        XCTAssertNil(WineryService.mapElement(element))
    }
}
