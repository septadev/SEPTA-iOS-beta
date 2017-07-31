// SEPTA.org, created on 7/31/17.

import Foundation
import Zip

enum DatabaseFileManagerError: Error {
    case NoPreloadedDatabase
    case NoDocumentsDirectory
}

class DatabaseFileManager {

    fileprivate let bundle = Bundle(for: DatabaseFileManager.self)
    fileprivate let databaseName = "SEPTA.sqlite"
    let fileManager = FileManager.default

    lazy var preloadedZippedDatabaseURL: URL? = {
        bundle.url(forResource: "SEPTA", withExtension: "zip")
    }()

    lazy var documentDirectoryURL: URL? = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }()

    lazy var databaseURL: URL? = {
        documentDirectoryURL?.appendingPathComponent(databaseName)
    }()

    var databaseFileExistsInDocumentsDirectory: Bool {
        guard let url = databaseURL else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    func unzipFileToDocumentsDirectoryIfNecessary() throws {
        guard let preloadedURL = preloadedZippedDatabaseURL else { throw DatabaseFileManagerError.NoPreloadedDatabase }
        guard let documentsURL = documentDirectoryURL else { throw DatabaseFileManagerError.NoDocumentsDirectory }
        if !databaseFileExistsInDocumentsDirectory {
            try Zip.unzipFile(preloadedURL, destination: documentsURL, overwrite: false, password: nil, progress: nil)
        }
    }
}
