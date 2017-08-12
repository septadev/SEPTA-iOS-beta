// Septa. 2017
@testable import Septa
import XCTest
/// ScheduleReducerTests purpose: Each reducer will change state, these tests verify that they do it correctly.
class ScheduleRequestReducerTests: BaseStateTests {

    func testTransitModeSelected() {
        let stateEntry = retrieveTestData("TransitModeSelected")!
        let action = stateEntry.action as! TransitModeSelected
        let stateBefore = stateEntry.stateBefore!.scheduleState.scheduleRequest!
        let expectedResult = stateEntry.stateAfter.scheduleState.scheduleRequest!
        let actualResult = ScheduleRequestReducer.reduceTransitModeSelected(action: action, scheduleRequest: stateBefore)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testRoutesSelected() {
        let stateEntry = retrieveTestData("RoutesSelected")!
        let action = stateEntry.action as! RouteSelected
        let stateBefore = stateEntry.stateBefore!.scheduleState.scheduleRequest!
        let expectedResult = stateEntry.stateAfter.scheduleState.scheduleRequest!
        let actualResult = ScheduleRequestReducer.reduceRouteSelected(action: action, scheduleRequest: stateBefore)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testRoutesLoaded() {
        let stateEntry = retrieveTestData("RoutesLoaded")!
        let action = stateEntry.action as! RoutesLoaded
        let stateBefore = stateEntry.stateBefore!.scheduleState.scheduleRequest!
        let expectedResult = stateEntry.stateAfter.scheduleState.scheduleRequest!
        let actualResult = ScheduleRequestReducer.reduceRoutesLoaded(action: action, scheduleRequest: stateBefore)
        XCTAssertEqual(expectedResult, actualResult)
    }
}
