// SEPTA.org, created on 7/29/17.

import XCTest
import CoreData
import SQLite
@testable import SeptaCoreData

class PreloadedDatabaseLoaderTests: BaseCoreDataTests {


    func testLoader() {
        let loader = PreloadedDatabaseLoader(moc: setup.getMainQueueManagedObjectContext()!)
        loader.loadTransitModes()

        let actualCount: Int = getStopCountFromMainQueue()

        let db = try! Connection(ImportDatabase().databaseDestinationURL!.path)

        let stopsTable = Table("stops_rail")
        let expectedCount: Int = try! db.scalar(stopsTable.count)
        XCTAssertEqual(actualCount, expectedCount)
    }

    
}
