// Septa. 2017

import XCTest
@testable import Septa

/// AppStateReducerTests purpose: make sure the basic app state reducer works
class AppStateReducerTests: XCTestCase {

    /// Can I make a state and does it get created
    func testTestMainReducer() {
        mainStore.dispatch(ToggleFeature())
        XCTAssertNotNil(mainStore.state)
    }

    func testAsyncCalback() {

        let expectation = self.expectation(description: "myExpectation")
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
