// Septa. 2017

@testable import SeptaSchedule
import XCTest

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
