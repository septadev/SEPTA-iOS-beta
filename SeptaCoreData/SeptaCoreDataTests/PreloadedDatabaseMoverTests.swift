// SEPTA.org, created on 7/28/17.


import XCTest
import CoreData
@testable import SeptaCoreData

class ProloadedDatabaseMoverTests: XCTestCase {

    let mover = PreloadedDatabaseMover()
    let fileManager = FileManager.default

    func testURL(){

        let url = mover.preloadedDatabaseURL
        fileManager.fileExists(atPath: url!.path)
    
    }


}
