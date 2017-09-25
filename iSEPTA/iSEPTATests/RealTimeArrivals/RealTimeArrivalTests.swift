//
// SEPTA.org, created on 9/7/2017.

import XCTest
import SeptaSchedule
import SeptaRest
import CoreLocation
@testable import Septa

extension Route {
    static func dummyRoute(routeId: String) -> Route {
        return Route(routeId: routeId, routeShortName: "", routeLongName: "", routeDirectionCode: .inbound)
    }
}

extension Stop {
    static func dummyStop(stopId: Int) -> Stop {

        return Stop(stopId: stopId, stopName: "", stopLatitude: 0, stopLongitude: 0, wheelchairBoarding: false, weekdayService: false, saturdayService: false, sundayService: false)
    }
}

extension ScheduleRequest {

    static func dummyRequest(transitMode: TransitMode, routeId: String, startId: Int, stopId: Int) -> ScheduleRequest {
        return ScheduleRequest(transitMode: transitMode,
                               selectedRoute: Route.dummyRoute(routeId: routeId),
                               selectedStart: Stop.dummyStop(stopId: startId),
                               selectedEnd: Stop.dummyStop(stopId: stopId),
                               scheduleType: .weekday, reverseStops: false)
    }
}

/// RealTimeArrivalTests purpose: Testing the Real Time arrival api
class RealTimeArrivalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    let provider = NextToArriveProvider.sharedInstance
    let scheduleRequest_rail: ScheduleRequest = {
        ScheduleRequest.dummyRequest(transitMode: .rail, routeId: "", startId: 90222, stopId: 90313)

    }()

    let scheduleRequest_bus: ScheduleRequest = {
        ScheduleRequest.dummyRequest(transitMode: .bus, routeId: "16", startId: 515, stopId: 136)

    }()

    func testRealTimeResultsRail_GetSomething() {
        let expectation = self.expectation(description: "myExpectation")
        var trips = [NextToArriveTrip]()
        provider.retrieveNextToArrive(scheduleRequest: scheduleRequest_rail) { realTimeArrivals in
            XCTAssertGreaterThan(realTimeArrivals.count, 0)
            for realTimeArrival in realTimeArrivals {
                let startStop = self.mapStart(realTimeArrival: realTimeArrival)
                let endStop = self.mapEnd(realTimeArrival: realTimeArrival)
                let vehicleLocation = self.mapVehicleLocation(realTimeArrival: realTimeArrival)
                let connectionLocation = self.mapConnectionStation(realTimeArrival: realTimeArrival)
                XCTAssertNotNil(startStop)
                XCTAssertNotNil(endStop)
                if let startStop = startStop, let endStop = endStop {
                    let nextToArriveTrip = NextToArriveTrip(startStop: startStop, endStop: endStop, vehicleLocation: vehicleLocation!, connectionLocation: connectionLocation)
                    trips.append(nextToArriveTrip)
                }
                XCTAssertTrue(trips.count > 0)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testRealTimeResultsBus_GetSomething() {
        let expectation = self.expectation(description: "myExpectation")
        var trips = [NextToArriveTrip]()
        provider.retrieveNextToArrive(scheduleRequest: scheduleRequest_bus) { realTimeArrivals in
            XCTAssertGreaterThan(realTimeArrivals.count, 0)
            for realTimeArrival in realTimeArrivals {
                let startStop = self.mapStart(realTimeArrival: realTimeArrival)
                let endStop = self.mapEnd(realTimeArrival: realTimeArrival)
                let vehicleLocation = self.mapVehicleLocation(realTimeArrival: realTimeArrival)
                let connectionLocation = self.mapConnectionStation(realTimeArrival: realTimeArrival)
                XCTAssertNotNil(startStop)
                XCTAssertNotNil(endStop)
                if let startStop = startStop, let endStop = endStop {
                    let nextToArriveTrip = NextToArriveTrip(startStop: startStop, endStop: endStop, vehicleLocation: vehicleLocation!, connectionLocation: connectionLocation)
                    trips.append(nextToArriveTrip)
                }
                XCTAssertTrue(trips.count > 0)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func mapRealTimeArrival(_ realTimeArrival: RealTimeArrival) {
        XCTAssertNotNil(realTimeArrival)
        print(realTimeArrival)
    }

    func mapStart(realTimeArrival a: RealTimeArrival) -> NextToArriveStop? {
        let formatter = DateFormatters.networkFormatter
        guard let arrivalTimeString = a.orig_arrival_time,
            let arrivalTime = formatter.date(from: arrivalTimeString),
            let departureTimeString = a.orig_departure_time,

            let departureTime = formatter.date(from: departureTimeString) else {
            return nil
        }
        return NextToArriveStop(routeId: a.orig_line_route_id!,
                                routeName: a.orig_line_route_name!,
                                tripId: Int(a.orig_line_trip_id ?? ""),
                                arrivalTime: arrivalTime,
                                departureTime: departureTime,
                                lastStopId: Int(a.orig_last_stop_id ?? ""),
                                lastStopName: a.orig_last_stop_name,
                                delayMinutes: a.orig_delay_minutes,
                                direction: RouteDirectionCode.fromNetwork(a.orig_line_direction ?? ""))
    }

    func mapEnd(realTimeArrival a: RealTimeArrival) -> NextToArriveStop? {
        let formatter = DateFormatters.networkFormatter
        guard let arrivalTimeString = a.term_arrival_time,
            let arrivalTime = formatter.date(from: arrivalTimeString),
            let departureTimeString = a.term_departure_time,
            let departureTime = formatter.date(from: departureTimeString) else {
            return nil
        }
        return NextToArriveStop(routeId: a.term_line_route_id!,
                                routeName: a.term_line_route_name!,
                                tripId: Int(a.term_line_trip_id ?? ""),
                                arrivalTime: arrivalTime,
                                departureTime: departureTime,
                                lastStopId: Int(a.term_last_stop_id ?? ""),
                                lastStopName: a.term_last_stop_name,
                                delayMinutes: a.term_delay_minutes,
                                direction: RouteDirectionCode.fromNetwork(a.term_line_direction ?? ""))
    }

    func mapVehicleLocation(realTimeArrival a: RealTimeArrival) -> VehicleLocation? {
        var firstLegLocation = CLLocationCoordinate2D()
        if let location = mapCoordinateFromString(latString: String(describing: a.vehicle_lat), lonString: String(describing: a.vehicle_lon)) {
            firstLegLocation = location
        } else if let location = mapCoordinateFromString(latString: String(describing: a.orig_vehicle_lat), lonString: String(describing: a.orig_vehicle_lon)) {
            firstLegLocation = location
        }
        let secondLegLocation = mapCoordinateFromString(latString: String(describing: a.term_vehicle_lat), lonString: String(describing: a.term_vehicle_lon)) ?? CLLocationCoordinate2D()

        return VehicleLocation(firstLegLocation: firstLegLocation, secondLegLocation: secondLegLocation)
    }

    func mapConnectionStation(realTimeArrival a: RealTimeArrival) -> NextToArriveConnectionStation? {
        guard let stopName = a.connection_station_name else { return nil }

        return NextToArriveConnectionStation(stopId: a.connection_station_id, stopName: stopName)
    }

    func mapCoordinateFromString(latString: String?, lonString: String?) -> CLLocationCoordinate2D? {
        guard
            let latString = latString,
            let latDegrees = CLLocationDegrees(latString),
            let lonString = lonString,
            let lonDegrees = CLLocationDegrees(lonString) else { return nil }

        return CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees)
    }

    func testAsyncCalback() {

        let expectation = self.expectation(description: "myExpectation")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
    }
}

enum NextToArriveTripStop {
    case start
    case end
}
