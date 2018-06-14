//
//  DatabaseUpdateActions.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule

protocol DatabaseUpdateAction: SeptaAction {}

struct CheckForDatabaseUpdate: DatabaseUpdateAction {
    let description = "Check for database update"
}

struct DatabaseUpdateAvailable: DatabaseUpdateAction {
    let databaseUpdate: DatabaseUpdate
    let description = "Database update is available"
}

struct DownloadDatabaseUpdate: DatabaseUpdateAction {
    let description = "Download database update"
}

struct DatabaseUpdateDownloaded: DatabaseUpdateAction {
    let description = "Database update downloaded"
}

struct DatabaseUpToDate: DatabaseUpdateAction {
    let description = "Database is up to date"
}
