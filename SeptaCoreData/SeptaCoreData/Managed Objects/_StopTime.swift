// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to StopTime.swift instead.

import Foundation
import CoreData

public enum StopTimeAttributes: String {
    case arrivalTime
    case stopSequence
    case stop_id
    case trip_id
}

public enum StopTimeRelationships: String {
    case stop
}

open class _StopTime: NSManagedObject {

    // MARK: - Class methods

    open class func entityName() -> String {
        return "StopTime"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _StopTime.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var arrivalTime: NSNumber?

    @NSManaged open
    var stopSequence: NSNumber?

    @NSManaged open
    var stop_id: NSNumber?

    @NSManaged open
    var trip_id: String

    // MARK: - Relationships

    @NSManaged open
    var stop: Stop?
}
