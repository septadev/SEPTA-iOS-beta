// Septa.org created on 7/28/17.

import Foundation


class PreloadedDatabaseMover {


    lazy var preloadedDatabaseURL: URL? = {
        let bundle = Bundle(for: SetupCoreData.self)
        return bundle.url(forResource: "SEPTA", withExtension: "zip")
    }()

//    lazy var applicationDocumentsDirectory: URL? = {
//
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls.first
//    }()
//
//    lazy var persistentStoreURL: URL? = {
//        self.applicationDocumentsDirectory!.appendingPathComponent(SetupCoreData.dbName)
//    }()
//
//    lazy var managedObjectModel: NSManagedObjectModel? = {
//        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = self.managedObjectModelURL!
//        return NSManagedObjectModel(contentsOf: modelURL)!
//    }()

}
