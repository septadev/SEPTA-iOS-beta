// Septa. 2017

import XCTest
@testable import Septa
import SeptaSchedule

/// ScheduleTests purpose: Does equatable work correctly for schedules?
class ScheduleTests: XCTestCase {

    /// Does equatable work properly for schedule
    func testDoesEquatableWorkProperlyForSchedule_Routes() {
        let schedule1 = Schedule(routes: nil, selectedRoute: nil, availableStarts: nil, selectedStart: nil, availableStops: nil, selectedStop: nil, availableTrips: nil)
        let schedule2 = Schedule(routes: [Route](), selectedRoute: nil, availableStarts: nil, selectedStart: nil, availableStops: nil, selectedStop: nil, availableTrips: nil)

        XCTAssertNotEqual(schedule1, schedule2)
    }

    /// Does equatable work properly for schedule
    func testDoesEquatableWorkProperlyForSchedule_SelectedRoute() {
        let route1 = Route(routeId: "slkjsdf", routeShortName: "lkjsdfkj", routeLongName: "sljksdflkjsd")
        let schedule1 = Schedule(routes: nil, selectedRoute: route1, availableStarts: nil, selectedStart: nil, availableStops: nil, selectedStop: nil, availableTrips: nil)
        let schedule2 = Schedule(routes: nil, selectedRoute: nil, availableStarts: nil, selectedStart: nil, availableStops: nil, selectedStop: nil, availableTrips: nil)

        XCTAssertNotEqual(schedule1, schedule2)
    }
}
