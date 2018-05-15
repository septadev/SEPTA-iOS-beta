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

    public weak var delegate: DatabaseStateDelegate?

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

    public func unzipFileToDocumentsDirectoryIfNecessary(forceUpdate: Bool = false) {

        if databaseFileExistsInDocumentsDirectory && !forceUpdate {
            updateState(databaseState: .loaded)
            print("No need to move database")
        } else {
            updateState(databaseState: .loading)
            print("database will be moving")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.moveDatabase()
            }
        }
    }

    private func moveDatabase() {

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            do {
                guard let preloadedURL = strongSelf.preloadedZippedDatabaseURL else { throw DatabaseFileManagerError.NoPreloadedDatabase }
                guard var documentsURL = strongSelf.documentDirectoryURL else { throw DatabaseFileManagerError.NoDocumentsDirectory }

                try Zip.unzipFile(preloadedURL, destination: documentsURL, overwrite: true, password: nil, progress: { (progress) -> Void in
                    if progress == 1 {
                        strongSelf.updateState(databaseState: .loaded)
                        print("database unzip is complete")
                    }
                })
                var resourceValues: URLResourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true
                try documentsURL.setResourceValues(resourceValues)
            } catch {
                print(error.localizedDescription)
                strongSelf.updateState(databaseState: .error)
            }
        }
    }

    func updateState(databaseState: DatabaseState) {
        DispatchQueue.main.async {
            self.delegate?.databaseStateUpdated(databaseState: databaseState)
        }
    }

    public init() {}
}
