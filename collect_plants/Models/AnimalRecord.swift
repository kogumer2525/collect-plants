import Foundation
import CoreData

@objc(AnimalRecord)
public class AnimalRecord: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var rarity: Int16
    @NSManaged public var icon: String
    @NSManaged public var animalDescription: String
}

extension AnimalRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AnimalRecord> {
        return NSFetchRequest<AnimalRecord>(entityName: "AnimalRecord")
    }
}
