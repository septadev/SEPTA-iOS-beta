//
//  DatabaseMover.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

class DatabaseMover: StoreSubscriber, DatabaseStateDelegate {

    typealias StoreSubscriberStateType = UserPreferenceState
    let databaseFileManager = DatabaseFileManager()

    init() {
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        if state.defaultsLoaded {
            movePreloadedDatabaseIfNeeded()
        }
    }

    func movePreloadedDatabaseIfNeeded() {
        let preloadedDatabaseVersion = SeptaNetwork.sharedInstance.databaseVersion
        let lastMovedDatabaseVersion = store.state.preferenceState.databaseVersion
        let forceUpdate = preloadedDatabaseVersion != lastMovedDatabaseVersion
        databaseFileManager.delegate = self
        databaseFileManager.unzipFileToDocumentsDirectoryIfNecessary(forceUpdate: forceUpdate)
    }

    func databaseStateUpdated(databaseState: DatabaseState) {
        let action = NewDatabaseState(databaseState: databaseState)
        store.dispatch(action)

        if action.databaseState == .loaded {
            updatePreferencesWithDatabaseVersion()
        }
    }

    func updatePreferencesWithDatabaseVersion() {

        let preferencesAction = PreferencesDatabaseLoaded(databaseVersion: SeptaNetwork.sharedInstance.databaseVersion)
        store.dispatch(preferencesAction)
    }

    deinit {
        store.unsubscribe(self)
    }
}
