import Foundation

struct ConversionRecord: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let fromCurrency: String
    let toCurrency: String
    let rate: Double
    let amount: Double
    let result: Double
}
