// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Stop.swift instead.

import Foundation
import CoreData

public enum StopAttributes: String {
    case lat
    case lon
    case name
    case stop_id
    case transitTypeString
    case wheelchairEnabled
}

public enum StopRelationships: String {
    case stopTimes
    case transitType
}

open class _Stop: NSManagedObject {

    // MARK: - Class methods

    open class func entityName() -> String {
        return "Stop"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName(), in: managedObjectContext)
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
    var transitTypeString: String

    @NSManaged open
    var wheelchairEnabled: NSNumber?

    // MARK: - Relationships

    @NSManaged open
    var stopTimes: NSSet

    open func stopTimesSet() -> NSMutableSet {
        return stopTimes.mutableCopy() as! NSMutableSet
    }

    @NSManaged open
    var transitType: TransitType?
}

extension _Stop {

    open func addStopTimes(_ objects: NSSet) {
        let mutable = stopTimes.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        stopTimes = mutable.copy() as! NSSet
    }

    open func removeStopTimes(_ objects: NSSet) {
        let mutable = stopTimes.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        stopTimes = mutable.copy() as! NSSet
    }

    open func addStopTimesObject(_ value: StopTime) {
        let mutable = stopTimes.mutableCopy() as! NSMutableSet
        mutable.add(value)
        stopTimes = mutable.copy() as! NSSet
    }

    open func removeStopTimesObject(_ value: StopTime) {
        let mutable = stopTimes.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        stopTimes = mutable.copy() as! NSSet
    }
}
