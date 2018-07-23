// Septa. 2017

import Foundation
@testable import SeptaSchedule
import XCTest

class DatabaseTablesTest: XCTestCase {
    func testNames() {
        XCTAssertEqual(DatabaseTables.stopsRail, "stops_rail")
        XCTAssertEqual(DatabaseTables.stopsBus, "stops_bus")
        XCTAssertEqual(DatabaseTables.stopTimesRail, "stop_times_rail")
        XCTAssertEqual(DatabaseTables.stopTimesBus, "stop_times_bus")
        XCTAssertEqual(DatabaseTables.tripsBus, "trips_bus")
        XCTAssertEqual(DatabaseTables.tripsRail, "trips_rail")
        XCTAssertEqual(DatabaseTables.routesBus, "routes_bus")
        XCTAssertEqual(DatabaseTables.routesRail, "routes_rail")
    }
}
