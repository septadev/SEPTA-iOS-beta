//
//  DatabaseUpdateWatcher.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/12/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaSchedule
import ReSwift

protocol DatabaseUpdateWatcherDelegate: AnyObject {
    func databaseUpdateAvailable()
}

class DatabaseUpdateWatcher: BaseWatcher {
    weak var delegate: DatabaseUpdateWatcherDelegate?
    
    init(delegate: DatabaseUpdateWatcherDelegate) {
        super.init()
        self.delegate = delegate
        subscribe()
    }
    
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.databaseUpdateState
            }
        }
    }
}

extension DatabaseUpdateWatcher: StoreSubscriber {
    typealias StoreSubscriberStateType = DatabaseUpdateState
    
    func newState(state: DatabaseUpdateState) {
        if state.status == .updateAvailable {
            delegate?.databaseUpdateAvailable()
        }
    }
}
