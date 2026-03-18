import Foundation

@Observable
class ItemShopViewModel {
    var totalPoints: Int = 0
    var allFurniture: [Furniture] = Furniture.allItems
    var furnitureCounts: [String: Int] = [:]

    private let pointManager = PointManager.shared
    private let furnitureManager = FurnitureManager.shared
    private let coreDataService = CoreDataService.shared

    func load() {
        totalPoints = pointManager.getTotalPoints()
        furnitureCounts = furnitureManager.getAllCounts()
    }

    func purchaseFurniture(_ furniture: Furniture) -> Bool {
        if pointManager.consumePoints(furniture.cost) {
            furnitureManager.addFurniture(id: furniture.id)
            coreDataService.purchaseFurniture(furnitureID: furniture.id, name: furniture.name, emoji: "")
            totalPoints = pointManager.getTotalPoints()
            furnitureCounts[furniture.id] = furnitureManager.getCount(forFurnitureId: furniture.id)
            NotificationCenter.default.post(name: .furniturePurchased, object: nil)
            return true
        }
        return false
    }

    func canAfford(_ furniture: Furniture) -> Bool {
        totalPoints >= furniture.cost && !isSoldOut(furniture)
    }

    func isSoldOut(_ furniture: Furniture) -> Bool {
        (furnitureCounts[furniture.id] ?? 0) >= 1
    }

    func getCount(forFurnitureId id: String) -> Int {
        furnitureCounts[id] ?? 0
    }
}
