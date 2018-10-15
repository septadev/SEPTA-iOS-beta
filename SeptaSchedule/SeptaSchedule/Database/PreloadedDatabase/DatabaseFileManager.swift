// Septa. 2017

import Foundation
import Zip

enum DatabaseFileManagerError: Error {
    case NoPreloadedDatabase
    case NoDocumentsDirectory
}

public class DatabaseFileManager {
    fileprivate let currentDatabaseNameKey = "currentDatabaseKey"
    fileprivate let currentDatabaseVersionKey = "currentDatabaseVersionKey"
    fileprivate let databaseUpdateInProgressKey = "databaseUpdateInProgressKey"
    fileprivate let databaseUpdateDateKey = "databaseUpdateDateKey"

    fileprivate let bundle = Bundle(for: DatabaseFileManager.self)
    fileprivate let defaultDatabaseName = "SEPTA.sqlite"
    let fileManager = FileManager.default
    let defaults = UserDefaults.standard

    public weak var delegate: DatabaseStateDelegate?

    lazy var preloadedZippedDatabaseURL: URL? = {
        bundle.url(forResource: "SEPTA", withExtension: "zip")
    }()

    lazy var documentDirectoryURL: URL? = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }()

    var databaseFileExistsInDocumentsDirectory: Bool {
        guard let url = databaseURL() else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    public func databaseURL() -> URL? {
        if let currentDB = defaults.string(forKey: currentDatabaseNameKey) {
            return documentDirectoryURL?.appendingPathComponent(currentDB)
        } else {
            return documentDirectoryURL?.appendingPathComponent(defaultDatabaseName)
        }
    }

    public func unzipFileToDocumentsDirectory() {
        updateState(databaseState: .loading)
        print("database will be moving")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.moveDatabase()
        }
    }

    public func appHasASQLiteFile() -> Bool {
        return allUserSqliteFiles().count > 0
    }

    private func allUserSqliteFiles() -> [URL] {
        var allSqliteFiles: [URL] = []

        guard let docDirUrl = documentDirectoryURL else { return allSqliteFiles }
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: docDirUrl, includingPropertiesForKeys: nil, options: [])
            allSqliteFiles = directoryContents.filter {
                $0.pathExtension == "sqlite"
            }
        } catch {
            // 😞
        }
        return allSqliteFiles
    }

    public func resetCurrentDatabaseName(dbURL: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            // Set database name property
            strongSelf.updateCurrentDatabase(dbURL: dbURL)
            // Set database version property
            DatabaseVersionSQLCommand.sharedInstance.version(completion: { versions, error in
                guard error == nil else { return }
                if let versions = versions, versions.count == 1 {
                    let dbVersion = versions[0]
                    strongSelf.updateCurrentDatabaseVersion(version: dbVersion)
                }
            })
        }
        // let databaseUpdateManager = DatabaseFileManager()
        // store.dispatch(databaseUpdateManager.CheckForDatabaseUpdate())
    }

    public func updateCurrentDatabase(dbURL: URL) {
        defaults.set(dbURL.lastPathComponent, forKey: currentDatabaseNameKey)
    }

    public func updateDatabaseUpdateDate(updateDate: String) {
        defaults.set(updateDate, forKey: databaseUpdateDateKey)
    }

    public func databaseUpdateDate() -> String {
        return defaults.string(forKey: databaseUpdateDateKey) ?? ""
    }

    public func updateCurrentDatabaseVersion(version: Int) {
        defaults.set(version, forKey: currentDatabaseVersionKey)
    }

    public func currentDatabaseVersion() -> Int {
        return defaults.integer(forKey: currentDatabaseVersionKey)
    }

    public func isDatabaseUpdateInProgress() -> Bool {
        return defaults.bool(forKey: databaseUpdateInProgressKey)
    }

    public func setDatabaseUpdateInProgress(inProgress: Bool) {
        defaults.set(inProgress, forKey: databaseUpdateInProgressKey)
    }

    public func removeOldDatabases() {
        guard let currentDatabase = self.databaseURL() else { return }

        let allSqliteFiles = allUserSqliteFiles()
        for file in allSqliteFiles {
            if file.lastPathComponent != currentDatabase.lastPathComponent {
                if allSqliteFiles.count == 1 {
                    resetCurrentDatabaseName(dbURL: file)
                } else {
                    do {
                        try fileManager.removeItem(at: file)
                    } catch {
                        // ¯\_(ツ)_/¯
                    }
                }
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
                        strongSelf.resetCurrentDatabaseName(dbURL: documentsURL.appendingPathComponent(strongSelf.defaultDatabaseName))
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
