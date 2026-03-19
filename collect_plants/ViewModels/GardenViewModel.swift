import Foundation

@Observable
class GardenViewModel {
    var plants: [PlantRecord] = []
    var totalPoints: Int = 0
    var ownedFurnitureIDs: Set<String> = []
    var gardenCritters: [GardenCritter] = []

    private let coreDataService = CoreDataService.shared
    private let animalEventService = AnimalEventService.shared
    private let pointManager = PointManager.shared
    private let healthKitService = HealthKitService.shared

    // MARK: - ポイント・レベル

    /// 合計ポイント（植物1種類につき10pt）
    var points: Int {
        uniquePlants.count * 10
    }

    /// 庭レベル
    var level: Int {
        switch points {
        case 0..<50:    return 1
        case 50..<120:  return 2
        case 120..<250: return 3
        case 250..<450: return 4
        default:        return 5
        }
    }

    /// 次のレベルに必要なポイント
    var nextLevelPoints: Int {
        switch level {
        case 1: return 50
        case 2: return 120
        case 3: return 250
        case 4: return 450
        default: return 450
        }
    }

    // MARK: - 庭に咲く植物の数（＝ユニーク種数）

    var gardenPlantCount: Int {
        uniquePlants.count
    }

    // MARK: - ロード

    func loadGarden() {
        plants = coreDataService.fetchAllPlants()
        totalPoints = pointManager.getTotalPoints()
        ownedFurnitureIDs = coreDataService.ownedFurnitureIDs()
        animalEventService.updateCritters(level: level)
        gardenCritters = animalEventService.gardenCritters
    }

    func refreshTotalPoints() {
        totalPoints = pointManager.getTotalPoints()
    }

    // MARK: - ユニーク植物（種類ごとに1件）

    var uniquePlants: [PlantRecord] {
        var seen = Set<String>()
        return plants.filter { plant in
            let key = plant.plantName
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }
}
