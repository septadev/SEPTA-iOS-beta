//
//  JSONBaseTest.swift
//  SeptaScheduleTests
//
//  Created by Mark Broski on 8/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import XCTest

protocol JSONExtractable {

    func extractJSON(fileName: String) -> Data
}

extension XCTestCase: JSONExtractable {

    func extractJSON(fileName: String) -> Data {
        let bundle = Bundle(for: TestBundleToken.self)
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}

private final class TestBundleToken {}
