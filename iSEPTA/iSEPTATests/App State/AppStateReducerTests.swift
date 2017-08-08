// Septa. 2017

import XCTest
@testable import Septa

/// AppStateReducerTests purpose: make sure the basic app state reducer works
class AppStateReducerTests: XCTestCase {

    /// Does the main reducer return a state
    func testDoesTheMainReducerReturnAState() {
        let action = ScheduleActions.TransitModeSelected(transitMode: .bus)
        let state = AppStateReducer.mainReducer(action: action, state: nil)
        XCTAssertNotNil(state)
    }
}
