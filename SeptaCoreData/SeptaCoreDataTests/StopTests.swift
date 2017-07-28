// SEPTA.org, created on 7/28/17.

import XCTest
import CoreData
@testable import SeptaCoreData

class StopTests: XCTestCase {
    let setup = SetupCoreData()
    let stopName = "111 Main"
    let lat = 1.113
    let lon = 4.23332
    let wheelchairEnabled = true
    let stop_id = 232

    var unManagedStop: UnManagedStop {
        let stop = UnManagedStop(stop_id: stop_id, name: stopName, lat: lat, lon: lon, wheelchairEnabled: wheelchairEnabled)
        return stop
    }

    var moc: NSManagedObjectContext {
        return setup.uiManagedObjectContext!
    }

    override func setUp() {
        try! setup.resetPersistentStore()
    }

    func testAddStop() {
        let stop: Stop = Stop.insert(intoContext: moc, unManagedStop: unManagedStop)
        try! moc.save()
        XCTAssertNotNil(stop)
    }

    func testAddStopGetsPersisted() {
        let _ = Stop.insert(intoContext: moc, unManagedStop: unManagedStop)
        try! moc.save()
        let count = getStopCount(moc: moc)
        XCTAssertEqual(count, 1)
    }

    func getStopCount(moc: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest<Stop>(entityName: Stop.entityName)
        fetchRequest.fetchBatchSize = 20
        let results = try! moc.fetch(fetchRequest)
        return results.count
    }
}
