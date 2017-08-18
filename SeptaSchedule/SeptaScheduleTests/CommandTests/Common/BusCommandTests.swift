// Septa. 2017

import XCTest
@testable import SeptaSchedule

/// SQLCommandTests purpose: Verifies that data objects are correctly returned from commands
class BusCommandTests: XCTestCase {
    // Xlet cmd = BusCommands()
    /*
     func testCallToBusRoutes() {

     let expectation = self.expectation(description: "Should Return")
     let sqlQuery = SQLQuery.busRoute(routeType: .bus)
     cmd.busRoutes(withQuery: sqlQuery) { routes, error in
     XCTAssertNotNil(routes)
     XCTAssertNil(error)

     XCTAssertTrue(Thread.isMainThread)
     let sampleRoute = Route(routeId: "108", routeShortName: "108", routeLongName: "UPS or Airport to 69th St TC")
     let filtered = routes!.filter { $0 == sampleRoute }
     XCTAssertEqual(filtered.count, 1)
     XCTAssertEqual(routes?.count, 127)
     expectation.fulfill()
     }

     waitForExpectations(timeout: 13) { error in
     if let error = error {
     XCTFail("waitForExpectationsWithTimeout errored: \(error)")
     }
     }
     }

     func testCallToBusStart_Saturday() {

     let expectation = self.expectation(description: "Should Return")
     let sqlQuery = SQLQuery.busStart(routeId: "44", scheduleType: .saturday)
     cmd.busStops(withQuery: sqlQuery) { stops, error in
     XCTAssertNotNil(stops)
     XCTAssertNil(error)
     XCTAssertTrue(Thread.isMainThread)
     let sampleStop = Stop(stopId: 20589, stopName: "54th St & City Av", stopLatitude: 39.99696, stopLongitude: -75.235135, wheelchairBoarding: false)
     let filtered = stops!.filter { $0 == sampleStop }

     XCTAssertEqual(filtered.count, 1)
     XCTAssertEqual(stops?.count, 122)
     expectation.fulfill()
     }

     waitForExpectations(timeout: 3) { error in
     if let error = error {
     XCTFail("waitForExpectationsWithTimeout errored: \(error)")
     }
     }
     }

     func testCallToBusStart_Weekday() {

     let expectation = self.expectation(description: "Should Return")
     let sqlQuery = SQLQuery.busStart(routeId: "44", scheduleType: .weekday)
     cmd.busStops(withQuery: sqlQuery) { stops, error in
     XCTAssertNotNil(stops)
     XCTAssertNil(error)
     XCTAssertTrue(Thread.isMainThread)
     let sampleStop = Stop(stopId: 3566, stopName: "52nd St & Overbrook Av", stopLatitude: 39.995615, stopLongitude: -75.231605, wheelchairBoarding: false)
     let filtered = stops!.filter { $0 == sampleStop }
     XCTAssertEqual(filtered.count, 1)
     XCTAssertEqual(stops?.count, 184)
     expectation.fulfill()
     }

     waitForExpectations(timeout: 3) { error in
     if let error = error {
     XCTFail("waitForExpectationsWithTimeout errored: \(error)")
     }
     }
     }

     func testCallToBusEnd_Saturday() {

     let expectation = self.expectation(description: "Should Return")
     let sqlQuery = SQLQuery.busEnd(routeId: "44", scheduleType: .saturday, startStopId: 694)
     cmd.busStops(withQuery: sqlQuery) { stops, error in
     XCTAssertNotNil(stops)
     XCTAssertNil(error)
     XCTAssertTrue(Thread.isMainThread)
     let sampleStop = Stop(stopId: 30592, stopName: "Old Lancaster Rd & City Line Av", stopLatitude: -75.235548, stopLongitude: -75.235548, wheelchairBoarding: false)
     let filtered = stops!.filter { $0 == sampleStop }
     XCTAssertEqual(filtered.count, 1)
     XCTAssertEqual(stops?.count, 58)
     expectation.fulfill()
     }

     waitForExpectations(timeout: 3) { error in
     if let error = error {
     XCTFail("waitForExpectationsWithTimeout errored: \(error)")
     }
     }
     }

     func testCallToBusTrip_Saturday() {

     let expectation = self.expectation(description: "Should Return")
     let sqlQuery = SQLQuery.busTrip(routeId: "44", scheduleType: .saturday, startStopId: 694, endStopId: 638)
     cmd.busTrips(withQuery: sqlQuery) { trips, error in
     XCTAssertNotNil(trips)
     XCTAssertNil(error)
     XCTAssertTrue(Thread.isMainThread)
     let sampleTrip = Trip(departureInt: 1412, arrivalInt: 1508)
     let filtered = trips!.filter { $0 == sampleTrip }
     XCTAssertEqual(filtered.count, 1)
     XCTAssertEqual(trips?.count, 20)
     expectation.fulfill()
     }

     waitForExpectations(timeout: 3) { error in
     if let error = error {
     XCTFail("waitForExpectationsWithTimeout errored: \(error)")
     }
     }
     }*/

    func testThis() {
        XCTAssertTrue(true)
    }
}
