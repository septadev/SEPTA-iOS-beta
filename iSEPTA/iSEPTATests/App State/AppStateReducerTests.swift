// Septa. 2017

import XCTest
@testable import Septa

/// AppStateReducerTests purpose: make sure the basic app state reducer works
class AppStateReducerTests: XCTestCase {

    /// Does the main reducer return a state
    func testDoesTheMainReducerReturnAState() {
        let action = TransitModeSelected(transitMode: .bus, description: "Just picked a transit Mode")
        let state = AppStateReducer.mainReducer(action: action, state: nil)
        XCTAssertNotNil(state)
    }
}
