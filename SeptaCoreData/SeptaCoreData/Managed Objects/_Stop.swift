// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Stop.swift instead.

import Foundation
import CoreData

public enum StopAttributes: String {
    case lat = "lat"
    case lon = "lon"
    case name = "name"
    case stop_id = "stop_id"
    case wheelchairEnabled = "wheelchairEnabled"
}

public enum StopRelationships: String {
    case transitType = "transitType"
}

open class _Stop: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Stop"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Stop.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var lat: NSNumber?

    @NSManaged open
    var lon: NSNumber?

    @NSManaged open
    var name: String

    @NSManaged open
    var stop_id: NSNumber?

    @NSManaged open
    var wheelchairEnabled: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var transitType: TransitType?

}

