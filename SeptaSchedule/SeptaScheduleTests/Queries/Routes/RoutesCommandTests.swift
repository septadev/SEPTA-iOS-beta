// Septa. 2017

import Foundation
import XCTest
@testable import SeptaSchedule

class RoutesCommandTests: XCTestCase {
    let tripStartCommand = TripStartCommand.sharedInstance
    let decoder = JSONDecoder()

    func testTrainRoutes_NotNil() {
        let json = extractJSON(fileName: "busRoutes")
        XCTAssertNotNil(json)
    }

    func testBusRoutes_decoding() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "busRoutes")
        let expectedResult = try! decoder.decode([Route].self, from: json)
        XCTAssertNotNil(expectedResult)
        expectation.fulfill()
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testBusRoutes_makeSet() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "busRoutes")
        let expectedResult = try! decoder.decode([Route].self, from: json)
        _ = Set(expectedResult)

        expectation.fulfill()
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testBusRoutes_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "busRoutes")
        let expectedResult = try! decoder.decode([Route].self, from: json)
        let expectedResultSet = Set(expectedResult)
        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.bus) { routes, error in
            let actualResultSet = Set(routes!)
            XCTAssertNil(error)
            XCTAssertEqual(expectedResultSet, actualResultSet)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testNHSL_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "nhslRoutes")
        let expectedResult = try! decoder.decode([Route].self, from: json)
        let expectedResultSet = Set(expectedResult)
        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.nhsl) { routes, error in
            let actualResultSet = Set(routes!)
            XCTAssertNil(error)
            XCTAssertEqual(expectedResultSet, actualResultSet)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testSubway_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "subwayRoutes")
        let expectedResult = try! decoder.decode([Route].self, from: json)
        let expectedResultSet = Set(expectedResult)
        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.subway) { routes, error in
            let actualResultSet = Set(routes!)
            XCTAssertNil(error)
            XCTAssertEqual(expectedResultSet, actualResultSet)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testRail_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "trainRoutes")
        let expectedResult = try! decoder.decode([Route].self, from: json)
        let expectedResultSet = Set(expectedResult)
        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.rail) { routes, error in
            let actualResultSet = Set(routes!)
            XCTAssertNil(error)
            XCTAssertEqual(expectedResultSet, actualResultSet)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
