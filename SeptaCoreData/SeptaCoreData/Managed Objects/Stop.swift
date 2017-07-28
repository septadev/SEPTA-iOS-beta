// SEPTA.org, created on 7/28/17.

import Foundation

import CoreData

@objc(Stop)
public final class Stop: NSManagedObject, Managed {
    public static var entityName = "Stop"
    @NSManaged fileprivate(set) var stop_id: Int
    @NSManaged fileprivate(set) var name: String
    @NSManaged fileprivate(set) var lat: Double
    @NSManaged fileprivate(set) var lon: Double
    @NSManaged fileprivate(set) var wheelchairEnabled: Bool

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "firstName", ascending: true)]
    }

    public static func insert(intoContext moc: NSManagedObjectContext, unManagedStop: UnManagedStop) -> Stop {
        let managedStop: Stop = moc.insertObject()
        managedStop.name = unManagedStop.name
        managedStop.stop_id = unManagedStop.stop_id
        managedStop.lat = unManagedStop.lat
        managedStop.lon = unManagedStop.lon
        managedStop.wheelchairEnabled = unManagedStop.wheelchairEnabled
        return managedStop
    }
}

public struct UnManagedStop {
    let stop_id: Int
    let name: String
    let lat: Double
    let lon: Double
    let wheelchairEnabled: Bool

    init(stop_id: Int, name: String, lat: Double, lon: Double, wheelchairEnabled: Bool) {
        self.stop_id = stop_id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.wheelchairEnabled = wheelchairEnabled
    }
}
