//
//  AlertState_AlertDetailsWatcher.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

// Septa. 2017

import SeptaSchedule
import ReSwift
import SeptaRest

protocol AlertState_AlertDetailsWatcherDelegate: AnyObject {
    func alertState_AlertDetailsUpdated(alertDetails: [AlertDetails_Alert])
}

class AlertState_AlertDetailsWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = [AlertDetails_Alert]

    weak var delegate: AlertState_AlertDetailsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertState.alertDetails }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.alertState_AlertDetailsUpdated(alertDetails: state)
    }
}
