//
//  AlertQueueState_ManageAlertsWatcher.swift
//  iSEPTA
//
//  Created by James Johnson on 12/06/2018.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift

protocol AlertQueueState_ManageAlertsWatcherDelegate: AnyObject {
    func alertQueueState_AlertsQueueUpdated(alertQueue: AppAlert)
}

class AlertQueueState_ManageAlertsWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = AppAlert
    
    weak var delegate: AlertQueueState_ManageAlertsWatcherDelegate? {
        didSet {
            subscribe()
        }
    }
    
    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.alertQueueState.nextAlertToDisplay }
        }
    }
    
    func newState(state: StoreSubscriberStateType) {
        delegate?.alertQueueState_AlertsQueueUpdated(alertQueue: state)
    }
}
