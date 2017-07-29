// SEPTA.org, created on 7/28/17.

import XCTest
import CoreData
@testable import SeptaCoreData

class ProloadedDatabaseMoverTests: XCTestCase {
    let fileManager = FileManager.default
    let importDatabase = ImportDatabase()

    func testPreloadedURL() {
        let url = importDatabase.preloadedZippedDatabaseURL
        XCTAssertNotNil(url)
    }

    func testDestinationURL() {
        let url = importDatabase.databaseDestinationURL
        XCTAssertNotNil(url)
    }

    func testUnzippingDatabase() {
        let dbURL = importDatabase.databaseDestinationURL!
        let dbPath = dbURL.path
        if fileManager.fileExists(atPath: dbPath) {
            try! fileManager.removeItem(at: dbURL)
        }
        let mover = PreloadedDatabaseMover()
        mover.expandZipDatabaseFile()

        let fileExists = fileManager.fileExists(atPath: dbPath)
        XCTAssertTrue(fileExists)
    }
}
