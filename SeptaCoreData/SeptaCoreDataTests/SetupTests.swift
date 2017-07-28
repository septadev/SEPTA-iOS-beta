//
//  SetupTests.swift
//  SeptaCoreDataTests
//
//  Created by Mark Broski on 7/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import XCTest
import CoreData
@testable import SeptaCoreData

class SetupTests: XCTestCase {
    let fileManager = FileManager.default

    func testModelURLExists() {
        let setup = SetupCoreData()
        let url = setup.managedObjectModelURL
        XCTAssertNotNil(url)
    }

    func testDocumentsDirectoryExists() {
        let setup = SetupCoreData()
        let docUrl = setup.applicationDocumentsDirectory
        XCTAssertNotNil(docUrl)
    }

    func testManagedObjectModelExists() {
        let setup = SetupCoreData()
        let model = setup.managedObjectModel
        XCTAssertNotNil(model)
    }

    func testPersistentStoreCoordinatorExists() {
        let setup = SetupCoreData()
        let coordinator = setup.persistentStoreCoordinator
        XCTAssertNotNil(coordinator)
    }

    func testCreatePersistentStore() {
        let setup = SetupCoreData()
        try! setup.createPersistentStore()
        let path = setup.persistentStoreURL!.path
        XCTAssertTrue(fileManager.fileExists(atPath: path))
    }

    func testDestroyPersistentStore() {
        let setup = SetupCoreData()
        try! setup.createPersistentStore()

        try! setup.destroyPersistentStore()
    }

    func testUIMocExists() {
        let setup = SetupCoreData()
        let moc = setup.uiManagedObjectContext
        XCTAssertNotNil(moc)
    }

    func testAddSomeObjects() {
        let setup = SetupCoreData()
        try! setup.createPersistentStore()
        let moc = setup.uiManagedObjectContext!
        let transitType: TransitType = moc.insertObject()
        XCTAssertNotNil(transitType)
    }

    func testAddSomeObjectsWithValue() {
        let setup = SetupCoreData()
        try! setup.createPersistentStore()
        let moc = setup.uiManagedObjectContext!
        let transitType = TransitType.insert(intoContext: moc, name: "Mark")
        moc.saveOrRollback()
        XCTAssertNotNil(transitType)
    }

    func testSaveChanges() {
        let setup = SetupCoreData()
        try! setup.destroyPersistentStore()
        try! setup.createPersistentStore()
        let moc = setup.uiManagedObjectContext!
        let transitType = TransitType.insert(intoContext: moc, name: "Mark")
        XCTAssertTrue(moc.saveOrRollback())
        let count = getTransitTypeCount(moc: moc)
        XCTAssertGreaterThan(count, 0, "Should be a result there")

        XCTAssertNotNil(transitType)
    }

    func getTransitTypeCount(moc: NSManagedObjectContext) -> Int {
        let fetchRequest = NSFetchRequest<TransitType>(entityName: "TransitType")
        fetchRequest.fetchBatchSize = 20
        let results = try! moc.fetch(fetchRequest)
        return results.count
    }
}
