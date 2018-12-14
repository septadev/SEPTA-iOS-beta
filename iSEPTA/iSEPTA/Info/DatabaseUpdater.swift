//
//  DatabaseUpdater.swift
//  iSEPTA
//
//  Created by Mike Mannix on 5/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule
import SQLite3
import UIKit
import Zip

struct DatabaseUpdate: Codable {
    let version: Int
    let url: URL
    let updateDate: String
}

class DatabaseUpdater {
    let databaseFileManager = DatabaseFileManager()

    func checkForUpdates() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        guard let url = URL(string: "https://s3.amazonaws.com/mobiledb.septa.org/latest/latestDb.json") else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let checkTask = URLSession.shared.dataTask(with: url) { data, _, error in

                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }

                guard error == nil else {
                    if let error = error {
                        print("Error checking for database update: \(error)")
                    }
                    return
                }

                guard let data = data else {
                    print("No data returned while checking for database update")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let latestDb = try decoder.decode(DatabaseUpdate.self, from: data)
                    self.compareAgainstLocalDatabase(latestDatabase: latestDb)
                } catch {
                    print("Error decoding json response")
                }
            }
            checkTask.resume()
        }
    }

    private func compareAgainstLocalDatabase(latestDatabase: DatabaseUpdate) {
        DatabaseVersionSQLCommand.sharedInstance.version { versions, error in
            guard error == nil else {
                print("Error retrieving database version: \(error.debugDescription)")
                return
            }
            if let versions = versions, versions.count == 1 {
                if latestDatabase.version > versions[0] {
                    DispatchQueue.main.async {
                        store.dispatch(DatabaseUpdateAvailable(databaseUpdate: latestDatabase))
                    }
                } else {
                    let dbFileManager = DatabaseFileManager()
                    dbFileManager.setDatabaseUpdateInProgress(inProgress: false)
                    DispatchQueue.main.async {
                        store.dispatch(DatabaseUpToDate())
                    }
                }
            }
        }
    }

    func performDownload(latestDb: DatabaseUpdate) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let downloadTask = URLSession.shared.downloadTask(with: latestDb.url) { tempUrl, _, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            guard error == nil, let tempUrl = tempUrl else { return }
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let zippedDatabaseURL = documentsURL.appendingPathComponent("SEPTA_\(latestDb.version).zip")
            // Move the temp file
            do {
                try FileManager.default.copyItem(at: tempUrl, to: zippedDatabaseURL)
                // Expand zip file
                do {
                    try Zip.unzipFile(zippedDatabaseURL, destination: documentsURL, overwrite: true, password: nil, progress: nil, fileOutputHandler: { outputURL in
                        do {
                            try FileManager.default.removeItem(at: zippedDatabaseURL)
                        } catch {
                            print("Error removing the database zip file: \(error)")
                        }
                        if self.applyScriptToDatabase(file: outputURL) {
                            self.databaseFileManager.updateCurrentDatabase(dbURL: outputURL)
                            self.databaseFileManager.updateCurrentDatabaseVersion(version: latestDb.version)
                            self.databaseFileManager.updateDatabaseUpdateDate(updateDate: latestDb.updateDate)
                            DispatchQueue.main.async {
                                store.dispatch(DatabaseUpdateDownloaded())
                            }
                        } else {
                            DispatchQueue.main.async {
                                store.dispatch(DatabaseUpToDate())
                            }
                        }
                    })
                } catch {
                    print("Error unzipping the database: \(error)")
                }
            } catch {
                print("Error copying the downloaded temp file: \(error)")
            }
        }
        downloadTask.resume()
    }

    private func applyScriptToDatabase(file: URL) -> Bool {
        var databasePointer: OpaquePointer?
        if sqlite3_open(file.path, &databasePointer) != SQLITE_OK {
            print("Unable to open database")
            return false
        }

        if let filepath = Bundle.main.path(forResource: "septa_database_update", ofType: "sql") {
            do {
                let contents = try String(contentsOfFile: filepath)
                if sqlite3_exec(databasePointer, contents, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(databasePointer)!)
                    print("Error running update script: \(errmsg)")
                    return false
                }
            } catch {
                print("Error loading sql update script: \(error)")
                return false
            }
        }
        return true
    }
}
