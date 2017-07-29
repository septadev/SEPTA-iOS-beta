// SEPTA.org, created on 7/29/17.

import XCTest
import CoreData
@testable import SeptaCoreData

class PreloadedDatabaseLoaderTests: XCTestCase {

    let setup = SetupCoreData.sharedInstance

    override func setUp() {
        try! setup.destroyPersistentStore()
        try! setup.createPersistentStore()
        
    }

    func testLoader() {
        let loader = PreloadedDatabaseLoader(moc: setup.getMainQueueManagedObjectContext()!)
        loader.loadRailStops()
    }
}
