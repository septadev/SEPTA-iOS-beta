// SEPTA.org, created on 7/31/2017.

import XCTest
@testable import SeptaSchedule

/// SQLCommandTests purpose: Verifies that data objects are correctly returned from commands
class SQLCommandTests: XCTestCase {
    let cmd = BusCommands()

    func testCallToBusStart_Saturday() {

        let expectation = self.expectation(description: "Should Return")
        let sqlQuery = SQLQuery.busStart(routeId: 44, scheduleType: .saturday)
        cmd.availableStartingPoints(withQuery: sqlQuery) { stops, error in
            XCTAssertNotNil(stops)
            XCTAssertNil(error)
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(stops?.count, 122)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testCallToBusStart_Weekday() {

        let expectation = self.expectation(description: "Should Return")
        let sqlQuery = SQLQuery.busStart(routeId: 44, scheduleType: .weekday)
        cmd.availableStartingPoints(withQuery: sqlQuery) { stops, error in
            XCTAssertNotNil(stops)
            XCTAssertNil(error)
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(stops?.count, 184)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
