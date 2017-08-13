// Septa. 2017

import Foundation
import XCTest
@testable import SeptaSchedule

class RoutesCommandTests: XCTestCase {
    let routesCommand = RoutesCommand.sharedInstance
    let decoder = JSONDecoder()

    func testTrainRoutes_NotNil() {
        let json = extractJSON(fileName: "trainRoutes")
        XCTAssertNotNil(json)
    }

    func testTrainRoutes() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "trainRoutes")
        var expectedResult = try! decoder.decode([Route].self, from: json)
        expectedResult.sort { $0.routeId < $1.routeId
        }

        routesCommand.routes(forTransitMode: .rail) { routes, error in
            var actualResult = routes!
            actualResult.sort { $0.routeId < $1.routeId }
            XCTAssertEqual(expectedResult, actualResult)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testBusRoutes() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "busRoutes")
        var expectedResult = try! decoder.decode([Route].self, from: json)
        expectedResult.sort { $0.routeId < $1.routeId }

        routesCommand.routes(forTransitMode: .bus) { routes, error in
            var actualResult = routes!
            actualResult.sort { $0.routeId < $1.routeId }
            XCTAssertEqual(expectedResult, actualResult)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testSubwayRoutes() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "subwayRoutes")
        var expectedResult = try! decoder.decode([Route].self, from: json)
        expectedResult.sort { $0.routeId < $1.routeId }
        routesCommand.routes(forTransitMode: .subway) { routes, error in
            var actualResult = routes!
            actualResult.sort { $0.routeId < $1.routeId }
            XCTAssertEqual(expectedResult, actualResult)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testNHSLRoutes() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "nhslRoutes")
        var expectedResult = try! decoder.decode([Route].self, from: json)
        expectedResult.sort { $0.routeId < $1.routeId }
        routesCommand.routes(forTransitMode: .nhsl) { routes, error in
            var actualResult = routes!
            actualResult.sort { $0.routeId < $1.routeId }
            XCTAssertEqual(expectedResult, actualResult)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testTrolleyRoutes() {
        let expectation = self.expectation(description: "Should Return")
        let json = extractJSON(fileName: "trolleyRoutes")
        var expectedResult = try! decoder.decode([Route].self, from: json)
        expectedResult.sort { $0.routeId < $1.routeId }
        routesCommand.routes(forTransitMode: .trolley) { routes, error in
            var actualResult = routes!
            actualResult.sort { $0.routeId < $1.routeId }
            XCTAssertEqual(expectedResult, actualResult)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
