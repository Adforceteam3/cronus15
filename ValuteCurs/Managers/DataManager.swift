import Foundation
import SwiftUI

@MainActor
class DataManager: ObservableObject {
    @Published var conversionHistory: [ConversionRecord] = []
    @Published var favoritePairs: [FavoritePair] = []
    
    init() {
        loadData()
    }
    
    func saveConversion(_ record: ConversionRecord) {
        DispatchQueue.main.async {
            self.conversionHistory.insert(record, at: 0) // Newest first
            self.saveData()
            print("✅ Saved conversion: \(record.fromCurrency) → \(record.toCurrency)")
        }
    }
    
    func addToFavorites(from: String, to: String) {
        DispatchQueue.main.async {
            // Check if already exists
            if !self.favoritePairs.contains(where: { $0.fromCurrency == from && $0.toCurrency == to }) {
                let favorite = FavoritePair(fromCurrency: from, toCurrency: to, dateAdded: Date())
                self.favoritePairs.append(favorite)
                self.saveData()
                print("⭐ Added to favorites: \(from)/\(to)")
            } else {
                print("⚠️ Already in favorites: \(from)/\(to)")
            }
        }
    }
    
    func removeFavorite(_ favorite: FavoritePair) {
        favoritePairs.removeAll { $0.id == favorite.id }
        saveData()
    }
    
    private func saveData() {
        if let historyData = try? JSONEncoder().encode(conversionHistory) {
            UserDefaults.standard.set(historyData, forKey: "conversionHistory")
        }
        if let favoritesData = try? JSONEncoder().encode(favoritePairs) {
            UserDefaults.standard.set(favoritesData, forKey: "favoritePairs")
        }
    }
    
    private func loadData() {
        if let historyData = UserDefaults.standard.data(forKey: "conversionHistory"),
           let history = try? JSONDecoder().decode([ConversionRecord].self, from: historyData) {
            conversionHistory = history
        }
        if let favoritesData = UserDefaults.standard.data(forKey: "favoritePairs"),
           let favorites = try? JSONDecoder().decode([FavoritePair].self, from: favoritesData) {
            favoritePairs = favorites
        }
    }
}
