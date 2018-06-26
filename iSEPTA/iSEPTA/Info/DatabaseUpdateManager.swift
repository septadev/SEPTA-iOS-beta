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
    
    func appLaunched(coldStart: Bool) {
        databaseFileManager.delegate = self
        
        if coldStart {
            // On a cold start, there should never be an update in progress.
            // In case an update was in progress and for whatever reason was interrupted,
            // make sure we can still check for updates
            databaseFileManager.setDatabaseUpdateInProgress(inProgress: false)
        }
        
        if databaseFileManager.appHasASQLiteFile() {
            store.dispatch(NewDatabaseState(databaseState: .loaded))
            databaseFileManager.removeOldDatabases()
            store.dispatch(CheckForDatabaseUpdate())
        } else {
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
