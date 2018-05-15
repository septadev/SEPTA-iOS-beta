// Septa. 2017

import Foundation
import XCTest
@testable import Septa

class BaseStateTests {
    let bundle = Bundle(for: NavigationReducerTests.self)
    let decoder = JSONDecoder()
    //
    //    func retrieveTestData(_ fileName: String) -> StateLogEntry? {
    //        let url = bundle.url(forResource: fileName, withExtension: "json")!
    //        let data = try! Data(contentsOf: url)
    //        let stateEntry = try! decoder.decode(StateLogEntry.self, from: data)
    //        return stateEntry
    //    }
}
