import Foundation

@Observable
class GardenViewModel {
    var plants: [PlantRecord] = []
    var visitingAnimal: String?

    private let coreDataService = CoreDataService.shared
    private let animalEventService = AnimalEventService.shared

    func loadGarden() {
        plants = coreDataService.fetchAllPlants()
        let uniqueCount = coreDataService.uniquePlantCount()
        animalEventService.checkForAnimalVisit(plantSpeciesCount: uniqueCount)
        visitingAnimal = animalEventService.visitingAnimal
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
