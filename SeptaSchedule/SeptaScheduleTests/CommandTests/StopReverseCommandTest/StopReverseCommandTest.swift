//
//  StopReverseCommandTest.swift
//  SeptaScheduleTests
//
//  Created by Mark Broski on 8/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import XCTest
@testable import SeptaSchedule

class StopReverseCommandTest: XCTestCase {

    func testRouteReverse() {
        let expectation = self.expectation(description: "Should Return")
        let startingTripStopId = TripStopId(start: 3076, end: 2673)
        let expectedResultTripStopId = [TripStopId(start: 3029, end: 3024)]

        StopReverseCommand.sharedInstance.reverseStops(forTransitMode: TransitMode.bus, tripStopId: startingTripStopId) { tripStopId, error in
            XCTAssertNil(error)
            XCTAssertEqual(tripStopId!, expectedResultTripStopId)

            expectation.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testTripReverse() {
        let expectation = self.expectation(description: "Should Return")
        let tripStopId = TripStopId(start: 3029, end: 3024)
        let expectedResults = [
            [1753, 1806],
            [1740, 1754],
            [1728, 1742],
            [1716, 1730],
            [1704, 1718],
            [1652, 1706],
            [1640, 1654],
        ]
        let expectedTrips: [Trip] = expectedResults.map { return Trip(departureInt: $0[0], arrivalInt: $0[1]) }
        TripReverseCommand.sharedInstance.reverseTrip(forTransitMode: .bus, tripStopId: tripStopId, scheduleType: .weekday) { trips, error in
            XCTAssertNil(error)
            guard let trips = trips else { XCTFail("No trips were returned"); return }
            for result in expectedTrips {
                XCTAssertTrue(trips.contains(result))
            }

            expectation.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testRetrieveStopsById() {
        let expectation = self.expectation(description: "Should Return")
        let tripStopId = TripStopId(start: 3029, end: 3024)
        let arrivalStop = Stop(stopId: 3024, stopName: "16th St & Cherry St", stopLatitude: 39.95561, stopLongitude: -75.166137, wheelchairBoarding: false, weekdayService: true, saturdayService: true, sundayService: true)

        let departureStop = Stop(stopId: 3029, stopName: "16th St & Dickinson St", stopLatitude: 39.931995, stopLongitude: -75.171312, wheelchairBoarding: false, weekdayService: true, saturdayService: true, sundayService: true)

        StopsByStopIdCommand.sharedInstance.retrieveStops(forTransitMode: .bus, tripStopId: tripStopId) { stops, error in
            XCTAssertNil(error)

            let actualDepartureStop = stops!.filter({ $0.stopId == departureStop.stopId }).first!
            let actualArrivalStop = stops!.filter({ $0.stopId == arrivalStop.stopId }).first!

            XCTAssertEqual(arrivalStop, actualArrivalStop)
            XCTAssertEqual(departureStop, actualDepartureStop)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testReverseRoute() {
        let expectation = self.expectation(description: "Should Return")
        let startingRoute = Route(routeId: "1", routeShortName: "routeName", routeLongName: "routeName", routeDirectionCode: .outbound)
        let expectedReverseRoute = Route(routeId: "1", routeShortName: "to Parx Casino", routeLongName: "Parx Casino to 54th-City", routeDirectionCode: .inbound)

        ReverseRouteCommand.sharedInstance.reverseRoute(forTransitMode: .bus, route: startingRoute) { routes, error in
            XCTAssertNil(error)

            let reversedRoute = routes!.first!

            XCTAssertEqual(expectedReverseRoute, reversedRoute)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
