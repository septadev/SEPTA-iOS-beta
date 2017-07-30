// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TransitType.swift instead.

import Foundation
import CoreData

public enum TransitTypeAttributes: String {
    case name
}

public enum TransitTypeRelationships: String {
    case stops
}

open class _TransitType: NSManagedObject {

    // MARK: - Class methods

    open class func entityName() -> String {
        return "TransitType"
    }

    open class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _TransitType.entity(managedObjectContext: managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var name: String

    // MARK: - Relationships

    @NSManaged open
    var stops: NSSet

    open func stopsSet() -> NSMutableSet {
        return stops.mutableCopy() as! NSMutableSet
    }
}

extension _TransitType {

    open func addStops(_ objects: NSSet) {
        let mutable = stops.mutableCopy() as! NSMutableSet
        mutable.union(objects as Set<NSObject>)
        stops = mutable.copy() as! NSSet
    }

    open func removeStops(_ objects: NSSet) {
        let mutable = stops.mutableCopy() as! NSMutableSet
        mutable.minus(objects as Set<NSObject>)
        stops = mutable.copy() as! NSSet
    }

    open func addStopsObject(_ value: Stop) {
        let mutable = stops.mutableCopy() as! NSMutableSet
        mutable.add(value)
        stops = mutable.copy() as! NSSet
    }

    open func removeStopsObject(_ value: Stop) {
        let mutable = stops.mutableCopy() as! NSMutableSet
        mutable.remove(value)
        stops = mutable.copy() as! NSSet
    }
}
