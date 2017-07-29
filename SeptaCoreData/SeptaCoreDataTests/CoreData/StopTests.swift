// SEPTA.org, created on 7/28/17.

import XCTest
import CoreData
@testable import SeptaCoreData

class StopTests: BaseCoreDataTests {

    let stopName = "111 Main"
    let lat: NSNumber = 1.113
    let lon: NSNumber = 4.23332
    let wheelchairEnabled = true
    let stop_id: NSNumber = 232

    func testThatSaveWorks() {
        let transitStop = Stop(managedObjectContext: moc)!
        transitStop.name = stopName
        transitStop.lat = lat
        transitStop.lon = lon
        transitStop.wheelchairEnabled = true
        transitStop.stop_id = stop_id

        do {
            try moc.save()
        } catch {
            XCTFail(error.localizedDescription)
        }
        moc.reset()
        let count = getStopCountFromMainQueue()
        XCTAssertEqual(count, 1)
    }

    
}
