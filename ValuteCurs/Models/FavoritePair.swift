import Foundation

struct FavoritePair: Identifiable, Codable {
    let id = UUID()
    let fromCurrency: String
    let toCurrency: String
    let dateAdded: Date
}
