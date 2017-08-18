// Septa. 2017

import Foundation
import Zip

enum DatabaseFileManagerError: Error {
    case NoPreloadedDatabase
    case NoDocumentsDirectory
}

public class DatabaseFileManager {

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

    public func unzipFileToDocumentsDirectoryIfNecessary(startCompletion: ((String) -> Void)? = nil, endCompletion: ((String) -> Void)? = nil) {
        let message: String
        if databaseFileExistsInDocumentsDirectory {
            message = "The schedule database is good to go"
            endCompletion?("Database is loaded")
        } else {
            moveDatabase(endCompletion: endCompletion)
            message = "Please allow a few moments to get the database set up"
        }

        startCompletion?(message)
    }

    func moveDatabase(endCompletion: ((String) -> Void)?) {

        var message: String = "The database has been successfully moved."
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            do {
                guard let preloadedURL = strongSelf.preloadedZippedDatabaseURL else { throw DatabaseFileManagerError.NoPreloadedDatabase }
                guard let documentsURL = strongSelf.documentDirectoryURL else { throw DatabaseFileManagerError.NoDocumentsDirectory }
                try Zip.unzipFile(preloadedURL, destination: documentsURL, overwrite: false, password: nil, progress: { (progress) -> Void in
                    if progress == 1 {
                        DispatchQueue.main.async {
                            endCompletion?(message)
                        }
                    }
                })
            } catch {
                message = error.localizedDescription
                DispatchQueue.main.async {
                    endCompletion?(message)
                }
            }
        }
    }

    public init() {}
}
