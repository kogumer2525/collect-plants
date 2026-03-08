import Foundation

@Observable
class DictionaryViewModel {
    var plants: [PlantRecord] = []

    private let coreDataService = CoreDataService.shared

    func loadPlants() {
        plants = coreDataService.fetchAllPlants()
    }

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
