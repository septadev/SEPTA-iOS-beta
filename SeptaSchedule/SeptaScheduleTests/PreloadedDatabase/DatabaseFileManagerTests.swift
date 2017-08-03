

import XCTest
import Zip
@testable import SeptaSchedule

class DatabaseFileManagerTests: XCTestCase {
    let bundle = Bundle(for: DatabaseFileManager.self)
    let databaseFileManager = DatabaseFileManager()
    let fileManager = FileManager.default
    let databaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("SEPTA.sqlite")

    let dbName = "SEPTA.sqlite"

    /// Make sure the documents directory always exists
    func testDocumentsDirectoryExists() {
        XCTAssertNotNil(databaseFileManager.documentDirectoryURL)
    }

    /// Verify that we know when the database file is in the documents directory
    func testVerifyDatabaseFileExistenceInDocumentsDirectory() {
        deleteDatabaseIfItExists()
        let actualResult = databaseFileManager.databaseFileExistsInDocumentsDirectory
        XCTAssertEqual(actualResult, false)
    }

    /// Verify that we know when the database file is in the documents directory
    func testVerifyDatabaseFileExistenceInDocumentsDirectory_AfterManualCopy() {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let preloadedDatabaseFile = bundle.url(forResource: "SEPTA", withExtension: "zip")!

        do {
            try Zip.unzipFile(preloadedDatabaseFile, destination: documentsDirectory, overwrite: true, password: nil, progress: nil)
        } catch {
            XCTFail("Failure to unzip")
        }

        let actualResult = databaseFileManager.databaseFileExistsInDocumentsDirectory
        XCTAssertEqual(actualResult, true)
    }

    /// Verify that the preloaded database can be unzipped to the documents directory
    func testVerifyUnzipToDocumentsDirectory() {
        deleteDatabaseIfItExists()
        let _ = try! databaseFileManager.unzipFileToDocumentsDirectoryIfNecessary()
        let fileExists = fileManager.fileExists(atPath: databaseURL.path)
        XCTAssertTrue(fileExists)
    }

    func deleteDatabaseIfItExists() {
        // Delete the file if it is there
        if fileManager.fileExists(atPath: databaseURL.path) {
            try! fileManager.removeItem(at: databaseURL)
        }
    }
}
