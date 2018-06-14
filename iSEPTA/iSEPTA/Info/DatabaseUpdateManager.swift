//
//  DatabaseUpdateManager.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/14/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule
import ReSwift

class DatabaseUpdateManager {
    
    let databaseFileManager = DatabaseFileManager()
    
    func appLaunched() {
        databaseFileManager.delegate = self
        
        // Check to see if initial db unzip was done
        if databaseFileManager.appHasASQLiteFile() {
            store.dispatch(NewDatabaseState(databaseState: .loaded))
            databaseFileManager.removeOldDatabases()
            store.dispatch(CheckForDatabaseUpdate())
        } else {
            // If not, do it. When finished, check for db updates
            databaseFileManager.unzipFileToDocumentsDirectory()
        }
        
    }
}

extension DatabaseUpdateManager: DatabaseStateDelegate {
    func databaseStateUpdated(databaseState: DatabaseState) {
        let action = NewDatabaseState(databaseState: databaseState)
        store.dispatch(action)
        
        if action.databaseState == .loaded {
            store.dispatch(CheckForDatabaseUpdate())
        }
    }
}
