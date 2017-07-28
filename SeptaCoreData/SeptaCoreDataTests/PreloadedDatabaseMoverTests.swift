// SEPTA.org, created on 7/28/17.

import XCTest
import CoreData
@testable import SeptaCoreData

class ProloadedDatabaseMoverTests: XCTestCase {
    let fileManager = FileManager.default
    let mover = PreloadedDatabaseMover()

    func testPreloadedURL() {
        let url = mover.preloadedZippedDatabaseURL
        XCTAssertNotNil(url)
    }

    func testDestinationURL() {
        let url = mover.databaseDestinationURL
        XCTAssertNotNil(url)
    }

    func testUnzippingDatabase() {
        mover.expandZipDatabaseFile()
        let path = mover.databaseDestinationURL!.path
        let fileExists = fileManager.fileExists(atPath: path)
        XCTAssertTrue(fileExists)
    }
}
