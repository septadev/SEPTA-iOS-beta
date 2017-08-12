//
//  BaseStateTest.swift
//  iSEPTATests
//
//  Created by Mark Broski on 8/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import XCTest
@testable import Septa

class BaseStateTests {
    let bundle = Bundle(for: NavigationReducerTests.self)
    let decoder = JSONDecoder()

    func retrieveTestData(_ fileName: String) -> StateLogEntry? {
        let url = bundle.url(forResource: fileName, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let stateEntry = try! decoder.decode(StateLogEntry.self, from: data)
        return stateEntry
    }
}
