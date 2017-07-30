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


        let busCount: Int = try! db.scalar(Table(ImportDatabase.TableNames.stopsBus).count)
        let trainCount: Int = try! db.scalar(Table(ImportDatabase.TableNames.stopsRail).count)
        XCTAssertEqual(actualCount, busCount + trainCount)
    }

    
}
