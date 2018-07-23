// Septa. 2017

@testable import Septa
import XCTest

/// AppStateReducerTests purpose: make sure the basic app state reducer works
class AppStateReducerTests: XCTestCase {
    /// Does the main reducer return a state
    func testDoesTheMainReducerReturnAState() {
        let action = TransitModeSelected(transitMode: .bus, description: "Just picked a transit Mode")
        let state = AppStateReducer.mainReducer(action: action, state: nil)
        XCTAssertNotNil(state)
    }
}
