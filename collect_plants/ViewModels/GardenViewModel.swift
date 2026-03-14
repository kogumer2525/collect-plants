import Foundation

@Observable
class GardenViewModel {
    var plants: [PlantRecord] = []
    var visitingAnimal: String?
    var totalPoints: Int = 0

    private let coreDataService = CoreDataService.shared
    private let animalEventService = AnimalEventService.shared
    private let pointManager = PointManager.shared
    private let healthKitService = HealthKitService.shared

    func loadGarden() {
        plants = coreDataService.fetchAllPlants()
        totalPoints = pointManager.getTotalPoints()
        let uniqueCount = coreDataService.uniquePlantCount()
        animalEventService.checkForAnimalVisit(plantSpeciesCount: uniqueCount)
        visitingAnimal = animalEventService.visitingAnimal
    }

    func refreshTotalPoints() {
        totalPoints = pointManager.getTotalPoints()
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
