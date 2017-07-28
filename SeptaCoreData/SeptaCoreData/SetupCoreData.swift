//
//  Setup.swift
//  SeptaCoreData
//
//  Created by Mark Broski on 7/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreData

public final class SetupCoreData {
    static let dbName = "Septa.sqlite"
    static let modelName = "SeptaModel"

    lazy var managedObjectModelURL: URL? = {
        let bundle = Bundle(for: SetupCoreData.self)
        return bundle.url(forResource: SetupCoreData.modelName, withExtension: "momd")
    }()

    lazy var applicationDocumentsDirectory: URL? = {

        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first
    }()

    lazy var persistentStoreURL: URL? = {
        self.applicationDocumentsDirectory!.appendingPathComponent(SetupCoreData.dbName)
    }()

    lazy var managedObjectModel: NSManagedObjectModel? = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = self.managedObjectModelURL!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
    }()

    public lazy var uiManagedObjectContext: NSManagedObjectContext? = {
        guard let persistentStoreCoordinator = self.persistentStoreCoordinator else { return nil }
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistentStoreCoordinator
        return moc
    }()

    public func createPersistentStore() throws {
        try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL!, options: nil)
    }

    public func destroyPersistentStore() throws {
        try persistentStoreCoordinator?.destroyPersistentStore(at: persistentStoreURL!, ofType: NSSQLiteStoreType, options: nil)
    }

    public func resetPersistentStore() throws {
        try destroyPersistentStore()
        try createPersistentStore()
    }
}
