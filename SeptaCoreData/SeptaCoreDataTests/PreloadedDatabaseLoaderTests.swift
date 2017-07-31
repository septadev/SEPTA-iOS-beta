// SEPTA.org, created on 7/29/17.

import XCTest
import CoreData
import SQLite
@testable import SeptaCoreData

class PreloadedDatabaseLoaderTests: BaseCoreDataTests {

    func testLoader() {
        let loader = PreloadedDatabaseLoader(moc: setup.getMainQueueManagedObjectContext()!)!
        loader.loadTransitModes()

        let actualStopCount: Int = getStopCountFromMainQueue()
        let actualStopTimeCount: Int = getStopTimeCountFromMainQueue()

        let db = try! Connection(ImportDatabase().databaseDestinationURL!.path)

        let busCount: Int = try! db.scalar(Table(ImportDatabase.TableNames.stopsBus).count)
        let trainCount: Int = try! db.scalar(Table(ImportDatabase.TableNames.stopsRail).count)

        let trainStopTimesCount = try! db.scalar(Table(ImportDatabase.TableNames.stopTimesRail).count)
        XCTAssertEqual(actualStopCount, busCount + trainCount)
        XCTAssertEqual(actualStopTimeCount, trainStopTimesCount)

        let fetchRequest = NSFetchRequest<Stop>(entityName: Stop.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K == %@", StopAttributes.stop_id.rawValue, NSNumber(value: 90210))
        let testStop = try! moc.fetch(fetchRequest).first
        let count = testStop?.stopTimes.count
        XCTAssertEqual(count, 113)
    }
}
