//
//  DatabaseUpdateProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

class DatabaseUpdateProvider {
    static let sharedInstance = DatabaseUpdateProvider()

    private init() {
        store.subscribe(self) {
            $0.select {
                $0.databaseUpdateState
            }.skipRepeats {
                $0 == $1
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}

extension DatabaseUpdateProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = DatabaseUpdateState

    func newState(state: DatabaseUpdateState) {
        if state.status == .checkForUpdate {
            let dbFileManager = DatabaseFileManager()
            print("DB Update Status: \(dbFileManager.isDatabaseUpdateInProgress())")
            if !dbFileManager.isDatabaseUpdateInProgress() {
                dbFileManager.setDatabaseUpdateInProgress(inProgress: true)
                let updater = DatabaseUpdater()
                updater.checkForUpdates()
            }
        }
    }
}
