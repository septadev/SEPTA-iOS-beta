//
//  DatabaseUpdateState.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

enum DatabaseUpdateStatus {
    case upToDate
    case checkForUpdate
    case updateAvailable
    case downloadUpdate
    case updateDownloaded
}

struct DatabaseUpdateState {
    let status: DatabaseUpdateStatus
    let databaseUpdate: DatabaseUpdate?
    
    init(status: DatabaseUpdateStatus, databaseUpdate: DatabaseUpdate?) {
        self.status = status
        self.databaseUpdate = databaseUpdate
    }
}

extension DatabaseUpdateStatus: Equatable {}
func == (lhs: DatabaseUpdateState, rhs: DatabaseUpdateState) -> Bool {
    var areEqual = true
    
    areEqual = lhs.status == rhs.status
    guard areEqual else { return false }

    return areEqual
}
