//
//  DatabaseUpdater.swift
//  iSEPTA
//
//  Created by Mike Mannix on 5/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit
import Zip
import SQLite3
import SeptaSchedule

struct DatabaseUpdate : Codable {
    let version: Int
    let url: URL
    let updateDate: String
}

class DatabaseUpdater {
    
    let databaseFileManager = DatabaseFileManager()
    
    func checkForUpdates() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        guard let url = URL(string: "https://s3.amazonaws.com/mobiledb.septa.org/latest/latestDb.json") else { return }
        let checkTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("Error checking for database update: \(error)")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            guard let data = data else {
                print("No data returned while checking for database update")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let latestDb = try decoder.decode(DatabaseUpdate.self, from: data)
                
                if latestDb.version > self.databaseFileManager.currentDatabaseVersion() {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    DispatchQueue.main.async {
                        store.dispatch(DatabaseUpdateAvailable(databaseUpdate: latestDb))
                    }
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    let dbFileManager = DatabaseFileManager()
                    dbFileManager.setDatabaseUpdateInProgress(inProgress: false)
                    DispatchQueue.main.async {
                        store.dispatch(DatabaseUpToDate())
                    }
                }
            } catch {
                print("Error decoding json response")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        checkTask.resume()
    }
    
    func performDownload(latestDb: DatabaseUpdate) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let downloadTask = URLSession.shared.downloadTask(with: latestDb.url) { (tempUrl, response, error) in
            guard error == nil, let tempUrl = tempUrl else { return }
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let zippedDatabaseURL = documentsURL.appendingPathComponent("SEPTA_\(latestDb.version).zip")
            // Move the temp file
            do {
                try FileManager.default.copyItem(at: tempUrl, to: zippedDatabaseURL)
                // Expand zip file
                do {
                    try Zip.unzipFile(zippedDatabaseURL, destination: documentsURL, overwrite: true, password: nil, progress: nil, fileOutputHandler: { (outputURL) in
                        do {
                            try FileManager.default.removeItem(at: zippedDatabaseURL)
                        } catch {
                            print("Error removing the database zip file: \(error)")
                        }
                        self.applyScriptToDatabase(file: outputURL)
                        self.databaseFileManager.updateCurrentDatabase(dbURL: outputURL)
                        self.databaseFileManager.updateCurrentDatabaseVersion(version: latestDb.version)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        DispatchQueue.main.async {
                            store.dispatch(DatabaseUpdateDownloaded())
                        }
                    })
                } catch {
                    print("Error unzipping the database: \(error)")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            } catch {
                print("Error copying the downloaded temp file: \(error)")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        downloadTask.resume()
    }
    
    private func applyScriptToDatabase(file: URL) {
        var databasePointer: OpaquePointer?
        if sqlite3_open(file.path, &databasePointer) != SQLITE_OK {
            print("Unable to open database")
        }
        
        if let filepath = Bundle.main.path(forResource: "septa_database_update", ofType: "sql") {
            do {
                let contents = try String(contentsOfFile: filepath)
                if sqlite3_exec(databasePointer, contents, nil, nil, nil) != SQLITE_OK {
                    let errmsg = String(cString: sqlite3_errmsg(databasePointer)!)
                    print("Error running update script: \(errmsg)")
                }
            } catch {
                print("Error loading sql update script: \(error)")
            }
        }
    }
}

