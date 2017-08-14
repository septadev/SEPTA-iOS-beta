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

    func testTripStartBus_makeSet() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: busTripFileName)
        let expectedResult: [Stop] = try! decoder.decode([Stop].self, from: json)
        XCTAssertNotNil(expectedResult)
        _ = Set(expectedResult)
        expectation.fulfill()
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testTripBusStart_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: busTripFileName)
        let expectedResult: [Stop] = try! decoder.decode([Stop].self, from: json)

        let route = Route(routeId: "44", routeShortName: "", routeLongName: "", routeDirectionCode: .inbound)
        TripStartCommand.sharedInstance.stops(forTransitMode: TransitMode.bus, forRoute: route) { stops, _ in
            guard let stops = stops else { XCTFail("Should have returned some records"); return }
            for stop in expectedResult {
                XCTAssertTrue(stops.contains(stop), "Could not find \(stop)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 25) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

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
