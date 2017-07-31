// SEPTA.org, created on 7/31/2017.

import XCTest
@testable import SeptaSchedule

/// SQLCommandTests purpose: Verifies that data objects are correctly returned from commands
class SQLCommandTests: XCTestCase {
    let cmd = BusCommands()

    func testCallToBusStart() {

        let expectation = self.expectation(description: "Should Return")
        cmd.availableStartingPoints(onRoute: 44, scheduleType: .saturday) { stops, _ in
            XCTAssertNotNil(stops)
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
}
