import Foundation
import CoreData

@objc(FurnitureRecord)
public class FurnitureRecord: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var furnitureID: String   // "bench", "fountain" など
    @NSManaged public var name: String          // 表示名
    @NSManaged public var emoji: String         // 絵文字アイコン
    @NSManaged public var purchasedDate: Date
}

extension FurnitureRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FurnitureRecord> {
        return NSFetchRequest<FurnitureRecord>(entityName: "FurnitureRecord")
    }
}
