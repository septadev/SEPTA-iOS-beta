// Septa. 2017

import XCTest
@testable import SeptaSchedule

/// SQLConnectionTests purpose: Verifies that we can make a connection to the database
class SQLConnectionTests: XCTestCase {

    func testConnectionWhenThereIsNoDatabase() {
        let testFileManager = DatabaseFileManagerTests()
        testFileManager.deleteDatabaseIfItExists()
        do {
            _ = try SQLConnection.sqlConnection()

        } catch {
            XCTFail("Couldn't make connection")
        }
    }
}
