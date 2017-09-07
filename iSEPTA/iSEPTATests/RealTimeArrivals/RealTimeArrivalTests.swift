//
// SEPTA.org, created on 9/7/2017.

import XCTest
import SeptaSchedule
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
                               scheduleType: .weekday, reverseStops: false,
                               databaseIsLoaded: true)
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
    let scheduleRequest: ScheduleRequest = {
        ScheduleRequest.dummyRequest(transitMode: .rail, routeId: "", startId: 90222, stopId: 90313)

    }()

    func testRealTimeResults_GetSomething() {
        let expectation = self.expectation(description: "myExpectation")
        provider.retrieveNextToArrive(scheduleRequest: scheduleRequest) { arrivals in
            XCTAssertGreaterThan(arrivals.count, 0)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testAsyncCalback() {

        let expectation = self.expectation(description: "myExpectation")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
    }
}
