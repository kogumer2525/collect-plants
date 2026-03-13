import Foundation
import CoreData

@objc(PlantRecord)
public class PlantRecord: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var plantName: String
    @NSManaged public var scientificName: String
    @NSManaged public var imageData: Data
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var growthLevel: Int16
    @NSManaged public var confidence: Double
    @NSManaged public var locationName: String
    @NSManaged public var japaneseName: String
}

extension PlantRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlantRecord> {
        return NSFetchRequest<PlantRecord>(entityName: "PlantRecord")
    }
}
