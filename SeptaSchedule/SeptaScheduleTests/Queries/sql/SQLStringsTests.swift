// SEPTA.org, created on 7/31/2017.

import XCTest
@testable import SeptaSchedule

/// SQLStringTests purpose: Validate that sql strings can be returned from the bundle
class SQLStringsTests: XCTestCase {

    let bundle = Bundle(for: SQLCommandStrings.self)
    let fileManager = FileManager.default
    let commandStrings = SQLCommandStrings()

    /// Verify that we can read from the bundle
    func testVerifyReadFileFromBundle() {
        let url = bundle.url(forResource: "busStart", withExtension: "sql", subdirectory: nil, localization: nil)!
        fileManager.fileExists(atPath: url.path)
    }

    /// Verify that we can pull the string from a file
    func testPullSqlCommandStringFromFile() {
        let commandString = try! commandStrings.commandStringForFileName(.busStart)
        XCTAssertNotNil(commandString)
    }
}
