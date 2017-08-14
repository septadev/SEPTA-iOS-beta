//
//  TripStartCommandTests.swift
//  SeptaScheduleTests
//
//  Created by Mark Broski on 8/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import XCTest
@testable import SeptaSchedule

class TripStartCommandTests: XCTestCase {
    let busTripFileName = "TripStart_Route44_Dir1"

    let decoder = JSONDecoder()

    func testTripStart_NotNil() {
        let json = extractJSON(fileName: busTripFileName)
        XCTAssertNotNil(json)
    }

    func testTripStartBus_decoding() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: busTripFileName)
        let expectedResult = try! decoder.decode([Stop].self, from: json)
        XCTAssertNotNil(expectedResult)
        expectation.fulfill()
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    //
    //    func testTripStartBus_makeSet() {
    //        let expectation = self.expectation(description: "Should Return")
    //        let json = extractJSON(fileName: busTripFileName)
    //        let expectedResult = try! decoder.decode([Stop].self, from: json)
    //        _ = Set(expectedResult)
    //
    //        expectation.fulfill()
    //        waitForExpectations(timeout: 2) { error in
    //            if let error = error {
    //                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //            }
    //        }
    //    }
    //
    //    func testBusRoutes_RunCommandAndCompare() {
    //        let expectation = self.expectation(description: "Should Return")
    //        let json = extractJSON(fileName: "busRoutes")
    //        let expectedResult = try! decoder.decode([Route].self, from: json)
    //        let expectedResultSet = Set(expectedResult)
    //        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.bus) { routes, error in
    //            let actualResultSet = Set(routes!)
    //            XCTAssertNil(error)
    //            XCTAssertEqual(expectedResultSet, actualResultSet)
    //            expectation.fulfill()
    //        }
    //
    //        waitForExpectations(timeout: 2) { error in
    //            if let error = error {
    //                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //            }
    //        }
    //    }
    //
    //    func testNHSL_RunCommandAndCompare() {
    //        let expectation = self.expectation(description: "Should Return")
    //        let json = extractJSON(fileName: "nhslRoutes")
    //        let expectedResult = try! decoder.decode([Route].self, from: json)
    //        let expectedResultSet = Set(expectedResult)
    //        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.nhsl) { routes, error in
    //            let actualResultSet = Set(routes!)
    //            XCTAssertNil(error)
    //            XCTAssertEqual(expectedResultSet, actualResultSet)
    //            expectation.fulfill()
    //        }
    //
    //        waitForExpectations(timeout: 2) { error in
    //            if let error = error {
    //                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //            }
    //        }
    //    }
    //
    //    func testSubway_RunCommandAndCompare() {
    //        let expectation = self.expectation(description: "Should Return")
    //        let json = extractJSON(fileName: "subwayRoutes")
    //        let expectedResult = try! decoder.decode([Route].self, from: json)
    //        let expectedResultSet = Set(expectedResult)
    //        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.subway) { routes, error in
    //            let actualResultSet = Set(routes!)
    //            XCTAssertNil(error)
    //            XCTAssertEqual(expectedResultSet, actualResultSet)
    //            expectation.fulfill()
    //        }
    //
    //        waitForExpectations(timeout: 2) { error in
    //            if let error = error {
    //                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //            }
    //        }
    //    }
    //
    //    func testRail_RunCommandAndCompare() {
    //        let expectation = self.expectation(description: "Should Return")
    //        let json = extractJSON(fileName: "trainRoutes")
    //        let expectedResult = try! decoder.decode([Route].self, from: json)
    //        let expectedResultSet = Set(expectedResult)
    //        RoutesCommand.sharedInstance.routes(forTransitMode: TransitMode.rail) { routes, error in
    //            let actualResultSet = Set(routes!)
    //            XCTAssertNil(error)
    //            XCTAssertEqual(expectedResultSet, actualResultSet)
    //            expectation.fulfill()
    //        }
    //
    //        waitForExpectations(timeout: 2) { error in
    //            if let error = error {
    //                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
    //            }
    //        }
    //    }
}
