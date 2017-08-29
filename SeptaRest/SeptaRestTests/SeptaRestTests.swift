//
//  SeptaRestTests.swift
//  SeptaRestTests
//
//  Created by Mark Broski on 8/29/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import XCTest
@testable import SeptaRest
import PromiseKit

class SeptaRestTests: XCTestCase {
    let client = SEPTAApiClient.defaultClient(url: "https://vnjb5kvq2b.execute-api.us-east-1.amazonaws.com/prod", apiKey: "7Nx754dd9G5YkpYoRLbi4aoNW9LtWllt1Jcbw9v8")

    func testAlerts() {
        let expectation = self.expectation(description: "Should Return")
        client.getAlerts(route: "").then { alerts -> Void in
            if let alerts = alerts?.alerts {
                XCTAssertTrue(alerts.count > 0, "Should always be some alerts")
                expectation.fulfill()
            }
        }.catch { err in
            print(err)
        }

        waitForExpectations(timeout: 10) { error in
            print(error?.localizedDescription)
        }
    }
}
