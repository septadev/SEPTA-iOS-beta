

// SEPTA.org, created on 9/21/2017.

@testable import Septa
import XCTest

/// NavigationViewControllerStateToNavigationEvent purpose: How to react when the view controller state changes
class NavigationViewControllerStateToNavigationEventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTrim() {
        let currentControllers: [ViewController] = [.selectSchedules, .routesViewController, .selectStartController, .selectStopController]
        let displayControllers: [ViewController] = [.selectSchedules, .routesViewController, .selectStartController, .selectStopController]
        let newControllers: [ViewController] = [.selectSchedules]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .truncateViewStack(truncationLength):
            XCTAssertEqual(truncationLength, 1)

        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testAppend() {
        let currentControllers: [ViewController] = [.selectSchedules]
        let displayControllers: [ViewController] = [.selectSchedules]
        let newControllers: [ViewController] = [.selectSchedules, .routesViewController, .selectStartController, .selectStopController]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .appendToViewStack(viewControllers):
            XCTAssertEqual(viewControllers, [.routesViewController, .selectStartController, .selectStopController])
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testPush() {
        let currentControllers: [ViewController] = [.selectSchedules]
        let displayControllers: [ViewController] = [.selectSchedules]
        let newControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .push(viewController):
            XCTAssertEqual(viewController, .routesViewController)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testPop() {
        let currentControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let displayControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let newControllers: [ViewController] = [.selectSchedules]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case .pop:
            XCTAssertTrue(true)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testRootViewController() {
        let currentControllers: [ViewController] = []
        let displayControllers: [ViewController] = []
        let newControllers: [ViewController] = [.selectSchedules]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .rootViewController(viewController):
            XCTAssertEqual(viewController, .selectSchedules)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testSystemPop() {
        let currentControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let displayControllers: [ViewController] = [.selectSchedules]
        let newControllers: [ViewController] = [.selectSchedules]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case .systemPop:
            XCTAssertTrue(true)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testReplaceViewStack() {
        let currentControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let displayControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let newControllers: [ViewController] = [.routesViewController, .selectSchedules, .routesViewController]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case let .replaceViewStack(viewControllers):
            XCTAssertEqual(viewControllers, [.routesViewController, .selectSchedules, .routesViewController])
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testNoActionNeeded() {
        let currentControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let displayControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let newControllers: [ViewController] = [.selectSchedules, .routesViewController]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case .noActionNeeded:
            XCTAssertTrue(true)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }

    func testNextToArrive_DetailVisible() {
        let currentControllers: [ViewController] = [.nextToArriveController, .nextToArriveDetailController]
        let displayControllers: [ViewController] = [.nextToArriveController, .nextToArriveDetailController]
        let newControllers: [ViewController] = [.nextToArriveController, .nextToArriveDetailController]
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentControllers, newControllers: newControllers, displayControllers: displayControllers)

        let result = model.determineNecessaryStateAction()
        switch result {
        case .noActionNeeded:
            XCTAssertTrue(true)
        default:
            XCTFail("Incorrect state returned \(result)")
        }
    }
}
