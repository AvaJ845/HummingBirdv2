import Foundation

enum WineData {
    static let wines: [Wine] = [
        Wine(id: "w1", name: "Estate Cabernet Sauvignon", winery: "Silverado Trail Cellars", region: "Napa Valley", country: "USA", type: .red, vintage: 2021, rating: 4.4, ratingsCount: 12840, priceEstimate: 48, grapes: ["Cabernet Sauvignon", "Merlot"], tastingNotes: ["Blackcurrant", "Cedar", "Cocoa", "Vanilla"], description: "A plush Napa Cabernet with dark fruit depth and silky tannins. Easy to love, hard to put down.", colorHex: "5C0A1A", alcohol: 14.5),
        Wine(id: "w2", name: "Coastal Chardonnay", winery: "Fogline Vineyards", region: "Sonoma Coast", country: "USA", type: .white, vintage: 2022, rating: 4.2, ratingsCount: 8921, priceEstimate: 32, grapes: ["Chardonnay"], tastingNotes: ["Green apple", "Lemon zest", "Butter", "Toast"], description: "Bright coastal acidity meets a soft buttery finish. Perfect porch pour.", colorHex: "E8D48B", alcohol: 13.2),
        Wine(id: "w3", name: "Rosé of Pinot Noir", winery: "Petite Côte", region: "Willamette Valley", country: "USA", type: .rose, vintage: 2023, rating: 4.1, ratingsCount: 5402, priceEstimate: 24, grapes: ["Pinot Noir"], tastingNotes: ["Strawberry", "Watermelon", "Citrus blossom"], description: "Crisp, dry, and wildly refreshing. The ultimate easy-button picnic wine.", colorHex: "E8A0AE", alcohol: 12.8),
        Wine(id: "w4", name: "Blanc de Blancs Brut", winery: "Maison Éclat", region: "Champagne", country: "France", type: .sparkling, vintage: 2018, rating: 4.6, ratingsCount: 21034, priceEstimate: 72, grapes: ["Chardonnay"], tastingNotes: ["Brioche", "Pear", "Chalk", "White flowers"], description: "Fine bubbles, elegant toast, and a clean mineral finish. Celebration mode, one tap away.", colorHex: "F5E6B8", alcohol: 12.0),
        Wine(id: "w5", name: "Old Vine Zinfandel", winery: "Dry Creek Heritage", region: "Dry Creek Valley", country: "USA", type: .red, vintage: 2020, rating: 4.3, ratingsCount: 7633, priceEstimate: 36, grapes: ["Zinfandel"], tastingNotes: ["Blackberry jam", "Pepper", "Licorice"], description: "Bold fruit with a peppery kick from old vines. Grill-night champion.", colorHex: "6B1224", alcohol: 15.1),
        Wine(id: "w6", name: "Sancerre Les Caillottes", winery: "Domaine Loire Verte", region: "Sancerre", country: "France", type: .white, vintage: 2023, rating: 4.5, ratingsCount: 11220, priceEstimate: 41, grapes: ["Sauvignon Blanc"], tastingNotes: ["Gooseberry", "Flint", "Lime", "Herbs"], description: "Laser-focused Sauvignon Blanc with classic Loire minerality. Oysters optional, recommended.", colorHex: "F2E8C9", alcohol: 13.0),
        Wine(id: "w7", name: "Barolo Cascina Alta", winery: "Casa delle Nebbie", region: "Piedmont", country: "Italy", type: .red, vintage: 2018, rating: 4.7, ratingsCount: 9844, priceEstimate: 89, grapes: ["Nebbiolo"], tastingNotes: ["Cherry", "Rose", "Tar", "Truffle"], description: "Structured Nebbiolo with soaring aromatics. Elegant now, better with a short breath.", colorHex: "7A1630", alcohol: 14.0),
        Wine(id: "w8", name: "Prosecco Extra Dry", winery: "Colli Vivaci", region: "Veneto", country: "Italy", type: .sparkling, vintage: nil, rating: 3.9, ratingsCount: 18450, priceEstimate: 18, grapes: ["Glera"], tastingNotes: ["Green apple", "Pear", "White peach"], description: "Light, friendly bubbles for any Tuesday. Zero fuss, maximum cheer.", colorHex: "F7F0D8", alcohol: 11.0),
        Wine(id: "w9", name: "Late Harvest Riesling", winery: "Rheingold Estate", region: "Mosel", country: "Germany", type: .dessert, vintage: 2021, rating: 4.4, ratingsCount: 3210, priceEstimate: 38, grapes: ["Riesling"], tastingNotes: ["Honey", "Apricot", "Slate", "Citrus peel"], description: "Luscious sweetness balanced by electric acidity. Cheese board magic.", colorHex: "D4B86A", alcohol: 9.5),
        Wine(id: "w10", name: "Grenache Blend", winery: "Sunstone Ridge", region: "Paso Robles", country: "USA", type: .red, vintage: 2021, rating: 4.0, ratingsCount: 4550, priceEstimate: 29, grapes: ["Grenache", "Syrah", "Mourvèdre"], tastingNotes: ["Raspberry", "Herbs", "Spice"], description: "Sunny Rhône-style blend with easy charm. Weeknight steak’s best friend.", colorHex: "8B1E36", alcohol: 14.2),
        Wine(id: "w11", name: "Albariño Rías", winery: "Atlántica Bodega", region: "Rías Baixas", country: "Spain", type: .white, vintage: 2023, rating: 4.3, ratingsCount: 6701, priceEstimate: 27, grapes: ["Albariño"], tastingNotes: ["Peach", "Salt spray", "Lemon"], description: "Saline, peachy, and built for seafood. One-tap coastal vibes.", colorHex: "F0E4B8", alcohol: 12.5),
        Wine(id: "w12", name: "Pinot Noir Reserve", winery: "Evening Mist", region: "Russian River Valley", country: "USA", type: .red, vintage: 2022, rating: 4.5, ratingsCount: 10112, priceEstimate: 54, grapes: ["Pinot Noir"], tastingNotes: ["Cherry", "Forest floor", "Cola", "Spice"], description: "Silky Russian River Pinot with layer after layer. Date-night automatic.", colorHex: "6E1830", alcohol: 13.8)
    ]

    static func wine(id: String) -> Wine? {
        wines.first { $0.id == id }
    }

    static func topRated(limit: Int = 6) -> [Wine] {
        Array(wines.sorted { $0.rating > $1.rating }.prefix(limit))
    }

    static func filtered(type: WineType?) -> [Wine] {
        let list = type.map { t in wines.filter { $0.type == t } } ?? wines
        return list.sorted { $0.rating > $1.rating }
    }
}
