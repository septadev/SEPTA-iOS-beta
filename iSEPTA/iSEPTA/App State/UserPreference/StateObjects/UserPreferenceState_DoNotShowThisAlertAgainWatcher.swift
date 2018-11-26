//
//  UserPreferenceState_DoNotShowThisAlertAgainWatcher.swift
//  iSEPTA
//
//  Created by James Johnson on 11/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import ReSwift
import SeptaSchedule

// TODO: JJ 7
protocol UserPreferenceState_DoNotShowThisAlertAgainWatcherDelegate: AnyObject {
    func userPreferenceState_DoNotShowThisAlertAgainUpdated(doNotShowThisAlertAgainWatcher: Bool)
}

class UserPreferenceState_DoNotShowThisAlertAgainWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = Bool
    
    weak var delegate: UserPreferenceState_DoNotShowThisAlertAgainWatcherDelegate? {
        didSet {
            subscribe()
        }
    }
    
    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.doNotShowThisAlertAgain }
        }
    }
    
    func newState(state: StoreSubscriberStateType) {
        delegate?.userPreferenceState_DoNotShowThisAlertAgainUpdated(doNotShowThisAlertAgainWatcher: state)
    }
}
