// SEPTA.org, created on 8/1/17.

// SEPTA.org, created on 8/1/2017.

import XCTest
@testable import Septa

///  RoutesViewModelTests purpose: Test the routes view model

class RoutesViewModelTests: XCTestCase {

    class RouteCellMock: RouteCellDisplayable {
        var shortName ""
        var longName = ""
        func setShortName(text: String) {
            shortName = text
        }

        func setLongName(text: String) {
            longName = text
        }
    }

    /// Verify that labels are set correctly on route cell
    func testRouteCell() {
        let viewModel = RoutesViewModel()
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
