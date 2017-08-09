// Septa. 2017

import XCTest
@testable import Septa
import ReSwift

/// ScheduleActionsTests purpose: Sending Schedule Actions Results in the Correct State
class ScheduleActionsTests: XCTestCase {

    /// Schedule should always return a transit mode
    func testViewschedulesShouldAlwaysReturnATransitMode() {
        store.dispatch(ScheduleActions.WillViewSchedules())
        let transitMode = store.state.scheduleState.scheduleRequest?.transitMode
        XCTAssertNotNil(transitMode)
    }

    /// When selecting a transit mode, the model should be updated
    func testTransitmodeselectedProducesModelUpdate() {
        store.dispatch(ScheduleActions.WillViewSchedules())
        let selectedTransitMode = TransitMode.trolley
        let action = ScheduleActions.TransitModeSelected(transitMode: selectedTransitMode)
        store.dispatch(action)
        let actualTransitMode = store.state.scheduleState.scheduleRequest?.transitMode
        XCTAssertEqual(selectedTransitMode, actualTransitMode)
    }

    /// When selecting a transit mode, preferences should be updated
    func testTransitmodeselectedProducesModelUpdate_AndUpdatesPreferences() {
        store.dispatch(ScheduleActions.WillViewSchedules())
        let selectedTransitMode = TransitMode.nhsl
        let action = ScheduleActions.TransitModeSelected(transitMode: selectedTransitMode)
        store.dispatch(action)
        let transitModeString = stateProviders.preferenceProvider.stringPreference(forKey: .preferredTransitMode)!
        let actualTransitMode = TransitMode(rawValue: transitModeString)!
        XCTAssertEqual(selectedTransitMode, actualTransitMode)
    }
}
