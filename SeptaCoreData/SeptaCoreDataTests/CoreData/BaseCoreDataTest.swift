// SEPTA.org, created on 7/29/17.

import Foundation

import XCTest
import CoreData
@testable import SeptaCoreData

class BaseCoreDataTests: XCTestCase {
    let fileManager = FileManager.default
    let setup = SetupCoreData.sharedInstance
    var moc: NSManagedObjectContext!
    var privateMoc: NSManagedObjectContext!

    override func setUp() {
        try! setup.removeCoreDataFiles()
        try! setup.createPersistentStore()
        moc = setup.getMainQueueManagedObjectContext()
        privateMoc = setup.getPrivateQueueManagedObjectContext()
    }

    override func tearDown() {
        try! setup.destroyPersistentStore()
    }

    func getStopCountFromMainQueue() -> Int {
        let fetchRequest = NSFetchRequest<Stop>(entityName: Stop.entityName())

        return try! moc.count(for: fetchRequest)
    }

    func getStopTimeCountFromMainQueue() -> Int {
        let fetchRequest = NSFetchRequest<StopTime>(entityName: StopTime.entityName())

        return try! moc.count(for: fetchRequest)
    }
}
