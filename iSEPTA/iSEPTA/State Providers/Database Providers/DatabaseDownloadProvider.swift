//
//  DatabaseDownloadProvider.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

class DatabaseDownloadProvider {
    
    static let sharedInstance = DatabaseDownloadProvider()
    
    private init() {
        store.subscribe(self) {
            $0.select {
                $0.databaseUpdateState
            }.skipRepeats {
                $0 == $1
            }
        }
    }
}

extension DatabaseDownloadProvider: StoreSubscriber {
    typealias StoreSubscriberStateType = DatabaseUpdateState
    
    func newState(state: DatabaseUpdateState) {
        if state.status == .downloadUpdate, let dbUpdate = state.databaseUpdate {
            let updater = DatabaseUpdater()
            updater.performDownload(latestDb: dbUpdate)
        }
    }
}
