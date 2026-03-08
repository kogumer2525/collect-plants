import CoreData

class CoreDataService {
    static let shared = CoreDataService()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "CollectPlants")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData load error: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }

    func savePlantRecord(
        plantName: String,
        scientificName: String,
        imageData: Data,
        latitude: Double,
        longitude: Double,
        locationName: String,
        confidence: Double
    ) -> PlantRecord {
        let record = PlantRecord(context: context)
        record.id = UUID()
        record.plantName = plantName
        record.scientificName = scientificName
        record.imageData = imageData
        record.latitude = latitude
        record.longitude = longitude
        record.date = Date()
        record.growthLevel = 0
        record.confidence = confidence
        record.locationName = locationName
        save()
        return record
    }

    func fetchAllPlants() -> [PlantRecord] {
        let request = PlantRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \PlantRecord.date, ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    func uniquePlantCount() -> Int {
        let plants = fetchAllPlants()
        let uniqueNames = Set(plants.map { $0.plantName })
        return uniqueNames.count
    }
}
