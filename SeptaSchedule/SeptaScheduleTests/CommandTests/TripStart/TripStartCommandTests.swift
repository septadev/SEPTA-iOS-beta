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
    let trolleyTripFileName = "TripStart_Trolley_Route102_Dir0"
    let nhslTripFileName = "TripStart_NHSL_Dir1"
    let subwayTripFileName = "TripStart_Subway_Dir1"
    let railTripFileName = "TripStart_Rail_Fox_0"

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

    func testTripTrolleyStart_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: busTripFileName)
        let expectedResult: [Stop] = try! decoder.decode([Stop].self, from: json)

        let route = Route(routeId: "102", routeShortName: "", routeLongName: "", routeDirectionCode: .outbound)
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

    func testTripNHSLStart_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: nhslTripFileName)
        let expectedResult: [Stop] = try! decoder.decode([Stop].self, from: json)

        let route = Route(routeId: "NHSL", routeShortName: "", routeLongName: "", routeDirectionCode: .inbound)
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

    func testTripSubwayStart_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: subwayTripFileName)
        let expectedResult: [Stop] = try! decoder.decode([Stop].self, from: json)

        let route = Route(routeId: "BSL", routeShortName: "", routeLongName: "", routeDirectionCode: .inbound)
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

    func testTripRailStart_RunCommandAndCompare() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: railTripFileName)
        let expectedResult: [Stop] = try! decoder.decode([Stop].self, from: json)

        let route = Route(routeId: "FOX", routeShortName: "", routeLongName: "", routeDirectionCode: .outbound)
        TripStartCommand.sharedInstance.stops(forTransitMode: TransitMode.rail, forRoute: route) { stops, _ in
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
}
