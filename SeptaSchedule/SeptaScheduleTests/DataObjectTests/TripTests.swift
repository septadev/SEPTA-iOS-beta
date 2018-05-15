// Septa. 2017

import XCTest
@testable import SeptaSchedule

///  TripTests purpose: Verify that the conversion to components works correctly.
class TripTests: XCTestCase {

    /// Verify that the components are created correctly
    func testCreationOfDateComponents() {
        let trip = Trip(departureInt: 1400, arrivalInt: 1427)
        var expectedDepartureComponents = DateComponents()
        expectedDepartureComponents.hour = 14
        expectedDepartureComponents.minute = 0

        var expectedArrivalComponets = DateComponents()
        expectedArrivalComponets.hour = 14
        expectedArrivalComponets.minute = 27

        let actualDepartureComponents = trip.departureComponents
        let actualArrivalComponents = trip.arrivalComponents
        XCTAssertEqual(expectedDepartureComponents, actualDepartureComponents)
        XCTAssertEqual(expectedArrivalComponets, actualArrivalComponents)
    }

    func testTripDuration_1() {
        let trip = Trip(departureInt: 1400, arrivalInt: 1427)
        var expectedDurationComponents = DateComponents()
        expectedDurationComponents.hour = 0
        expectedDurationComponents.minute = 27

        let actualDurationComponents = trip.tripDuration
        XCTAssertEqual(expectedDurationComponents, actualDurationComponents)
    }

    func testTripDuration_2() {
        let trip = Trip(departureInt: 1230, arrivalInt: 1427)
        var expectedDurationComponents = DateComponents()
        expectedDurationComponents.hour = 1
        expectedDurationComponents.minute = 57

        let actualDurationComponents = trip.tripDuration
        XCTAssertEqual(expectedDurationComponents, actualDurationComponents)
    }

    func testTripDuration_3() {
        let trip = Trip(departureInt: 2359, arrivalInt: 2501)
        var expectedDurationComponents = DateComponents()
        expectedDurationComponents.hour = 1
        expectedDurationComponents.minute = 2

        let actualDurationComponents = trip.tripDuration
        XCTAssertEqual(expectedDurationComponents, actualDurationComponents)
    }
}
