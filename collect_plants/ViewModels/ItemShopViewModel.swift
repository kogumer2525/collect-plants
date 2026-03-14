import Foundation

@Observable
class ItemShopViewModel {
    var totalPoints: Int = 0
    var allFurniture: [Furniture] = Furniture.allItems
    var furnitureCounts: [String: Int] = [:]

    private let pointManager = PointManager.shared
    private let furnitureManager = FurnitureManager.shared

    func load() {
        totalPoints = pointManager.getTotalPoints()
        furnitureCounts = furnitureManager.getAllCounts()
    }

    func purchaseFurniture(_ furniture: Furniture) -> Bool {
        if pointManager.consumePoints(furniture.cost) {
            furnitureManager.addFurniture(id: furniture.id)
            totalPoints = pointManager.getTotalPoints()
            furnitureCounts[furniture.id] = furnitureManager.getCount(forFurnitureId: furniture.id)
            return true
        }
        return false
    }

    func canAfford(_ furniture: Furniture) -> Bool {
        totalPoints >= furniture.cost
    }

    func getCount(forFurnitureId id: String) -> Int {
        furnitureCounts[id] ?? 0
    }
}
