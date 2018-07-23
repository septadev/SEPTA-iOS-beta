

// SEPTA.org, created on 9/21/2017.

@testable import Septa
import XCTest

/// NavigationViewControllerStateToNavigationEvent purpose: How to react when the view controller state changes
class NavigationModalStateToNavigationEventTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPresentModal() {
        let currentModal: ViewController? = nil
        let newModal: ViewController? = .routesViewController

        let model = NavigationModalStateToNavigationEvent(currentModal: currentModal, newModal: newModal)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .presentModal(viewController):
            XCTAssertEqual(viewController, .routesViewController)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testDismissModal() {
        let currentModal: ViewController? = .routesViewController
        let newModal: ViewController? = nil

        let model = NavigationModalStateToNavigationEvent(currentModal: currentModal, newModal: newModal)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .dismissModal:
            break
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testNoActionNeeded() {
        let currentModal: ViewController? = .routesViewController
        let newModal: ViewController? = .routesViewController

        let model = NavigationModalStateToNavigationEvent(currentModal: currentModal, newModal: newModal)

        let result = model.determineNecessaryStateAction()
        switch result {
        case .noActionNeeded:
            break
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testDismissThenPresent() {
        let currentModal: ViewController? = .routesViewController
        let newModal: ViewController? = .selectSchedules

        let model = NavigationModalStateToNavigationEvent(currentModal: currentModal, newModal: newModal)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .dismissThenPresent(viewController):
            XCTAssertEqual(viewController, .selectSchedules)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }
}
