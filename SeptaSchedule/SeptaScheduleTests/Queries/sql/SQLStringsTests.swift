// Septa. 2017

import XCTest
@testable import SeptaSchedule

/// SQLStringTests purpose: Validate that sql strings can be returned from the bundle
class SQLStringsTests: XCTestCase {

    let bundle = Bundle(for: SQLCommandTemplate.self)
    let fileManager = FileManager.default
    let commandStrings = SQLCommandTemplate()

    /// Verify that we can read from the bundle
    func testVerifyReadFileFromBundle_RailRoute() {
        let url = bundle.url(forResource: "railRoute", withExtension: "sql", subdirectory: nil, localization: nil)!
        fileManager.fileExists(atPath: url.path)
    }

    func testVerifyReadFileFromBundle_BusRoute() {
        let url = bundle.url(forResource: "busRoute", withExtension: "sql", subdirectory: nil, localization: nil)!
        fileManager.fileExists(atPath: url.path)
    }

    func testVerifyReadFileFromBundle_NHSLRoute() {
        let url = bundle.url(forResource: "NHSLRoute", withExtension: "sql", subdirectory: nil, localization: nil)!
        fileManager.fileExists(atPath: url.path)
    }

    func testVerifyReadFileFromBundle_SubwayRoute() {
        let url = bundle.url(forResource: "subwayRoute", withExtension: "sql", subdirectory: nil, localization: nil)!
        fileManager.fileExists(atPath: url.path)
    }

    func testVerifyReadFileFromBundle_TrolleyRoute() {
        let url = bundle.url(forResource: "trolleyRoute", withExtension: "sql", subdirectory: nil, localization: nil)!
        fileManager.fileExists(atPath: url.path)
    }
}
