
// SEPTA.org, created on 8/7/2017.

import XCTest
@testable import Septa
import ReSwift

/// ScheduleReducerTests purpose: Each reducer will change state, these tests verify that they do it correctly.
class ScheduleReducerTests: XCTestCase {

    let action = GenericAction()

    /// Schedule should always return a transit mode
    func testThatReducerAlwaysReturnsATransitMode() {
        let state = ScheduleReducers.main(action: action, state: nil)
        XCTAssertNotNil(state.scheduleRequest?.transitMode)
    }

    /// Schedule should always return a transit mode
    func testThatReducerAlwaysReturnsATransitMode_MockPreferences() {
        let preferenceProvider = MockPreferenceProvider(preferences: [UserPreferenceKeys.preferredTransitMode: TransitMode.bus.rawValue])
        stateProviders = StateProviders(preferenceProvider: preferenceProvider)

        let state = ScheduleReducers.main(action: action, state: nil)
        XCTAssertEqual(state.scheduleRequest!.transitMode, TransitMode.bus)
    }

    /// Schedule should always return a transit mode
    func testThatReducerAlwaysReturnsATransitMode_RailIsTheRealDefault() {
        let preferenceProvider = PreferencesProvider.sharedInstance
        stateProviders = StateProviders(preferenceProvider: preferenceProvider)

        let state = ScheduleReducers.main(action: action, state: nil)
        XCTAssertEqual(state.scheduleRequest!.transitMode, TransitMode.rail)
    }
}
