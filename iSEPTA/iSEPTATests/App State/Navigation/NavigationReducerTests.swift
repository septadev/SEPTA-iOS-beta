// SEPTA.org, created on 8/12/2017.

@testable import Septa
import XCTest

/// NavigationReducerTests purpose: Verify that the navigation state truly represents what is happening in the app.
class NavigationReducerTests: BaseStateTests {

    func testInitializationOfNavigationState() {
        let stateEntry = retrieveTestData("InitializeNavigationState")!
        let action = stateEntry.action as! InitializeNavigationState
        let stateBefore = stateEntry.stateAfter.navigationState.appStackState!
        let expectedResult = stateEntry.stateAfter.navigationState.appStackState!
        let actualResult = NavigationReducer.reduceInitializeViewAction(action: action, state: stateBefore)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testPresentModal() {
        let stateEntry = retrieveTestData("PresentModal")!
        let action = stateEntry.action as! PresentModal
        let stateBefore = stateEntry.stateAfter.navigationState.appStackState!
        let expectedResult = stateEntry.stateAfter.navigationState.appStackState!
        let actualResult = NavigationReducer.reducePresentModalAction(action: action, state: stateBefore)
        XCTAssertEqual(expectedResult, actualResult)
    }

    func testDismissModal() {
        let stateEntry = retrieveTestData("DismissModal")!
        let action = stateEntry.action as! DismissModal
        let stateBefore = stateEntry.stateAfter.navigationState.appStackState!
        let expectedResult = stateEntry.stateAfter.navigationState.appStackState!
        let actualResult = NavigationReducer.reduceDismissModalAction(action: action, state: stateBefore)
        XCTAssertEqual(expectedResult, actualResult)
    }
}
