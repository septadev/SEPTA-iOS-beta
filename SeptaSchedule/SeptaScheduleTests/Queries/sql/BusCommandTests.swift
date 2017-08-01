// SEPTA.org, created on 7/31/2017.

import XCTest
@testable import SeptaSchedule

/// SQLCommandTests purpose: Verifies that data objects are correctly returned from commands
class BusCommandTests: XCTestCase {
    let cmd = BusCommands()

    func testCallToBusStart_Saturday() {

        let expectation = self.expectation(description: "Should Return")
        let sqlQuery = SQLQuery.busStart(routeId: 44, scheduleType: .saturday)
        cmd.busStops(withQuery: sqlQuery) { stops, error in
            XCTAssertNotNil(stops)
            XCTAssertNil(error)
            XCTAssertTrue(Thread.isMainThread)
            let filtered = stops!.filter {
                return $0.stopId == 1169 && $0.stopName == "City Av & Bala Av"
            }
            XCTAssertEqual(filtered.count, 1)
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
        cmd.busStops(withQuery: sqlQuery) { stops, error in
            XCTAssertNotNil(stops)
            XCTAssertNil(error)
            XCTAssertTrue(Thread.isMainThread)
            let filtered = stops!.filter {
                return $0.stopId == 21893 && $0.stopName == "Essex Av & Woodbine Av"
            }
            XCTAssertEqual(filtered.count, 1)
            XCTAssertEqual(stops?.count, 184)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testCallToBusEnd_Saturday() {

        let expectation = self.expectation(description: "Should Return")
        let sqlQuery = SQLQuery.busEnd(routeId: 44, scheduleType: .saturday, startStopId: 638)
        cmd.busStops(withQuery: sqlQuery) { stops, error in
            XCTAssertNotNil(stops)
            XCTAssertNil(error)
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(stops?.count, 121)
            let filtered = stops!.filter {
                return $0.stopId == 6232 && $0.stopName == "City Av & Bryn Mawr Av"
            }
            XCTAssertEqual(filtered.count, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
