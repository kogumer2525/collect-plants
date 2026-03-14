import Foundation

class FurnitureManager {
    static let shared = FurnitureManager()

    private let userDefaults = UserDefaults.standard
    private let furnitureCountPrefix = "furnitureCount_"

    private init() {}

    // MARK: - Get Count
    func getCount(forFurnitureId id: String) -> Int {
        userDefaults.integer(forKey: "\(furnitureCountPrefix)\(id)")
    }

    // MARK: - Add Furniture
    func addFurniture(id: String, quantity: Int = 1) {
        let current = getCount(forFurnitureId: id)
        userDefaults.set(current + quantity, forKey: "\(furnitureCountPrefix)\(id)")
    }

    // MARK: - Get All Counts
    func getAllCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for furniture in Furniture.allItems {
            counts[furniture.id] = getCount(forFurnitureId: furniture.id)
        }
        return counts
    }

    // MARK: - Reset (for testing)
    func reset() {
        for furniture in Furniture.allItems {
            userDefaults.removeObject(forKey: "\(furnitureCountPrefix)\(furniture.id)")
        }
    }
}
