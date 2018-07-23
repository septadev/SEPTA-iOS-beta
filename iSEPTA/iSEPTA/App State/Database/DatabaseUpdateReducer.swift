//
//  DatabaseUpdateReducer.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule

struct DatabaseUpdateReducer {
    static func main(action: Action, state: DatabaseUpdateState?) -> DatabaseUpdateState {
        guard let state = state else { return DatabaseUpdateState(status: .upToDate, databaseUpdate: nil) }
        guard let action = action as? DatabaseUpdateAction else { return state }

        if action is CheckForDatabaseUpdate {
            return DatabaseUpdateState(status: .checkForUpdate, databaseUpdate: nil)
        }
        if let action = action as? DatabaseUpdateAvailable {
            return DatabaseUpdateState(status: .updateAvailable, databaseUpdate: action.databaseUpdate)
        }
        if action is DownloadDatabaseUpdate {
            return DatabaseUpdateState(status: .downloadUpdate, databaseUpdate: state.databaseUpdate)
        }
        if action is DatabaseUpdateDownloaded {
            return DatabaseUpdateState(status: .updateDownloaded, databaseUpdate: nil)
        }
        if action is DatabaseUpToDate {
            return DatabaseUpdateState(status: .upToDate, databaseUpdate: nil)
        }

        return state
    }
}
