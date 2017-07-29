//
//  Setup.swift
//  SeptaCoreData
//
//  Created by Mark Broski on 7/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreData

public final class SetupCoreData {
    static let dbName = "SeptaCoreData.sqlite"
    static let modelName = "SeptaModel"
    static let coreDataDirectoryName = "SEPTACoreData"

    static let sharedInstance = SetupCoreData()

    let fileManager = FileManager.default

    private init() {
        print("Private Init is called")
    } // This prevents others from using the default '()' initializer for this class.

    lazy var managedObjectModelURL: URL? = {
        let bundle = Bundle(for: SetupCoreData.self)
        print("Initiatiing Moc")
        return bundle.url(forResource: SetupCoreData.modelName, withExtension: "momd")
    }()

    lazy var applicationDocumentsDirectory: URL? = {
        print("Locating Documents Directory")
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first
    }()

    lazy var coreDataDirectory: URL? = {
        guard let docsDirectory = applicationDocumentsDirectory else { return nil }
        return docsDirectory.appendingPathComponent(SetupCoreData.coreDataDirectoryName)

    }()

    func createCoreDataDirectoryIfNeeded() {
        do {
            try fileManager.createDirectory(at: coreDataDirectory!, withIntermediateDirectories: true, attributes: nil)
            print("Creating directory for core data")
        } catch {
            print(error.localizedDescription)
        }
    }

    lazy var persistentStoreURL: URL? = {
        let url = coreDataDirectory?.appendingPathComponent(SetupCoreData.dbName)
        print("SQL LITE DB is here: \(url!)")
        return url
    }()

    lazy var managedObjectModel: NSManagedObjectModel? = {
        print("Building out Managed Object Model")
        let modelURL = self.managedObjectModelURL!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        print("Building Persistent Store Coordinator")
        return NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
    }()

    public func getMainQueueManagedObjectContext() -> NSManagedObjectContext? {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistentStoreCoordinator
        return moc
    }

    public func getPrivateQueueManagedObjectContext() -> NSManagedObjectContext? {
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = persistentStoreCoordinator
        return moc
    }

    public func createPersistentStore() throws {
        createCoreDataDirectoryIfNeeded()
        try persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL!, options: nil)
        assert(persistentStoreCoordinator!.persistentStores.count == 1)
        print("adding persistent store")
    }

    public func destroyPersistentStore() throws {
        guard persistentStoreCoordinator?.persistentStores.count == 1 else { return }
        try persistentStoreCoordinator?.destroyPersistentStore(at: persistentStoreURL!, ofType: NSSQLiteStoreType, options: nil)
        assert(persistentStoreCoordinator!.persistentStores.count == 0)

        print("removing persistent store")
    }

    func removeCoreDataFiles() throws {
        let coreDataPath = coreDataDirectory!.path
        let enumerator = fileManager.enumerator(atPath: coreDataPath)
        fileManager.changeCurrentDirectoryPath(coreDataPath)
        while let file = enumerator?.nextObject() as? String {
            try fileManager.removeItem(atPath: file)
        }
    }

    public func resetPersistentStore() throws {
        try destroyPersistentStore()
        try createPersistentStore()
    }

    deinit {
        print("Core Data Setup is disappearing")
    }
}
