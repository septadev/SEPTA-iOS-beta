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

class SetupTests: BaseCoreDataTests {

    func testModelURLExists() {
        validateMainThread()
        let url = setup.managedObjectModelURL
        XCTAssertNotNil(url)
    }

    func testDocumentsDirectoryExists() {
        validateMainThread()
        let docUrl = setup.applicationDocumentsDirectory
        XCTAssertNotNil(docUrl)
    }

    func testManagedObjectModelExists() {
        validateMainThread()
        let model = setup.managedObjectModel
        XCTAssertNotNil(model)
    }

    func testPersistentStoreCoordinatorExists() {
        validateMainThread()
        let coordinator = setup.persistentStoreCoordinator
        XCTAssertNotNil(coordinator)
    }

    func testCreatePersistentStore() {
        validateMainThread()
        try! setup.destroyPersistentStore()
        let path = setup.persistentStoreURL!.path
        // when you blow up the persistent store, it doesn't delete the sqlite file, just empties it.
        XCTAssertTrue(fileManager.fileExists(atPath: path))
    }

    func testUIMocExists() {
        XCTAssertNotNil(moc)
    }

    func testEntityDescriptionExists() {
        let _entityDescription = _TransitType.entity(managedObjectContext: moc)
        XCTAssertNotNil(_entityDescription)
    }

    func testEntityInitWorks() {
        let transitType = TransitType(managedObjectContext: moc)
        XCTAssertNotNil(transitType)
    }

    func testThatSaveWorks() {
        let transitType = TransitType(managedObjectContext: moc)!
        transitType.name = "Rail"

        do {
            try moc.save()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testThatFetchWorks() {
        let transitType = TransitType(managedObjectContext: moc)!
        transitType.name = "Rail"
        do {
            try moc.save()
        } catch {
            XCTFail(error.localizedDescription)
        }
        let count = getTransitTypeCountFromMainQueue()
        XCTAssertEqual(count, 1)
    }

    func testThatSaveOnPrivateMocWorks() {
        let transitType = TransitType(managedObjectContext: privateMoc)!
        transitType.name = "Rail"

        privateMoc.performAndWait {
            do {
                try privateMoc.save()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        let count = getTransitTypeCountFromMainQueue()
        XCTAssertEqual(count, 1)
    }

    func getTransitTypeCountFromMainQueue() -> Int {
        let fetchRequest = NSFetchRequest<TransitType>(entityName: TransitType.entityName())
        fetchRequest.fetchBatchSize = 20
        let results = try! moc.fetch(fetchRequest)
        return results.count
    }

    func validateMainThread() {
        XCTAssertTrue(Thread.isMainThread, "Somehow you got off the main thread")
    }
}
