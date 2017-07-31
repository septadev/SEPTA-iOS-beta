// SEPTA.org, created on 7/31/2017.

import XCTest
@testable import SeptaSchedule

/// SQLCommandTests purpose: Verifies that data objects are correctly returned from commands
class SQLCommandTests: XCTestCase {
    let cmd = SQLCommand()

    func testAsyncCalback() {

        let expectation = self.expectation(description: "Should Return")
        try! cmd.busDestinationBeginStops(routeId: 44, scheduleType: .weekday) { stops, _ in
            XCTAssertNotNil(stops)
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
