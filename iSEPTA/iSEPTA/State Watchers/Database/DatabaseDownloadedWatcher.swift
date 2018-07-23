//
//  DatabaseDownloadedWatcher.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/13/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

protocol DatabaseDownloadedWatcherDelegate: AnyObject {
    func databaseDownloadComplete()
}

class DatabaseDownloadedWatcher: BaseWatcher {
    weak var delegate: DatabaseDownloadedWatcherDelegate?

    init(delegate: DatabaseDownloadedWatcherDelegate) {
        super.init()
        self.delegate = delegate
        subscribe()
    }

    private func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.databaseUpdateState
            }
        }
    }
}

extension DatabaseDownloadedWatcher: StoreSubscriber {
    typealias StoreSubscriberStateType = DatabaseUpdateState

    func newState(state: DatabaseUpdateState) {
        if state.status == .updateDownloaded {
            delegate?.databaseDownloadComplete()
        }
    }
}
